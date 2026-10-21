"""Build a bounded deformation trial from the pinned Blender Studio CC0 body.

Keeps the authored body proportions. Writes a separate source and GLB; never
rebuilds or replaces adventurer.blend/adventurer.glb.
"""
from pathlib import Path
import math, json, hashlib
import bpy
from mathutils import Vector, Matrix

ROOT=Path(__file__).resolve().parents[2]
BUNDLE=ROOT/'tools/logs/base-model-comparison/vendor/human-base-meshes-bundle-v1.4.1/human_base_meshes_bundle.blend'
SOURCE=ROOT/'art/source/characters/studio_trial'
EXPORT=ROOT/'assets/models/characters/studio_trial'
EVIDENCE=ROOT/'art/references/character/studio_rig_trial'
for p in [SOURCE,EXPORT,EVIDENCE]:p.mkdir(parents=True,exist_ok=True)
if not BUNDLE.exists():raise RuntimeError('Download the pinned official bundle; see tools/blender/STUDIO_TRIAL.md')
bpy.ops.wm.open_mainfile(filepath=str(BUNDLE))
source=bpy.data.objects['GEO-body_male_realistic']
source.modifiers['Multires'].levels=1
source.modifiers['Multires'].render_levels=1
bpy.context.view_layer.update()
deps=bpy.context.evaluated_depsgraph_get()
mesh=bpy.data.meshes.new_from_object(source.evaluated_get(deps),depsgraph=deps)
low=min(v.co.z for v in mesh.vertices);high=max(v.co.z for v in mesh.vertices)
scale=1.8/(high-low)
for v in mesh.vertices:v.co=Vector((-v.co.x*scale,-v.co.y*scale,(v.co.z-low)*scale))
mesh.update()
eye_meshes=[]
for name in ['GEO-body_male_realistic.eye.L','GEO-body_male_realistic.eye.R']:
    o=bpy.data.objects[name]
    d=bpy.data.meshes.new_from_object(o.evaluated_get(deps),depsgraph=deps)
    # Bring eyes from collection/world coordinates into the body's local frame.
    d.transform(source.matrix_world.inverted() @ o.matrix_world)
    for v in d.vertices:v.co=Vector((-v.co.x*scale,-v.co.y*scale,(v.co.z-low)*scale))
    eye_meshes.append((name,d))
for o in list(bpy.data.objects):bpy.data.objects.remove(o,do_unlink=True)
for c in list(bpy.data.collections):bpy.data.collections.remove(c)
body=bpy.data.objects.new('StudioTrialBody',mesh);bpy.context.scene.collection.objects.link(body)
mesh.name='StudioTrialBodyMesh'
sets={}
for poly,value in zip(mesh.polygons,mesh.attributes['.sculpt_face_set'].data):
    sets.setdefault(value.value,set()).update(poly.vertices)

def mean(ids):
    ids=list(ids)
    if not ids:raise RuntimeError('Empty anatomical landmark')
    return sum((mesh.vertices[i].co for i in ids),Vector())/len(ids)

def seam(a,b):return mean(sets[a]&sets[b])

def mat(name,color,rough=.78):
    m=bpy.data.materials.new(name);m.use_nodes=True;m.diffuse_color=(*color,1)
    bs=m.node_tree.nodes['Principled BSDF'];bs.inputs['Base Color'].default_value=(*color,1)
    bs.inputs['Roughness'].default_value=rough;bs.inputs['Specular IOR Level'].default_value=.22
    return m

clay=mat('Trial_NeutralClay',(.40,.43,.46))
dark=mat('Trial_PelvisCoverage',(.035,.048,.065))
mesh.materials.clear();mesh.materials.append(clay);mesh.materials.append(dark)
for p in mesh.polygons:
    p.use_smooth=True
    center=sum((mesh.vertices[i].co for i in p.vertices),Vector())/len(p.vertices)
    p.material_index=1 if .64<center.z<.94 and abs(center.x)<.27 else 0

ad=bpy.data.armatures.new('StudioTrialSkeleton')
rig=bpy.data.objects.new('StudioTrialRig',ad);bpy.context.scene.collection.objects.link(rig)
rig.show_in_front=True;ad.display_type='STICK'
bpy.context.view_layer.objects.active=rig
rig.select_set(True);bpy.ops.object.mode_set(mode='EDIT')
bones={};finger_sets={};hand_frames={};chains={}

def bone(name,a,b,parent=None,roll=Vector((0,1,0)),deform=True):
    a=Vector(a);b=Vector(b);e=ad.edit_bones.new(name);e.head=a;e.tail=b
    e.use_deform=deform
    if parent:e.parent=ad.edit_bones[parent]
    e.align_roll(roll)
    bones[name]=(a,b)
    return e

bone('root',(0,0,0),(0,0,.18),deform=False)
bone('pelvis',(0,0,.90),(0,0,1.04),'root')
bone('spine_01',(0,0,1.04),(0,0,1.18),'pelvis')
bone('spine_02',(0,0,1.18),(0,0,1.32),'spine_01')
bone('chest',(0,0,1.32),(0,0,1.45),'spine_02')
bone('neck',(0,0,1.45),(0,0,1.57),'chest')
bone('head',(0,0,1.57),(0,0,1.77),'neck')
for label,sgn,upper,fore,palm,thigh,shin,foot,starts in [
    ('R',1,20,11,10,23,16,13,[84,88,92,96,100]),
    ('L',-1,21,12,9,24,15,14,[80,76,72,68,64])]:
    shoulder=seam(1,upper);elbow=seam(upper,fore);wrist=seam(fore,palm)
    digit_chains=[]
    for f,start in enumerate(starts):
        joints=[seam(palm,start),seam(start,start+1),seam(start+1,start+2)]
        direction=(mean(sets[start+2])-joints[-1]).normalized()
        ids=sets[start+2]|sets.get(start+3,set())
        projections=[(mesh.vertices[i].co-joints[-1]).dot(direction) for i in ids]
        top=max(projections)-.003
        tip=mean([i for i in ids if (mesh.vertices[i].co-joints[-1]).dot(direction)>=top])
        joints.append(tip);digit_chains.append(joints)
        finger_sets[(label,f)]=[sets[start+k] for k in range(3)]+[sets.get(start+3,set())]
    across=(digit_chains[1][0]-digit_chains[4][0]).normalized()
    knuckles=sum((j[0] for j in digit_chains[1:]),Vector())/4
    long=(knuckles-wrist).normalized()
    inward=across.cross(long).normalized()
    if inward.x*sgn>0:inward=-inward
    bone('clavicle_'+label,(.035*sgn,0,1.435),shoulder,'chest')
    bone('upper_arm_'+label,shoulder,elbow,'clavicle_'+label)
    bone('forearm_'+label,elbow,wrist,'upper_arm_'+label)
    bone('hand_'+label,wrist,knuckles,'forearm_'+label,inward)
    for f,joints in enumerate(digit_chains):
        for k in range(3):
            name=f'finger_{label}_{f}_{k}'
            bone(name,joints[k],joints[k+1],'hand_'+label if k==0 else f'finger_{label}_{f}_{k-1}',inward)
    chains[label]=digit_chains
    hip=seam(18,thigh);knee=seam(thigh,shin);ankle=seam(shin,foot)
    ball=ankle+Vector((.025*sgn,.105,-.055))
    bone('thigh_'+label,hip,knee,'pelvis')
    bone('shin_'+label,knee,ankle,'thigh_'+label)
    bone('foot_'+label,ankle,ball,'shin_'+label,Vector((0,0,1)))
    bone('toes_'+label,ball,ball+Vector((.015*sgn,.060,-.005)),'foot_'+label,Vector((0,0,1)))
    grip_y=across
    grip_z=(inward-grip_y*inward.dot(grip_y)).normalized();grip_x=grip_y.cross(grip_z).normalized()
    grip=Matrix((grip_x,grip_y,grip_z)).transposed().to_4x4()
    grip.translation=knuckles+inward*.034+long*.025
    hand_frames[label]={'grip_world':grip,'wrist':wrist,'long':long,'palm':palm,'fore':fore}
bpy.ops.object.mode_set(mode='OBJECT')

# Bind body automatically, then constrain hand ownership to its authored
# anatomical face sets. These weights move the intact mesh, not its rest shape.
bpy.ops.object.select_all(action='DESELECT');body.select_set(True);rig.select_set(True)
bpy.context.view_layer.objects.active=rig
bpy.ops.object.parent_set(type='ARMATURE_AUTO')
if not body.modifiers:raise RuntimeError('Heat binding failed')
body.modifiers[0].use_deform_preserve_volume=False

def weights(index,values):
    for g in list(mesh.vertices[index].groups):body.vertex_groups[g.group].remove([index])
    total=sum(values.values())
    for name,w in values.items():
        if w>1e-6:body.vertex_groups[name].add([index],w/total,'REPLACE')

def smooth(a,b,t):
    t=max(0,min(1,(t-a)/(b-a)));return t*t*(3-2*t)

for label in ['R','L']:
    frame=hand_frames[label];wrist=frame['wrist'];long=frame['long']
    for i in sets[frame['palm']]:
        hand=smooth(-.012,.028,(mesh.vertices[i].co-wrist).dot(long))
        weights(i,{'hand_'+label:hand,'forearm_'+label:1-hand})
    for f,joints in enumerate(chains[label]):
        ids=set().union(*finger_sets[(label,f)])
        for i in ids:
            p=mesh.vertices[i].co
            options=[]
            for k in range(3):
                d=joints[k+1]-joints[k];t=(p-joints[k]).dot(d)/d.length_squared
                nearest=joints[k]+d*max(0,min(1,t))
                options.append(((p-nearest).length,k,t))
            _distance,k,t=min(options)
            influence={k:1.0}
            if t<.22 and k>0:influence={k-1:.5*(1-max(0,t)/.22),k:.5+.5*max(0,t)/.22}
            elif t>.78 and k<2:influence={k:1-.5*min(1,(t-.78)/.22),k+1:.5*min(1,(t-.78)/.22)}
            first=(p-joints[0]).dot((joints[1]-joints[0]).normalized())
            amount=smooth(-.006,.012,first)
            values={'hand_'+label:1-amount}
            for segment,w in influence.items():values[f'finger_{label}_{f}_{segment}']=w*amount
            weights(i,values)

unweighted=[]
for v in mesh.vertices:
    values=sorted([(body.vertex_groups[g.group].name,g.weight) for g in v.groups if g.weight>1e-7],key=lambda x:x[1],reverse=True)[:4]
    if not values:unweighted.append(v.index);continue
    weights(v.index,dict(values))
if unweighted:raise RuntimeError(f'Unweighted body vertices: {len(unweighted)}')

objects=[body,rig]
for name,data in eye_meshes:
    eye=bpy.data.objects.new('StudioTrialEye_'+name[-1],data);bpy.context.scene.collection.objects.link(eye)
    data.materials.clear();data.materials.append(mat('Trial_Eye',(.62,.65,.67)))
    g=eye.vertex_groups.new(name='head');g.add(list(range(len(data.vertices))),1,'REPLACE')
    mod=eye.modifiers.new('Trial head skin','ARMATURE');mod.object=rig;eye.parent=rig
    for p in data.polygons:p.use_smooth=True
    objects.append(eye)
local_grips={}
for label in ['R','L']:
    grip=hand_frames[label]['grip_world']
    local=ad.bones['hand_'+label].matrix_local.inverted() @ grip
    local_grips[label]={'origin':list(local.translation),'basis_columns':[list(local.to_3x3().col[i]) for i in range(3)]}
    socket=bpy.data.objects.new('TrialGripSocket_'+label,None);bpy.context.scene.collection.objects.link(socket)
    socket.empty_display_size=.025;socket.empty_display_type='ARROWS'
    socket.parent=rig;socket.parent_type='BONE';socket.parent_bone='hand_'+label
    bpy.context.view_layer.update();socket.matrix_world=grip
    objects.append(socket)
rig['scope']='Isolated rig trial; no wardrobe or gameplay integration'
rig['anatomy_author']='Dan Ulrich / Blender Studio';rig['anatomy_license']='CC0'
scene=bpy.context.scene;scene['human_acceptance']='pending';scene['asset']='Blender Studio isolated deformation trial'
bpy.ops.object.select_all(action='DESELECT')
for o in objects:o.select_set(True)
bpy.context.view_layer.objects.active=rig
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'studio_rig_trial.blend'))
path=EXPORT/'studio_rig_trial.glb'
bpy.ops.export_scene.gltf(filepath=str(path),export_format='GLB',use_selection=True,
    export_skins=True,export_animations=False,export_extras=True,export_yup=True)
report={'source_bundle':'Human Base Meshes v1.4.1','asset':'Body Male - Realistic','author':'Dan Ulrich','license':'CC0',
    'scope':'rig, weights, neutral posture, grip, walk and turn trial only; no wardrobe/mission replacement',
    'height_m':1.8,'vertices':len(mesh.vertices),'bones':len(ad.bones),'glb_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
    'unweighted_vertices':len(unweighted),'rest_shape_sculpt_corrections':0,'max_influences':4,'grips':local_grips,
    'bones_blender':{n:{'head':list(a),'tail':list(b)} for n,(a,b) in bones.items()},
    'finger_landmarks':{side:[[list(p) for p in chain] for chain in cs] for side,cs in chains.items()},
    'human_acceptance':'pending'}
(EXPORT/'rig_metadata.json').write_text(json.dumps(report,indent=2),encoding='utf8')
(EVIDENCE/'export_report.json').write_text(json.dumps(report,indent=2),encoding='utf8')
print('STUDIO_TRIAL_EXPORT_OK',len(ad.bones),len(mesh.vertices),path)
