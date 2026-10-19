"""Build the original player body and first wardrobe on one deforming armature.

Run with Blender --background --python tools/blender/create_character.py.
Rebuilds the editable source; manual changes must be kept in another file.
Human anatomy derives from the pinned MakeHuman CC0 basemesh; the adapted rig,
wardrobe and materials are produced here. See the bundled asset credits.
"""
from pathlib import Path
import math
import json
import hashlib
import sys
import bpy
import bmesh
import numpy as np
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0,str(Path(__file__).parent))
from human_base import build as build_human
SOURCE = ROOT / 'art/source/characters'
EXPORT = ROOT / 'assets/models/characters'
EVIDENCE = ROOT / 'art/references/character'
for directory in (SOURCE, EXPORT, EVIDENCE):
    directory.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
PARTS = []
BONES = {}


def material(name, color, roughness, weave=False, metal=0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1)
    bsdf.inputs['Roughness'].default_value = roughness
    bsdf.inputs['Metallic'].default_value = metal
    bsdf.inputs['Specular IOR Level'].default_value = .18 if weave else .28
    if weave:
        n = 512
        yy, xx = np.mgrid[:n, :n]
        rng = np.random.default_rng(42)
        grain = rng.normal(0, .014, (n, n))
        grain += .018 * np.sin(xx * math.pi / 2) + .018 * np.sin(yy * math.pi / 2)
        # Linear pixels; Blender encodes the exported image with its color space.
        pixels = np.ones((n, n, 4), dtype=np.float32)
        for c in range(3):
            pixels[:, :, c] = np.clip(color[c] * (1 + grain), 0, 1)
        image = bpy.data.images.new(name + '_weave', width=n, height=n)
        image.pixels.foreach_set(pixels.ravel())
        image.pack()
        tex = mat.node_tree.nodes.new('ShaderNodeTexImage')
        tex.image = image
        mat.node_tree.links.new(tex.outputs['Color'], bsdf.inputs['Base Color'])
    return mat


SKIN = material('Skin_warm_sand', (.44, .285, .205), .68)
HAIR = material('Hair_umber', (.035, .022, .017), .9)
EYE = material('Eyes_ivory', (.55, .48, .39), .3)
IRIS = material('Iris_dark_hazel', (.055, .036, .016), .35)
BASE = material('Base_woven_charcoal', (.065, .07, .073), .9, True)
BASE_TRIM = material('Base_seams', (.13, .125, .112), .85)
ROBE = material('Robe_graphite', (.055, .061, .067), .88, True)
PANEL = material('Robe_slate', (.105, .116, .124), .87, True)
LINEN = material('Linen_warm_grey', (.26, .235, .19), .94, True)
LEATHER = material('Leather_dark', (.045, .027, .019), .66, True)
BRONZE = material('Buckle_old_bronze', (.25, .16, .065), .56, False, .65)


def mesh(name, vertices, faces, mat, role, bone=None, subdiv=0):
    data = bpy.data.meshes.new(name)
    data.from_pydata(vertices, [], faces)
    data.update()
    bm = bmesh.new()
    bm.from_mesh(data)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(data)
    bm.free()
    obj = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat)
    obj['wardrobe_role'] = role
    obj['fixed_bone'] = bone or ''
    for p in data.polygons:
        p.use_smooth = True
    if subdiv:
        mod = obj.modifiers.new('Surface continuity', 'SUBSURF')
        mod.levels = subdiv
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=mod.name)
    PARTS.append(obj)
    return obj


def loft(name, rings, mat, role, bone=None, sides=32, cap=True, subdiv=1):
    # Each ring is x,y,z, width radius, depth radius.
    vertices = []
    for j, (x, y, z, rx, ry) in enumerate(rings):
        for i in range(sides):
            a = 2 * math.pi * i / sides
            vertices.append((x + rx * math.cos(a), y + ry * math.sin(a), z))
    faces = []
    for j in range(len(rings) - 1):
        for i in range(sides):
            a = j * sides + i
            b = j * sides + (i + 1) % sides
            faces.append((a, b, b + sides, a + sides))
    if cap:
        faces.append(tuple(reversed(range(sides))))
        faces.append(tuple((len(rings)-1)*sides+i for i in range(sides)))
    return mesh(name, vertices, faces, mat, role, bone, subdiv)


def ellipsoid(name, center, size, mat, role, bone=None):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16, location=center)
    obj = bpy.context.object
    obj.name = name
    obj.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    # Coordinates in armature space before skinning.
    bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)
    obj.data.materials.append(mat)
    obj['wardrobe_role'] = role
    obj['fixed_bone'] = bone or ''
    for p in obj.data.polygons:
        p.use_smooth = True
    PARTS.append(obj)
    return obj


def combine_skin(objects, name):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects: o.select_set(True)
    bpy.context.view_layer.objects.active=objects[0]
    bpy.ops.object.join()
    obj=objects[0]
    obj.name=name
    mod=obj.modifiers.new('Continuous sculpt surface','REMESH')
    mod.mode='VOXEL';mod.voxel_size=.012
    bpy.ops.object.modifier_apply(modifier=mod.name)
    smooth=obj.modifiers.new('Sculpt smoothing','SMOOTH');smooth.factor=.55;smooth.iterations=4
    bpy.ops.object.modifier_apply(modifier=smooth.name)
    for o in objects[1:]: PARTS.remove(o)
    for p in obj.data.polygons: p.use_smooth=True
    return obj


# Base underwear, sleeveless top and short trousers have deliberate seams.
loft('BaseTop',[(0,0,1.0,.25,.17),(0,0,1.1,.23,.16),(0,0,1.18,.225,.151),(0,0,1.32,.285,.18),
 (0,0,1.43,.365,.19),(0,0,1.50,.40,.172),(0,0,1.57,.20,.135),
 (0,0,1.635,.125,.125),(0,0,1.645,.125,.125)],BASE,'base','spine',cap=False,subdiv=1)
loft('BaseShortsHip',[(0,0,.87,.23,.169),(0,0,.96,.253,.18),(0,0,1.035,.25,.173)],BASE,'base','hips')
for side,label in ((-1,'L'),(1,'R')):
    loft('BaseShorts_'+label,[(side*.16,0,.72,.125,.125),(side*.16,0,.79,.139,.14),
      (side*.145,0,.94,.145,.15),(side*.125,0,1.025,.143,.144)],BASE,'base')
    loft('BaseShortHem_'+label,[(side*.16,0,.722,.126,.126),(side*.16,0,.738,.129,.129)],BASE_TRIM,'base',cap=False,subdiv=0)
loft('BaseWaistband',[(0,0,1.0,.26,.18),(0,0,1.067,.254,.178)],BASE_TRIM,'base','hips',cap=False,subdiv=0)


def shoe(name, side, role, high=False):
    label='L' if side<0 else 'R'
    # Toe points forward (+Y in Blender); heel is shorter.
    rings=[(side*.16,.065,.035,.085,.18),(side*.16,.065,.063,.086,.18),
      (side*.16,.06,.1,.081,.168),(side*.16,.025,.15,.066,.089),
      (side*.16,.005,.21 if high else .18,.067,.07)]
    if high:
        rings += [(side*.16,0,.34,.095,.086),(side*.16,0,.44,.095,.082)]
    loft(name+'_'+label,rings,LEATHER,role)
    loft(name+'Sole_'+label,[(side*.16,.067,.018,.087,.18),(side*.16,.067,.045,.088,.183)],BASE,role,bone='foot_'+label,subdiv=0)
    if high:
        loft(name+'Cuff_'+label,[(side*.16,0,.422,.097,.084),(side*.16,0,.447,.097,.084)],LEATHER,role)


for side in [-1,1]: shoe('BaseShoes',side,'base')

# Jacket and sleeves: opaque body coverage removes the hidden anatomy from
# rendering while the cloth envelope and shared weights control silhouette.
loft('UniformTorso',[(0,0,.92,.255,.174),(0,0,1.06,.244,.163),
 (0,0,1.18,.23,.155),(0,0,1.33,.281,.179),(0,0,1.45,.32,.171),
 (0,0,1.52,.26,.14),(0,0,1.585,.106,.102)],ROBE,'uniform')
loft('UniformCollar',[(0,0,1.55,.16,.14),(0,0,1.56,.16,.14),(0,0,1.65,.125,.125),(0,0,1.66,.125,.125)],LINEN,'uniform','spine',cap=False)
for side,label in ((-1,'L'),(1,'R')):
    ellipsoid('UniformShoulder_'+label,(side*.265,0,1.475),(.195,.148,.125),ROBE,'uniform')
    loft('UniformSleeve_'+label,[(side*.32,0,1.5,.145,.137),(side*.405,0,1.43,.143,.132),
      (side*.42,.005,1.27,.127,.119),(side*.42,.012,1.19,.116,.106),
      (side*.42,.018,1.07,.114,.104),(side*.42,.02,.90,.11,.102)],ROBE,'uniform')
    loft('UniformCuff_'+label,[(side*.42,.02,.895,.112,.104),(side*.42,.02,.944,.115,.105)],PANEL,'uniform',cap=False,subdiv=0)
    loft('UniformTrousers_'+label,[(side*.16,0,.29,.084,.083),(side*.16,0,.55,.1,.1),
      (side*.16,0,.79,.143,.146),(side*.145,0,.98,.145,.151)],BASE,'uniform')
    shoe('UniformBoots',side,'uniform',True)
    # Folded lapels from shoulder to waist, separate visible cloth edge.
    path=[(side*.08,.111,1.575),(side*.15,.17,1.46),(side*.1,.19,1.33),(-side*.08,.18,1.09)]
    ribbon=[]
    for x,y,z in path:
        ribbon.extend([(x-.022,y,z),(x+.022,y,z)])
    lapel=mesh('UniformLapel_'+label,ribbon,[(j*2,j*2+1,j*2+3,j*2+2) for j in range(3)],PANEL,'uniform','spine',2)
    thickness=lapel.modifiers.new('Fold thickness','SOLIDIFY');thickness.thickness=.006
    bpy.context.view_layer.objects.active=lapel
    bpy.ops.object.modifier_apply(modifier=thickness.name)
combine_skin([o for o in PARTS if o.name=='UniformTorso' or o.name.startswith('UniformSleeve') or o.name.startswith('UniformShoulder')],'UniformJacket')
loft('UniformBelt',[(0,0,1.025,.251,.173),(0,0,1.09,.245,.168)],LEATHER,'uniform','spine')
ellipsoid('UniformBuckle',(0,.178,1.057),(.045,.012,.03),BRONZE,'uniform','spine')

# Six loose panels, each with a dedicated two-bone chain. The split avoids a
# closed skirt tying both legs together. Fold geometry is visible at game scale.
for panel_index in range(6):
    center=2*math.pi*panel_index/6+math.pi/6
    verts=[];faces=[];rows=18;cols=10
    for j in range(rows):
        t=j/(rows-1)
        z=1.05-.75*t
        radius=.25+.13*t
        for i in range(cols):
            u=i/(cols-1)
            a=center+(u-.5)*.99
            fold=.012*math.cos(u*math.pi*4)*(.3+.7*t)
            verts.append(((radius+fold)*math.cos(a),(radius*.76+fold)*math.sin(a),z+.018*math.cos(u*math.pi*2)*t))
    for j in range(rows-1):
        for i in range(cols-1):
            a=j*cols+i;faces.append((a,a+1,a+1+cols,a+cols))
    obj=mesh('UniformPanel_%d'%panel_index,verts,faces,PANEL if panel_index%3==0 else ROBE,'uniform',subdiv=1)
    obj['panel_index']=panel_index
    # Solidify after skinning is not exported as a live modifier; actual thickness.
    mod=obj.modifiers.new('Cloth edge thickness','SOLIDIFY');mod.thickness=.004
    bpy.context.view_layer.objects.active=obj
    bpy.ops.object.modifier_apply(modifier=mod.name)

# One shared armature. No animation changes gameplay impact times.
arm_data=bpy.data.armatures.new('AdventurerRig')
rig=bpy.data.objects.new('AdventurerRig',arm_data)
bpy.context.collection.objects.link(rig)
bpy.context.view_layer.objects.active=rig
bpy.ops.object.mode_set(mode='EDIT')


def bone(name,head,tail,parent=None):
    b=arm_data.edit_bones.new(name);b.head=head;b.tail=tail
    if parent: b.parent=arm_data.edit_bones[parent]
    BONES[name]=(Vector(head),Vector(tail))


bone('root',(0,0,0),(0,0,.2))
bone('hips',(0,0,.9),(0,0,1.1),'root')
bone('spine',(0,0,1.06),(0,0,1.59),'hips')
bone('head',(0,0,1.64),(0,0,1.95),'spine')
for side,label in ((-1,'L'),(1,'R')):
    bone('upper_arm_'+label,(side*.42,0,1.5),(side*.42,.01,1.2),'spine')
    bone('forearm_'+label,(side*.42,.01,1.2),(side*.42,.02,.91),'upper_arm_'+label)
    bone('hand_'+label,(side*.42,.02,.91),(side*.42,.04,.78),'forearm_'+label)
    bone('thigh_'+label,(side*.16,0,.9),(side*.16,.018,.51),'hips')
    bone('shin_'+label,(side*.16,.018,.51),(side*.16,0,.14),'thigh_'+label)
    bone('foot_'+label,(side*.16,0,.14),(side*.16,.22,.07),'shin_'+label)
for k in range(6):
    a=2*math.pi*k/6+math.pi/6
    bone('cloth_%d_a'%k,(.25*math.cos(a),.19*math.sin(a),1.04),(.32*math.cos(a),.24*math.sin(a),.68),'hips')
    bone('cloth_%d_b'%k,(.32*math.cos(a),.24*math.sin(a),.68),(.38*math.cos(a),.29*math.sin(a),.30),'cloth_%d_a'%k)
bpy.ops.object.mode_set(mode='OBJECT')


# Replace the construction mannequin with anatomically authored CC0 topology.
for obj in list(PARTS):
    if obj['wardrobe_role'] in ['body','always']:
        PARTS.remove(obj);bpy.data.objects.remove(obj,do_unlink=True)
human,IMPORTED_WEIGHTS=build_human(ROOT,BONES,rig,SKIN,HAIR,EYE,IRIS,BASE)
PARTS.extend(human)


def segdist(p,a,b):
    delta=b-a
    t=max(0,min(1,(p-a).dot(delta)/delta.length_squared))
    return (p-a-delta*t).length


for obj in PARTS:
    role=obj['wardrobe_role']
    fixed=obj['fixed_bone']
    groups={n:obj.vertex_groups.new(name=n) for n in BONES}
    for v in obj.data.vertices:
        p=v.co
        if obj.name in IMPORTED_WEIGHTS:
            weights=IMPORTED_WEIGHTS[obj.name][v.index]
        elif fixed:
            weights=[(fixed,1)]
        elif obj.name.startswith(('BaseShorts_','BaseShortHem_','UniformTrousers_')):
            label='R' if p.x>=0 else 'L'
            hip=max(0,min(1,(p.z-.87)/.16))
            weights=[('hips',hip),('thigh_'+label,1-hip)]
        elif obj.name.startswith(('BaseShoes','UniformBoots')):
            label='R' if p.x>=0 else 'L'
            shin=max(0,min(1,(p.z-.13)/.12))
            weights=[('shin_'+label,shin),('foot_'+label,1-shin)]
        elif 'panel_index' in obj:
            k=obj['panel_index'];t=max(0,min(1,(1.04-p.z)/.74))
            top=max(0,1-t*5)
            bottom=max(0,min(1,(t-.32)/.45))
            weights=[('hips',top),('cloth_%d_a'%k,(1-top)*(1-bottom)),('cloth_%d_b'%k,(1-top)*bottom)]
        else:
            # Region limits stop torso and opposite limbs from stealing weights.
            label='R' if p.x>=0 else 'L'
            if abs(p.x)>.30 and p.z>.82:
                candidates=['upper_arm_'+label,'forearm_'+label,'hand_'+label,'spine']
            elif p.z<.96:
                candidates=['thigh_'+label,'shin_'+label,'foot_'+label,'hips']
            else:
                candidates=['hips','spine','upper_arm_'+label] if abs(p.x)>.22 else ['hips','spine']
            ds=sorted([(segdist(p,*BONES[n]),n) for n in candidates])[:2]
            vals=[(n,math.exp(-((d-ds[0][0])/.065)**2)) for d,n in ds]
            total=sum(w for _,w in vals)
            weights=[(n,w/total) for n,w in vals]
        for n,w in weights:
            if w>.0001: groups[n].add([v.index],w,'REPLACE')
    mod=obj.modifiers.new('Shared skeleton','ARMATURE');mod.object=rig
    obj.parent=rig
    # Unwrap to provide repeatable exported woven texture sampling.
    bpy.context.view_layer.objects.active=obj
    bpy.ops.object.select_all(action='DESELECT');obj.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=1.15,island_margin=.015)
    bpy.ops.object.mode_set(mode='OBJECT')

def body_x(x):
    v=abs(x)
    return math.copysign(v*.85 if v<=.24 else .204+(v-.24)*.57,x)

# Slim the old procedural actor proportions while preserving room for its rig.
for obj in PARTS:
    if obj['fixed_bone']=='head' or obj.name in ['HumanHeadHands','HairCrop']:
        # Keep head width while compressing the hands to the arm positions.
        if obj.name=='HumanHeadHands':
            for v in obj.data.vertices:
                if abs(v.co.x)>.25:v.co.x=body_x(v.co.x)
        continue
    for v in obj.data.vertices:
        v.co.x=body_x(v.co.x)
bpy.context.view_layer.objects.active=rig
bpy.ops.object.mode_set(mode='EDIT')
for b in arm_data.edit_bones:
    b.head.x=body_x(b.head.x);b.tail.x=body_x(b.tail.x)
bpy.ops.object.mode_set(mode='OBJECT')

bpy.context.scene['asset']='Adventurer: adapted CC0 anatomy and original wardrobe'
bpy.context.scene['human_acceptance']='pending'
for role in ['always','body','base','uniform']:
    collection=bpy.data.collections.new('Wardrobe_'+role)
    bpy.context.scene.collection.children.link(collection)
    for obj in PARTS:
        if obj['wardrobe_role']!=role:continue
        for old in list(obj.users_collection):old.objects.unlink(obj)
        collection.objects.link(obj)
    if role=='uniform':collection.hide_viewport=True;collection.hide_render=True
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'adventurer.blend'))
# Source retains named pieces. Export copies are grouped by wardrobe role to
# avoid a draw submission for every eye, finger and hair ridge.
copies=[]
for role,name in [('always','HeadAndHands'),('body','BodyCovered'),('base','BaseOutfit'),('uniform','UniformOutfit')]:
    group=[]
    for obj in PARTS:
        if obj['wardrobe_role']!=role: continue
        dup=obj.copy();dup.data=obj.data.copy()
        bpy.context.collection.objects.link(dup);group.append(dup)
    bpy.ops.object.select_all(action='DESELECT')
    for obj in group: obj.select_set(True)
    bpy.context.view_layer.objects.active=group[0]
    if len(group)>1:bpy.ops.object.join()
    joined=group[0];joined.name=name;copies.append(joined)
bpy.ops.object.select_all(action='DESELECT');rig.select_set(True)
for obj in copies: obj.select_set(True)
path=EXPORT/'adventurer.glb'
bpy.ops.export_scene.gltf(filepath=str(path),export_format='GLB',use_selection=True,
    export_skins=True,export_animations=False,export_extras=True,export_yup=True)
report={'source':'art/source/characters/adventurer.blend','glb':'assets/models/characters/adventurer.glb',
 'glb_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'bytes':path.stat().st_size,
 'mesh_count':len(copies),'source_mesh_pieces':len(PARTS),'bones':len(BONES),'vertices':sum(len(o.data.vertices) for o in PARTS),
 'triangles':sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in PARTS),
 'human_acceptance':'pending','textures':'original procedural weave; body anatomy adapted from MakeHuman CC0',
 'anatomy_source_sha256':hashlib.sha256((SOURCE/'vendor/makehuman/base.obj').read_bytes()).hexdigest(),
 'anatomy_source_commit':(SOURCE/'vendor/makehuman/COMMIT.txt').read_text(encoding='utf-8-sig').strip(),
 'roles':{r:[o.name for o in PARTS if o['wardrobe_role']==r] for r in ['always','body','base','uniform']}}
(EVIDENCE/'export_report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print('CHARACTER_EXPORT_OK',json.dumps(report))
