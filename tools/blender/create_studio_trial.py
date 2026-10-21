"""Build a bounded deformation trial from the pinned Blender Studio CC0 body.

Keeps the authored body proportions. Writes a separate source and GLB; never
rebuilds or replaces adventurer.blend/adventurer.glb.
"""
from pathlib import Path
import math, json, hashlib
import bpy
import bmesh
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
    # The hilt runs from wrist to knuckles through the palm; it must not lie
    # crosswise along the knuckle row. In the relaxed arm pose this aligns the
    # blade with the forearm/hand, as a held sword should.
    grip_y=long
    grip_z=(inward-grip_y*inward.dot(grip_y)).normalized();grip_x=grip_y.cross(grip_z).normalized()
    grip=Matrix((grip_x,grip_y,grip_z)).transposed().to_4x4()
    grip.translation=wrist+long*((knuckles-wrist).length*.58)+inward*.025
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

# First clothing fit for the isolated Blender Studio candidate: a simple dark
# base shirt, shorts and low shoes. These are separate skinned shells and do
# not replace the approved production character or its full uniform.
base_cloth=mat('Trial_BaseCloth',(.055,.064,.072),.94)
base_shoe=mat('Trial_BaseLeather',(.070,.046,.029),.84)
base_trim=mat('Trial_BaseTrim',(.13,.12,.105),.88)

def get_weights(index):
    values={}
    for group in mesh.vertices[index].groups:
        name=body.vertex_groups[group.group].name
        values[name]=group.weight
    return values

def interpolate(a,b,t):
    names=set(a['w'])|set(b['w'])
    return {'p':a['p'].lerp(b['p'],t),'n':a['n'].lerp(b['n'],t).normalized(),
        'w':{name:a['w'].get(name,0)*(1-t)+b['w'].get(name,0)*t for name in names}}

def clip_polygon(poly,field):
    out=[]
    for a,b in zip(poly,poly[1:]+poly[:1]):
        fa,fb=field(a),field(b)
        if fa>=0:out.append(a)
        if (fa>=0)!=(fb>=0):out.append(interpolate(a,b,fa/(fa-fb)))
    return out

def fitted_garment(name,material,fields,outset=.007,thickness=.003,max_components=1):
    vertices=[];normals=[];point_weights=[];faces=[];lookup={}
    for polygon in mesh.polygons:
        poly=[{'p':mesh.vertices[i].co.copy(),'n':mesh.vertices[i].normal.copy(),'w':get_weights(i)} for i in polygon.vertices]
        for field in fields:
            if not poly:break
            poly=clip_polygon(poly,field)
        if len(poly)<3:continue
        indices=[]
        for point in poly:
            key=tuple(round(c,6) for c in point['p'])
            if key not in lookup:
                lookup[key]=len(vertices);vertices.append(point['p']);normals.append(point['n'])
                point_weights.append(point['w'])
            indices.append(lookup[key])
        if len(set(indices))>=3:faces.append(indices)
    if not faces:raise RuntimeError(f'Fitted clothing surface is empty: {name}')
    adjacency={i:set() for i in range(len(vertices))};edge_counts={}
    for face in faces:
        for a,b in zip(face,face[1:]+face[:1]):
            adjacency[a].add(b);adjacency[b].add(a)
            edge=tuple(sorted((a,b)));edge_counts[edge]=edge_counts.get(edge,0)+1
    remaining=set(adjacency);components=[]
    while remaining:
        stack=[remaining.pop()];component=set(stack)
        while stack:
            for neighbour in adjacency[stack.pop()]:
                if neighbour in remaining:
                    remaining.remove(neighbour);component.add(neighbour);stack.append(neighbour)
        components.append(component)
    keep=set().union(*sorted(components,key=len,reverse=True)[:max_components])
    chosen=sorted(keep);remap={old:new for new,old in enumerate(chosen)}
    faces=[[remap[i] for i in face] for face in faces if all(i in keep for i in face)]
    vertices=[vertices[i] for i in chosen];normals=[normals[i] for i in chosen]
    point_weights=[point_weights[i] for i in chosen]
    # The base garment should read as fabric instead of a dark copy of the
    # body's pecs, abs and toes. Relax the broad surface while holding every
    # cut contour in place; hidden skin is recessed separately below.
    adjacency={i:set() for i in range(len(vertices))};edge_counts={}
    for face in faces:
        for a,b in zip(face,face[1:]+face[:1]):
            adjacency[a].add(b);adjacency[b].add(a)
            edge=tuple(sorted((a,b)));edge_counts[edge]=edge_counts.get(edge,0)+1
    boundary={i for edge,uses in edge_counts.items() if uses==1 for i in edge}
    iterations=4 if name=='BaseTop' else 4 if name=='BaseShorts' else 8
    coords=[point.copy() for point in vertices]
    for _ in range(iterations):
        updates={i:coords[i].lerp(sum((coords[n] for n in adjacency[i]),Vector())/len(adjacency[i]),.14)
            for i in adjacency if i not in boundary and adjacency[i]}
        for i,point in updates.items():coords[i]=point
    vertices=coords
    count=len(vertices)
    outer=[vertices[i]+normals[i]*outset for i in range(count)]
    inner=[vertices[i]+normals[i]*(outset-thickness) for i in range(count)]
    shell_faces=list(faces)+[list(reversed([i+count for i in face])) for face in faces]
    for (a,b),uses in edge_counts.items():
        if uses==1 and a in remap and b in remap:
            a,b=remap[a],remap[b];shell_faces.append([a,b,b+count,a+count])
    data=bpy.data.meshes.new(name+'Mesh');data.from_pydata(outer+inner,[],shell_faces);data.update()
    bm=bmesh.new();bm.from_mesh(data);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(data);bm.free()
    data.materials.append(material)
    obj=bpy.data.objects.new(name,data);bpy.context.scene.collection.objects.link(obj)
    obj.parent=rig;obj['wardrobe_role']='base';obj['fixed_bone']=''
    for polygon in data.polygons:polygon.use_smooth=True
    group_names=sorted(set(name for values in point_weights for name in values))
    groups={name:obj.vertex_groups.new(name=name) for name in group_names}
    for i,values in enumerate(point_weights):
        ordered=sorted(values.items(),key=lambda pair:pair[1],reverse=True)[:4]
        total=sum(weight for _,weight in ordered)
        if total<=1e-8:raise RuntimeError(f'Unweighted garment point in {name}')
        for group_name,weight in ordered:
            if weight>1e-7:
                groups[group_name].add([i,i+count],weight/total,'REPLACE')
    modifier=obj.modifiers.new('Studio trial skin','ARMATURE');modifier.object=rig
    return obj

top_fields=[lambda v:v['p'].z-1.01,lambda v:1.64-v['p'].z,
    lambda v:(v['p'].x/.13)**2+(v['p'].y/.13)**2+((v['p'].z-1.70)/.25)**2-1,
    lambda v:.30+.025*math.exp(-((v['p'].z-1.50)/.07)**2)-abs(v['p'].x),
    lambda v:.12-v['w'].get('head',0)]
shorts_fields=[lambda v:v['p'].z-.735,lambda v:1.055-v['p'].z,
    lambda v:sum(value for name,value in v['w'].items() if name=='pelvis' or name.startswith('thigh_'))-.58]
shirt=fitted_garment('BaseTop',base_cloth,top_fields,outset=.007,thickness=.003)
shorts=fitted_garment('BaseShorts',base_cloth,shorts_fields,outset=.006,thickness=.003)

shoes=[]
def attached_shoe_part(name,material,label,rings):
    centre_x=.2217*(1 if label=='R' else -1);centre_y=.0159;sides=32
    vertices=[];faces=[]
    for y,centre_z,rx,rz in rings:
        for i in range(sides):
            angle=math.tau*i/sides
            vertices.append((centre_x+rx*math.cos(angle),centre_y+y,centre_z+rz*math.sin(angle)))
    faces.append(tuple(reversed(range(sides))))
    for row in range(len(rings)-1):
        for i in range(sides):
            a=row*sides+i;b=row*sides+(i+1)%sides
            faces.append((a,b,b+sides,a+sides))
    faces.append(tuple((len(rings)-1)*sides+i for i in range(sides)))
    data=bpy.data.meshes.new(name+'Mesh');data.from_pydata(vertices,[],faces);data.update()
    bm=bmesh.new();bm.from_mesh(data);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(data);bm.free()
    data.materials.append(material)
    obj=bpy.data.objects.new(name,data);bpy.context.scene.collection.objects.link(obj)
    obj.parent=rig;obj['wardrobe_role']='base';obj['fixed_bone']='foot_'+label
    for polygon in data.polygons:polygon.use_smooth=True
    group=obj.vertex_groups.new(name='foot_'+label)
    group.add(list(range(len(data.vertices))),1.0,'REPLACE')
    modifier=obj.modifiers.new('Studio trial shoe skin','ARMATURE');modifier.object=rig
    return obj

for side,label in [(1,'R'),(-1,'L')]:
    # Measured from the Studio mesh's weighted foot/toe vertices; the source
    # foot is wider and longer than its ankle-to-toe bone landmarks suggest.
    # A tapered closed shoe volume hides the toe anatomy instead of tracing it.
    shoes.append(attached_shoe_part('BaseShoeUpper_'+label,base_shoe,label,
        [(-.136,.061,.042,.069),(-.110,.065,.057,.067),(-.074,.063,.072,.062),
         (-.034,.060,.078,.057),(.010,.054,.078,.051),(.054,.041,.071,.040),
         (.094,.028,.058,.028),(.124,.020,.036,.019),(.137,.017,.012,.013)]))
    shoes.append(attached_shoe_part('BaseShoeSole_'+label,base_trim,label,
        [(-.140,.010,.042,.010),(-.120,.010,.062,.010),(-.075,.010,.078,.010),
         (-.030,.010,.083,.010),(.015,.010,.082,.010),(.060,.010,.074,.010),
         (.100,.010,.061,.010),(.132,.010,.039,.010),(.143,.010,.015,.010)]))

# The fitted shoe wraps the toes; use the same dark leather on any toe details
# that remain visible through the simple shell. This keeps skin from reading as
# bare toes while the candidate's foot proportions and rig stay intact.
mesh.materials.append(base_shoe)
for polygon in mesh.polygons:
    centre=sum((mesh.vertices[i].co for i in polygon.vertices),Vector())/len(polygon.vertices)
    foot_amount=sum(max(get_weights(i).get('foot_R',0)+get_weights(i).get('toes_R',0),
        get_weights(i).get('foot_L',0)+get_weights(i).get('toes_L',0)) for i in polygon.vertices)/len(polygon.vertices)
    if centre.z<.265 and foot_amount>.28:polygon.material_index=2
mesh.update()

objects=[body,rig]
for name,data in eye_meshes:
    eye=bpy.data.objects.new('StudioTrialEye_'+name[-1],data);bpy.context.scene.collection.objects.link(eye)
    data.materials.clear();data.materials.append(mat('Trial_Eye',(.62,.65,.67)))
    g=eye.vertex_groups.new(name='head');g.add(list(range(len(data.vertices))),1,'REPLACE')
    mod=eye.modifiers.new('Trial head skin','ARMATURE');mod.object=rig;eye.parent=rig
    for p in data.polygons:p.use_smooth=True
    objects.append(eye)
objects.extend([shirt,shorts,*shoes])
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
    'scope':'isolated rig, fitted base clothing and footwear trial; no uniform/mission replacement',
    'height_m':1.8,'vertices':len(mesh.vertices),'bones':len(ad.bones),'glb_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
    'unweighted_vertices':len(unweighted),'rest_shape_sculpt_corrections':0,'max_influences':4,'grips':local_grips,
    'base_clothing':['BaseTop','BaseShorts','BaseShoeUpper_R','BaseShoeSole_R','BaseShoeUpper_L','BaseShoeSole_L'],
    'bones_blender':{n:{'head':list(a),'tail':list(b)} for n,(a,b) in bones.items()},
    'finger_landmarks':{side:[[list(p) for p in chain] for chain in cs] for side,cs in chains.items()},
    'human_acceptance':'pending'}
(EXPORT/'rig_metadata.json').write_text(json.dumps(report,indent=2),encoding='utf8')
(EVIDENCE/'export_report.json').write_text(json.dumps(report,indent=2),encoding='utf8')
print('STUDIO_TRIAL_EXPORT_OK',len(ad.bones),len(mesh.vertices),path)
