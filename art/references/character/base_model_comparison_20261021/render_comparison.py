"""Read-only model comparison. Never saves the production .blend or GLB."""
from pathlib import Path
import json, math, hashlib, sys
import bpy
import numpy as np
from mathutils import Vector, Matrix

PROJECT = next(p for p in Path(__file__).resolve().parents if (p/'project.godot').exists())
WORK = PROJECT / 'tools/logs/base-model-comparison'
OUT = PROJECT / 'art/references/character/base_model_comparison_20261021'
OUT.mkdir(parents=True, exist_ok=True)
BUNDLE = WORK / 'vendor/human-base-meshes-bundle-v1.4.1/human_base_meshes_bundle.blend'
report = {'purpose':'Asset comparison only; no game assets changed', 'human_acceptance':'pending',
          'blender':bpy.app.version_string, 'height_m':1.8, 'materials':'shared neutral clay; dark pelvis coverage',
          'source_poses':'Native rest poses preserved; no candidate rig or animation inferred',
          'studio_url':'https://download.blender.org/demo/asset-bundles/human-base-meshes/human-base-meshes-bundle-v1.4.1.zip',
          'studio_zip_sha256':hashlib.sha256((WORK/'human-base-meshes-bundle-v1.4.1.zip').read_bytes()).hexdigest(),
          'camera_settings': {
              'front':{'position':[0,5,.92],'target':[0,0,.92],'ortho_scale':2.02,'size':[800,1000]},
              'three_quarter':{'position':[3,5,1.05],'target':[0,0,.97],'ortho_scale':2.02,'size':[800,1000]},
              'torso':{'position':[0,5,1.30],'target':[0,0,1.30],'ortho_scale':.92,'size':[900,800]},
              'hand_aligned':{'ortho_scale':.28,'target':[0,0,-.025],'size':[800,800],
                              'A_position':[0,4,-.025],'B_position':[0,-4,-.025]},
          },
          'models':{}}

def material(name, color):
    m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value=(*color,1)
    p.inputs['Roughness'].default_value=.78
    p.inputs['Specular IOR Level'].default_value=.22
    return m

def pelvis_mask(mat):
    nodes=mat.node_tree.nodes;links=mat.node_tree.links
    geo=nodes.new('ShaderNodeNewGeometry');sep=nodes.new('ShaderNodeSeparateXYZ')
    links.new(geo.outputs['Position'],sep.inputs[0])
    a=nodes.new('ShaderNodeMath');a.operation='GREATER_THAN';a.inputs[1].default_value=.64
    b=nodes.new('ShaderNodeMath');b.operation='LESS_THAN';b.inputs[1].default_value=.94
    x=nodes.new('ShaderNodeMath');x.operation='ABSOLUTE'
    c=nodes.new('ShaderNodeMath');c.operation='LESS_THAN';c.inputs[1].default_value=.27
    links.new(sep.outputs['Z'],a.inputs[0]);links.new(sep.outputs['Z'],b.inputs[0])
    links.new(sep.outputs['X'],x.inputs[0]);links.new(x.outputs[0],c.inputs[0])
    ab=nodes.new('ShaderNodeMath');ab.operation='MULTIPLY'
    abc=nodes.new('ShaderNodeMath');abc.operation='MULTIPLY'
    links.new(a.outputs[0],ab.inputs[0]);links.new(b.outputs[0],ab.inputs[1])
    links.new(ab.outputs[0],abc.inputs[0]);links.new(c.outputs[0],abc.inputs[1])
    mix=nodes.new('ShaderNodeMixRGB');mix.inputs[1].default_value=(.42,.44,.46,1)
    mix.inputs[2].default_value=(.08,.095,.115,1)
    links.new(abc.outputs[0],mix.inputs[0]);links.new(mix.outputs[0],nodes['Principled BSDF'].inputs['Base Color'])

def surface_copy(obj, name):
    deps=bpy.context.evaluated_depsgraph_get()
    ev=obj.evaluated_get(deps)
    data=bpy.data.meshes.new_from_object(ev, depsgraph=deps)
    out=bpy.data.objects.new(name,data); bpy.context.scene.collection.objects.link(out)
    out.matrix_world=obj.matrix_world.copy()
    return out

def normalized(objects):
    for o in objects:
        transform=o.matrix_world.copy()
        o.data.transform(transform);o.matrix_world=Matrix.Identity(4)
    verts=[v.co.copy() for o in objects for v in o.data.vertices]
    low=min(v.z for v in verts); high=max(v.z for v in verts)
    center=(min(v.x for v in verts)+max(v.x for v in verts))*.5
    scale=1.8/(high-low)
    for o in objects:
        for v in o.data.vertices:
            v.co.x=(v.co.x-center)*scale; v.co.y*=scale; v.co.z=(v.co.z-low)*scale
        o.data.update()
    return scale

def raw_makehuman():
    path=PROJECT/'art/source/characters/vendor/makehuman/base.obj'
    verts=[];faces=[];group=''
    for line in path.read_text(encoding='utf-8-sig').splitlines():
        row=line.split()
        if not row:continue
        if row[0]=='v':verts.append((float(row[1]),float(row[3]),float(row[2])))
        elif row[0]=='g':group=row[1]
        elif row[0]=='f' and group=='body':faces.append(tuple(reversed([int(x.split('/')[0])-1 for x in row[1:]])))
    ids=sorted({i for f in faces for i in f});ix={i:j for j,i in enumerate(ids)}
    data=bpy.data.meshes.new('MakeHumanOriginal')
    data.from_pydata([verts[i] for i in ids],[],[tuple(ix[i] for i in f) for f in faces]);data.update()
    obj=bpy.data.objects.new('MakeHumanOriginal',data);bpy.context.scene.collection.objects.link(obj)
    mod=obj.modifiers.new('Comparison subdivision','SUBSURF');mod.levels=1;mod.render_levels=1
    result=surface_copy(obj,'MakeHumanOriginalSurface')
    obj.hide_render=True
    return [result]

def prepare(key):
    metadata={}
    if key.startswith('current'):
        if key!='current_no_contact':
            bpy.ops.wm.open_mainfile(filepath=str(PROJECT/'art/source/characters/adventurer.blend'))
        else:
            # Rebuild only the in-memory pre-corrective scene. Stop before any
            # atlas generation, save or export in the production generator.
            bpy.ops.wm.read_factory_settings(use_empty=True)
            source=PROJECT/'tools/blender/create_character.py'
            prefix=source.read_text(encoding='utf8').split("\ngrip_contact(PARTS,")[0]
            assert 'bpy.ops.wm.save' not in prefix and 'bpy.ops.export_scene' not in prefix
            exec(compile(prefix,str(source),'exec'),{'__file__':str(source),'__name__':'comparison_build'})
        rig=bpy.data.objects['AdventurerRig'];rig.data.pose_position='REST'
        if key=='current_common_apose':
            rig.data.pose_position='POSE'
            for label,angle in [('L',math.radians(22)),('R',math.radians(-22))]:
                bone=rig.pose.bones['upper_arm_'+label]
                rest=bone.bone.matrix_local.copy();pivot=Matrix.Translation(rest.translation)
                bone.matrix=pivot @ Matrix.Rotation(angle,4,'Y') @ pivot.inverted() @ rest
            bpy.context.view_layer.update()
            metadata['temporary_comparison_pose']='Shoulders rotated 22 degrees outward; no game file changed'
        for o in bpy.data.objects:o.hide_render=True
        meshes=[o for o in bpy.data.objects if o.type=='MESH' and o.get('wardrobe_role') in ['always','body','base']]
        objects=[surface_copy(o,'Compare_'+o.name) for o in meshes]
        metadata['source']='In-memory create_character.py prefix, stopped before grip_contact; no save/export' if key=='current_no_contact' else 'art/source/characters/adventurer.blend'
        metadata['rigged_in_source']=True
        metadata['grip_contact_applied']=key!='current_no_contact'
    elif key=='makehuman':
        bpy.ops.wm.read_factory_settings(use_empty=True)
        objects=raw_makehuman()
        metadata['source']='Pinned MakeHuman hm08 base.obj; diagnostic baseline, not a second ready character'
        metadata['rigged_in_source']=False
    else:
        bpy.ops.wm.open_mainfile(filepath=str(BUNDLE))
        col=bpy.data.collections['Body Male - Realistic']
        metadata['asset']={p:getattr(col.asset_data,p,'') for p in ['author','description','license','copyright']}
        metadata['bundle_readme']=bpy.data.texts['README'].as_string()
        body=bpy.data.objects['GEO-body_male_realistic']
        for m in body.modifiers:
            if m.type=='MULTIRES':m.levels=1;m.render_levels=1
        bpy.context.view_layer.update()
        objects=[surface_copy(o,'Compare_'+o.name) for o in col.all_objects if o.type=='MESH']
        for o in objects:o.data.transform(Matrix.Rotation(math.pi,4,'Z'));o.matrix_world=Matrix.Rotation(math.pi,4,'Z') @ o.matrix_world @ Matrix.Rotation(-math.pi,4,'Z')
        # Collapse this transformation below; preserve the authored proportions.
        metadata['source']='Blender Studio Human Base Meshes 1.4.1 / Body Male - Realistic'
        metadata['rigged_in_source']=False
        metadata['base_vertices']=len(body.data.vertices)
        metadata['vertex_groups']=len(body.vertex_groups)
        for o in bpy.data.objects:
            if o not in objects:o.hide_render=True
    scale=normalized(objects)
    for o in bpy.data.objects:
        if o.type in ['CAMERA','LIGHT']:o.hide_render=True
    clay=material('Comparison neutral clay',(.42,.44,.46))
    pelvis_mask(clay)
    for o in objects:
        o.hide_render=False;o.hide_set(False)
        o.data.materials.clear();o.data.materials.append(clay)
        for p in o.data.polygons:
            p.use_smooth=True
            p.material_index=0
    bounds=[v.co.copy() for o in objects for v in o.data.vertices]
    metadata.update({'render_vertices':sum(len(o.data.vertices) for o in objects),
                     'render_faces':sum(len(o.data.polygons) for o in objects),
                     'native_width_m':max(v.x for v in bounds)-min(v.x for v in bounds),
                     'normalization_scale':scale,'renders':report['models'].get(key,{}).get('renders',[])})
    scene=bpy.context.scene
    scene.render.engine='CYCLES';scene.cycles.samples=24;scene.cycles.use_denoising=True
    scene.cycles.device='CPU'
    scene.render.resolution_percentage=100
    scene.render.image_settings.file_format='PNG'
    scene.render.film_transparent=False
    scene.world=bpy.data.worlds.new('Comparison World');scene.world.use_nodes=True
    scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.025,.032,.043,1)
    scene.world.node_tree.nodes['Background'].inputs[1].default_value=.4
    scene.view_settings.view_transform='AgX'
    scene.view_settings.look='AgX - Medium High Contrast'
    scene.view_settings.exposure=0;scene.view_settings.gamma=1
    for pos,power,size in [((-3,4,5),500,4),((3,1,3),230,3),((0,-3,3),350,3)]:
        d=bpy.data.lights.new('Comparison Softbox','AREA');d.energy=power;d.shape='DISK';d.size=size
        light=bpy.data.objects.new(d.name,d);scene.collection.objects.link(light)
        light.location=pos;light.rotation_euler=(Vector((0,0,1))-light.location).to_track_quat('-Z','Y').to_euler()
    camera=bpy.data.objects.new('Comparison Camera',bpy.data.cameras.new('Comparison Camera'))
    scene.collection.objects.link(camera);scene.camera=camera;camera.data.type='ORTHO';camera.data.lens=70
    report['models'][key]=metadata
    return objects, camera

def shot(key, camera, label, pos, target, scale, size=(800,1000)):
    scene=bpy.context.scene;camera.location=pos;camera.rotation_euler=(Vector(target)-camera.location).to_track_quat('-Z','Y').to_euler()
    camera.data.ortho_scale=scale
    scene.render.resolution_x=size[0];scene.render.resolution_y=size[1]
    scene.render.filepath=str(OUT/f'{key}_{label}.png')
    bpy.ops.render.render(write_still=True)
    filename=f'{key}_{label}.png'
    if filename not in report['models'][key]['renders']:report['models'][key]['renders'].append(filename)

def aligned_hand(objects,key,camera):
    # Crop the integral hand surface using a wrist plane, then rotate the whole
    # cutout rigidly into its PCA frame. The geometry and fingers are not posed.
    cutoff={'current':.92,'current_no_contact':.92,'current_common_apose':1.02,'makehuman':1.24,'studio':.985}[key]
    xmin={'current':0,'current_no_contact':0,'current_common_apose':0,'makehuman':.34,'studio':.28}[key]
    selected=[]
    for obj in objects:
        if key.startswith('current') and 'HumanHands' not in obj.name:continue
        ids={v.index for v in obj.data.vertices if v.co.x>xmin and .45<v.co.z<cutoff}
        faces=[tuple(p.vertices) for p in obj.data.polygons if all(i in ids for i in p.vertices)]
        if faces:selected.append((obj,faces))
    vertices=[];faces=[]
    for obj,fs in selected:
        ids=sorted({i for f in fs for i in f});ix={i:j+len(vertices) for j,i in enumerate(ids)}
        vertices.extend([obj.data.vertices[i].co.copy() for i in ids])
        faces.extend([tuple(ix[i] for i in f) for f in fs])
    xyz=np.array([list(v) for v in vertices]);mean=xyz.mean(axis=0)
    _vals,axes=np.linalg.eigh(np.cov((xyz-mean).T))
    long=axes[:,2]
    if long[2]<0:long=-long
    wide=axes[:,1]
    if wide[0]<0:wide=-wide
    normal=np.cross(long,wide)
    rotated=(xyz-mean) @ np.array([wide,normal,long]).T
    rotated-= (rotated.min(axis=0)+rotated.max(axis=0))*.5
    mesh=bpy.data.meshes.new('AlignedHand');mesh.from_pydata(rotated.tolist(),[],faces);mesh.update()
    hand=bpy.data.objects.new('AlignedHand',mesh);bpy.context.scene.collection.objects.link(hand)
    mesh.materials.append(material('Hand comparison clay',(.42,.44,.46)))
    for p in mesh.polygons:p.use_smooth=True
    for o in objects:o.hide_render=True
    shot(key,camera,'hand_aligned_A',(0,4,-.025),(0,0,-.025),.28,(800,800))
    shot(key,camera,'hand_aligned_B',(0,-4,-.025),(0,0,-.025),.28,(800,800))
    shot(key,camera,'hand_aligned_oblique',(2,4,.675),(0,0,-.025),.28,(800,800))
    hand.hide_render=True

args=sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else []
hands_only='--hands-only' in args
keys=[a for a in args if not a.startswith('--')] or ['current','makehuman','studio','current_no_contact']
if (OUT/'comparison_report.json').exists():
    old=json.loads((OUT/'comparison_report.json').read_text(encoding='utf8'))
    report['models'].update(old.get('models',{}))
for key in keys:
    objects,camera=prepare(key)
    if hands_only:
        aligned_hand(objects,key,camera)
        (OUT/'comparison_report.json').write_text(json.dumps(report,indent=2),encoding='utf8')
        continue
    shot(key,camera,'front',(0,5,.92),(0,0,.92),2.02)
    shot(key,camera,'three_quarter',(3,5,1.05),(0,0,.97),2.02)
    shot(key,camera,'torso',(0,5,1.30),(0,0,1.30),.92,(900,800))
    # Right hand from the full body, shown from the front in the native rest pose.
    # A close-up in native orientation diagnoses silhouette before any new rig.
    vertices=[v.co.copy() for o in objects for v in o.data.vertices]
    hand_region=[v for v in vertices if v.x>.26 and .47<v.z<1.05]
    # Locate the lower hand/fingertips while excluding upper arm geometry.
    if key=='makehuman':hand_region=[v for v in vertices if v.x>.45 and .5<v.z<1.24]
    bottom=min(v.z for v in hand_region)
    hand=[v for v in hand_region if v.z<bottom+.205]
    center=sum(hand,Vector())/len(hand)
    metadata=report['models'][key];metadata['hand_view_center']=list(center)
    shot(key,camera,'hand_front',(center.x,center.y+4,center.z),center,.30,(800,800))
    shot(key,camera,'hand_back',(center.x,center.y-4,center.z),center,.30,(800,800))
    shot(key,camera,'hand_oblique',(center.x+3,center.y+4,center.z+.7),center,.32,(800,800))
    aligned_hand(objects,key,camera)
    (OUT/'comparison_report.json').write_text(json.dumps(report,indent=2),encoding='utf8')
report['production_unchanged_sha256']={str(p.relative_to(PROJECT)):hashlib.sha256(p.read_bytes()).hexdigest()
    for p in [PROJECT/'art/source/characters/adventurer.blend',PROJECT/'assets/models/characters/adventurer.glb']}
report['raw_capture_count']=len([p for p in OUT.glob('*.png') if p.name not in ['body_comparison.png','hands_comparison.png','contact_diagnostic.png']])
(OUT/'comparison_report.json').write_text(json.dumps(report,indent=2),encoding='utf8')
print('BASE_COMPARISON_RENDER_OK',OUT)
