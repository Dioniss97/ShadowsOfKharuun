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
from mathutils.bvhtree import BVHTree

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0,str(Path(__file__).parent))
from human_base import build as build_human
from character_surfaces import skin_atlas, cloth_coordinates, grip_contact
SOURCE = ROOT / 'art/source/characters'
EXPORT = ROOT / 'assets/models/characters'
EVIDENCE = ROOT / 'art/references/character'
for directory in (SOURCE, EXPORT, EVIDENCE):
    directory.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
PARTS = []
BONES = {}


def smooth_noise(size, grid, rng):
    """Small deterministic, smoothly interpolated noise field for packed maps."""
    samples = rng.normal(0, 1, (grid + 1, grid + 1)).astype(np.float32)
    axis = np.linspace(0, grid, size, endpoint=False, dtype=np.float32)
    ix = np.floor(axis).astype(np.int32)
    iy = ix.copy()
    fx = axis - ix
    fy = fx.copy()
    fx = fx * fx * (3 - 2 * fx)
    fy = fy * fy * (3 - 2 * fy)
    x0, x1 = ix, ix + 1
    y0, y1 = iy, iy + 1
    a = samples[y0[:, None], x0[None, :]]
    b = samples[y0[:, None], x1[None, :]]
    c = samples[y1[:, None], x0[None, :]]
    d = samples[y1[:, None], x1[None, :]]
    return ((a * (1 - fx)[None, :] + b * fx[None, :]) * (1 - fy)[:, None]
            + (c * (1 - fx)[None, :] + d * fx[None, :]) * fy[:, None])


def material(name, color, roughness, weave=False, metal=0, skin=False, leather=False):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1)
    bsdf.inputs['Roughness'].default_value = roughness
    bsdf.inputs['Metallic'].default_value = metal
    bsdf.inputs['Specular IOR Level'].default_value = .18 if weave else .28
    if weave or skin or leather:
        n = 512
        yy, xx = np.mgrid[:n, :n]
        seed = sum((i + 1) * ord(c) for i, c in enumerate(name))
        rng = np.random.default_rng(seed)
        broad = smooth_noise(n, 5, rng)
        medium = smooth_noise(n, 25, rng)
        grain = rng.normal(0, 1, (n, n)).astype(np.float32)
        if skin:
            value = broad * .020 + medium * .008 + grain * .0035
            warmth = smooth_noise(n, 11, rng) * .007
        elif leather:
            value = broad * .018 + medium * .010 + grain * .006
            warmth = smooth_noise(n, 18, rng) * .003
        else:
            threads = .002 * (np.sin(xx * 2 * math.pi / 4) + np.sin(yy * 2 * math.pi / 4))
            value = broad * .012 + medium * .005 + grain * .003 + threads
            warmth = smooth_noise(n, 18, rng) * .004
        # Linear pixels; Blender encodes the exported image with its color space.
        pixels = np.ones((n, n, 4), dtype=np.float32)
        pixels[:, :, 0] = np.clip(color[0] * (1 + value + warmth), 0, 1)
        pixels[:, :, 1] = np.clip(color[1] * (1 + value), 0, 1)
        pixels[:, :, 2] = np.clip(color[2] * (1 + value - warmth), 0, 1)
        image = bpy.data.images.new(name + '_surface', width=n, height=n)
        image.pixels.foreach_set(pixels.ravel())
        image.pack()
        tex = mat.node_tree.nodes.new('ShaderNodeTexImage')
        tex.image = image
        mat.node_tree.links.new(tex.outputs['Color'], bsdf.inputs['Base Color'])
        rough = np.clip(roughness + broad * (.045 if skin else .035)
                        + medium * (.018 if weave else .012)
                        + grain * (.010 if weave else .007), .35, .98)
        rough_pixels = np.empty((n, n, 4), dtype=np.float32)
        rough_pixels[:, :, :3] = rough[:, :, None]
        rough_pixels[:, :, 3] = 1
        rough_image = bpy.data.images.new(name + '_roughness', width=n, height=n)
        rough_image.colorspace_settings.name = 'Non-Color'
        rough_image.pixels.foreach_set(rough_pixels.ravel())
        rough_image.pack()
        rough_tex = mat.node_tree.nodes.new('ShaderNodeTexImage')
        rough_tex.image = rough_image
        rough_tex.label = 'Subtle surface roughness variation'
        mat.node_tree.links.new(rough_tex.outputs['Color'], bsdf.inputs['Roughness'])
        if weave or leather:
            height=medium*.025+grain*(.008 if leather else .003)
            if weave:height+=.035*(np.sin(xx*2*math.pi/4)+np.sin(yy*2*math.pi/4))
            dy,dx=np.gradient(height)
            normals=np.stack((-dx*3,-dy*3,np.ones_like(dx)),axis=2)
            normals/=np.linalg.norm(normals,axis=2,keepdims=True)
            normal_pixels=np.ones((n,n,4),dtype=np.float32)
            normal_pixels[:,:,:3]=normals*.5+.5
            normal_image=bpy.data.images.new(name+'_normal',width=n,height=n)
            normal_image.colorspace_settings.name='Non-Color'
            normal_image.pixels.foreach_set(normal_pixels.ravel());normal_image.pack()
            normal_tex=mat.node_tree.nodes.new('ShaderNodeTexImage');normal_tex.image=normal_image
            normal_map=mat.node_tree.nodes.new('ShaderNodeNormalMap');normal_map.inputs['Strength'].default_value=.35
            mat.node_tree.links.new(normal_tex.outputs['Color'],normal_map.inputs['Color'])
            mat.node_tree.links.new(normal_map.outputs['Normal'],bsdf.inputs['Normal'])
    return mat


SKIN = material('Skin_warm_sand', (.44, .285, .205), .66, skin=True)
HAIR = material('Hair_umber', (.035, .022, .017), .9)
EYE = material('Eyes_ivory', (.55, .48, .39), .3)
IRIS = material('Iris_dark_hazel', (.055, .036, .016), .35)
BASE = material('Base_woven_charcoal', (.065, .07, .073), .9, True)
BASE_TRIM = material('Base_seams', (.13, .125, .112), .85)
ROBE = material('Robe_graphite', (.14, .155, .175), .88, True)
PANEL = material('Robe_slate', (.24, .27, .30), .86, True)
LINEN = material('Linen_warm_grey', (.36, .335, .285), .92, True)
LEATHER = material('Leather_dark', (.061, .039, .024), .66, leather=True)
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
        rings=[(x,y*.92,z,rx*.90,ry*.92) for x,y,z,rx,ry in rings]
        rings += [(side*.16,0,.34,.095,.086),(side*.16,0,.44,.105,.10)]
    if not high:
        rings=[(x,y*.85,z,rx*.80,ry*.85) for x,y,z,rx,ry in rings]
        rings[-2]=(side*.16,-.005,.15,.0528,.085)
        rings[-1]=(side*.16,-.012,.19,.050,.072)
        rings.append((side*.16,-.005,.245,.050,.074))
    loft(name+'_'+label,rings,LEATHER,role,cap=False)
    loft(name+'Sole_'+label,[(side*.16,.067*(.92 if high else .85),.018,.087*(.90 if high else .80),.18*(.92 if high else .85)),
                           (side*.16,.067*(.92 if high else .85),.045,.088*(.90 if high else .80),.183*(.92 if high else .85))],BASE,role,bone='foot_'+label,subdiv=0)
    if high:
        loft(name+'Cuff_'+label,[(side*.16,0,.422,.107,.103),(side*.16,0,.447,.107,.103)],LEATHER,role)


for side in [-1,1]: shoe('BaseShoes',side,'base')

# Jacket and sleeves: opaque body coverage removes the hidden anatomy from
# rendering while the cloth envelope and shared weights control silhouette.
loft('UniformTorso',[(0,0,.92,.255,.174),(0,0,1.06,.244,.163),
 (0,0,1.18,.23,.155),(0,0,1.33,.281,.179),(0,0,1.45,.32,.171),
 (0,0,1.52,.26,.14),(0,0,1.585,.106,.102)],ROBE,'uniform')
loft('UniformCollar',[(0,0,1.545,.15,.135),(0,0,1.56,.15,.135),(0,0,1.615,.132,.126),(0,0,1.625,.13,.125)],LINEN,'uniform','spine',cap=False)
for side,label in ((-1,'L'),(1,'R')):
    ellipsoid('UniformShoulder_'+label,(side*.278,0,1.474),(.103,.092,.074),ROBE,'uniform')
    # Fill the cloth bridge between the narrow torso and sleeve inner wall.
    # Without this gusset the hidden body leaves a visible hole under the arm.
    ellipsoid('UniformAxilla_'+label,(side*.30,0,1.315),(.083,.09,.095),ROBE,'uniform')
    loft('UniformSleeve_'+label,[(side*.30,0,1.49,.103,.106),(side*.355,0,1.445,.116,.112),
      (side*.402,.002,1.365,.105,.104),(side*.418,.005,1.27,.096,.097),
      (side*.415,.01,1.205,.092,.094),(side*.405,.014,1.12,.086,.09),
      (side*.398,.018,1.01,.081,.086),(side*.397,.02,.93,.078,.084)],ROBE,'uniform')
    loft('UniformCuff_'+label,[(side*.42,.02,.935,.057,.052),(side*.42,.02,.975,.060,.055),
      (side*.42,.02,.975,.052,.047),(side*.42,.02,.935,.049,.044),(side*.42,.02,.935,.057,.052)],PANEL,'uniform','forearm_'+label,cap=False,subdiv=0)
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
combine_skin([o for o in PARTS if o.name=='UniformTorso' or o.name.startswith(('UniformSleeve','UniformShoulder','UniformAxilla'))],'UniformJacket')
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
            a=center+(u-.5)*1.08
            fold=.009*math.cos(u*math.pi*4)*(.3+.7*t)
            hem_scallop=.006*math.sin(math.pi*u)**2*t**3
            verts.append(((radius+fold)*math.cos(a),(radius*.76+fold)*math.sin(a),z-hem_scallop))
    for j in range(rows-1):
        for i in range(cols-1):
            a=j*cols+i;faces.append((a,a+1,a+1+cols,a+cols))
    obj=mesh('UniformPanel_%d'%panel_index,verts,faces,PANEL if panel_index%3==0 else ROBE,'uniform',subdiv=1)
    obj['panel_index']=panel_index
    # Solidify after skinning is not exported as a live modifier; actual thickness.
    mod=obj.modifiers.new('Cloth edge thickness','SOLIDIFY');mod.thickness=.004
    bpy.context.view_layer.objects.active=obj
    bpy.ops.object.modifier_apply(modifier=mod.name)

# A separate back mantle extends the silhouette from shoulders to calves.
# Its five broad pleats remain legible at game distance. Nine vertical bone
# chains provide live secondary motion; the shoulders stay attached to spine.
cape_rows=27;cape_cols=17;cape_chains=9
def cape_surface(t,u):
    half_width=.155+.125*t
    x=u*half_width*2
    pleat=.012*math.cos(u*math.pi*10)*(.35+.65*t)
    # Keep the lower mantle behind the skirt's .29m rear envelope. Body
    # capsules do not provide cape-to-skirt self collision.
    y=-.18-.07*math.sin(math.pi*t)-.015*t-.16*t*t-pleat
    z=1.535-1.23*t-.012*(.5+.5*math.cos(u*math.pi*10))*t**4
    return (x,y,z)

cape_verts=[];cape_faces=[]
for j in range(cape_rows):
    t=j/(cape_rows-1)
    for i in range(cape_cols):
        u=i/(cape_cols-1)-.5
        cape_verts.append(cape_surface(t,u))
for j in range(cape_rows-1):
    for i in range(cape_cols-1):
        a=j*cape_cols+i
        cape_faces.append((a,a+cape_cols,a+cape_cols+1,a+1))
cape=mesh('UniformCape',cape_verts,cape_faces,PANEL,'uniform')
cape['cape_cloth']=True
cape.data.materials.append(LINEN)
cape_solid=cape.modifiers.new('Woven edge thickness','SOLIDIFY')
cape_solid.thickness=.008;cape_solid.material_offset=1
bpy.context.view_layer.objects.active=cape
bpy.ops.object.modifier_apply(modifier=cape_solid.name)

hem_verts=[];hem_faces=[]
for t in [.978,1.0]:
    for i in range(cape_cols):
        u=i/(cape_cols-1)-.5
        x,y,z=cape_surface(t,u)
        hem_verts.append((x,y-.002,z+.001))
for i in range(cape_cols-1):hem_faces.append((i,i+1,i+1+cape_cols,i+cape_cols))
hem=mesh('UniformCapeHem',hem_verts,hem_faces,LINEN,'uniform')
hem['cape_cloth']=True
hem_solid=hem.modifiers.new('Hem binding thickness','SOLIDIFY');hem_solid.thickness=.005
bpy.context.view_layer.objects.active=hem
bpy.ops.object.modifier_apply(modifier=hem_solid.name)
ellipsoid('UniformCapeClasp',(0,-.155,1.515),(.041,.012,.032),BRONZE,'uniform','spine')

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
bone('head',(0,0,1.615),(0,0,1.925),'spine')
for side,label in ((-1,'L'),(1,'R')):
    bone('upper_arm_'+label,(side*.42,0,1.5),(side*.42,.01,1.2),'spine')
    bone('forearm_'+label,(side*.42,.01,1.2),(side*.42,.02,.91),'upper_arm_'+label)
    bone('hand_'+label,(side*.42,.02,.91),(side*.42,.04,.74),'forearm_'+label)
    bone('thigh_'+label,(side*.16,0,.9),(side*.16,.018,.51),'hips')
    bone('shin_'+label,(side*.16,.018,.51),(side*.16,0,.14),'thigh_'+label)
    bone('foot_'+label,(side*.16,0,.14),(side*.16,.22,.07),'shin_'+label)
for k in range(6):
    a=2*math.pi*k/6+math.pi/6
    bone('cloth_%d_a'%k,(.25*math.cos(a),.19*math.sin(a),1.04),(.32*math.cos(a),.24*math.sin(a),.68),'hips')
    bone('cloth_%d_b'%k,(.32*math.cos(a),.24*math.sin(a),.68),(.38*math.cos(a),.29*math.sin(a),.30),'cloth_%d_a'%k)
for k in range(cape_chains):
    x=((k/(cape_chains-1))-.5)*.33
    bone('cape_%d_a'%k,(x,-.145,1.53),(x,-.27,1.06),'spine')
    bone('cape_%d_b'%k,(x,-.27,1.06),(x,-.34,.57),'cape_%d_a'%k)
bpy.ops.object.mode_set(mode='OBJECT')


# Replace the construction mannequin with anatomically authored CC0 topology.
for obj in list(PARTS):
    if obj['wardrobe_role'] in ['body','always'] or obj.name.startswith(('BaseTop','BaseShorts','BaseShortHem','BaseWaistband','UniformJacket','UniformCollar','UniformTrousers','UniformBelt')):
        PARTS.remove(obj);bpy.data.objects.remove(obj,do_unlink=True)
human,IMPORTED_WEIGHTS=build_human(ROOT,BONES,rig,SKIN,HAIR,EYE,IRIS,BASE,BASE_TRIM,ROBE,LEATHER)
PARTS.extend(human)


def surface_tree(obj):
    obj.data.update();obj.data.calc_loop_triangles()
    triangles=[tuple(t.vertices) for t in obj.data.loop_triangles]
    return BVHTree.FromPolygons([v.co for v in obj.data.vertices],triangles,all_triangles=True),triangles


def surface_skin(obj,triangles,index,point):
    ids=triangles[index];a,b,c=(obj.data.vertices[i].co for i in ids)
    ab,ac,ap=b-a,c-a,point-a
    denom=ab.dot(ab)*ac.dot(ac)-ab.dot(ac)**2
    if abs(denom)<1e-12:return IMPORTED_WEIGHTS[obj.name][ids[0]]
    v=(ac.dot(ac)*ap.dot(ab)-ab.dot(ac)*ap.dot(ac))/denom
    w=(ab.dot(ab)*ap.dot(ac)-ab.dot(ac)*ap.dot(ab))/denom
    merged={}
    for vertex,factor in zip(ids,[1-v-w,v,w]):
        for name,weight in IMPORTED_WEIGHTS[obj.name][vertex]:merged[name]=merged.get(name,0)+weight*factor
    return [(name,value) for name,value in merged.items() if value>.00001]


# Fit the existing trims and cloth anchors to the new continuous garments.
jacket=next(o for o in PARTS if o.name=='UniformJacket')
belt=next(o for o in PARTS if o.name=='UniformBelt')
jacket_tree,jacket_triangles=surface_tree(jacket)
belt_tree,belt_triangles=surface_tree(belt)
for obj in PARTS:
    if obj.name.startswith('UniformLapel_'):
        transferred={}
        count=len(obj.data.vertices)//2
        for i in range(count):
            vertex=obj.data.vertices[i]
            hit,normal,index,distance=jacket_tree.ray_cast(Vector((vertex.co.x,.6,vertex.co.z)),Vector((0,-1,0)))
            if hit is None:
                transferred[i]=[('spine',1)];transferred[i+count]=[('spine',1)];continue
            lift=.008+(.007*max(0,1-abs(vertex.co.x)/.07) if obj.name.endswith('_L') else 0)
            shift=hit+normal*lift-vertex.co
            obj.data.vertices[i].co+=shift;obj.data.vertices[i+count].co+=shift
            values=surface_skin(jacket,jacket_triangles,index,hit)
            transferred[i]=values;transferred[i+count]=values
        IMPORTED_WEIGHTS[obj.name]=transferred
    elif obj.name=='UniformBuckle':
        hit,normal,index,distance=belt_tree.ray_cast(Vector((0,.6,1.057)),Vector((0,-1,0)))
        if hit is not None:
            centre_y=(min(v.co.y for v in obj.data.vertices)+max(v.co.y for v in obj.data.vertices))/2
            for vertex in obj.data.vertices:vertex.co.y+=hit.y+.014-centre_y
            IMPORTED_WEIGHTS[obj.name]={v.index:surface_skin(belt,belt_triangles,index,hit) for v in obj.data.vertices}
    elif obj.name.startswith('UniformPanel_'):
        count=len(obj.data.vertices)//2
        for i in range(count):
            p=obj.data.vertices[i].co
            t=max(0,min(1,(1.05-p.z)/.11))
            if t>=1:continue
            direction=Vector((p.x,p.y,0)).normalized()
            hit,normal,index,distance=belt_tree.ray_cast(direction*.6+Vector((0,0,1.057)),-direction)
            if hit is None:continue
            target=Vector((hit.x,hit.y,p.z))-direction*.005
            shift=(target-p)*(1-t)
            obj.data.vertices[i].co+=shift;obj.data.vertices[i+count].co+=shift
    elif obj.name=='UniformCape':
        count=len(obj.data.vertices)//2
        for i in range(count):
            p=obj.data.vertices[i].co
            t=max(0,min(1,(1.535-p.z)/.25))
            if t>=1:continue
            hit,normal,index,distance=jacket_tree.ray_cast(Vector((p.x,-.6,p.z)),Vector((0,1,0)))
            if hit is None:continue
            shift=(hit+normal*.008-p)*(1-t)
            obj.data.vertices[i].co+=shift;obj.data.vertices[i+count].co+=shift

cape=next(o for o in PARTS if o.name=='UniformCape')
cape_tree,_cape_triangles=surface_tree(cape)
clasp=next(o for o in PARTS if o.name=='UniformCapeClasp')
centre_z=sum(v.co.z for v in clasp.data.vertices)/len(clasp.data.vertices)
hit,normal,index,distance=cape_tree.ray_cast(Vector((0,-.6,centre_z)),Vector((0,1,0)))
if hit is not None:
    centre_y=(min(v.co.y for v in clasp.data.vertices)+max(v.co.y for v in clasp.data.vertices))/2
    for vertex in clasp.data.vertices:vertex.co.y+=hit.y-.009-centre_y


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
            shin=max(0,min(1,(p.z-.10)/.08))
            weights=[('shin_'+label,shin),('foot_'+label,1-shin)]
        elif 'panel_index' in obj:
            k=obj['panel_index'];t=max(0,min(1,(1.04-p.z)/.74))
            top=max(0,1-t*5)
            bottom=max(0,min(1,(t-.32)/.45))
            weights=[('hips',top),('cloth_%d_a'%k,(1-top)*(1-bottom)),('cloth_%d_b'%k,(1-top)*bottom)]
        elif obj.get('cape_cloth',False):
            columns=cape_cols
            row_width=columns
            base_vertex_count=cape_rows*cape_cols if obj.name=='UniformCape' else cape_cols*2
            # Solidify duplicates the original surface in the same vertex order.
            # Map both faces back to their source row so the shell stays skinned.
            index=v.index % base_vertex_count
            row=index//row_width
            col=index%row_width
            u=col/(columns-1)-.5
            t=row/(cape_rows-1) if obj.name=='UniformCape' else .978+.022*(row/(2-1))
            across=(u+.5)*(cape_chains-1)
            k0=int(math.floor(across));k1=min(cape_chains-1,k0+1);blend_x=across-k0
            blend_z=max(0,min(1,(t-.20)/.68))
            weights=[('cape_%d_a'%k0,(1-blend_x)*(1-blend_z)),('cape_%d_a'%k1,blend_x*(1-blend_z)),
                     ('cape_%d_b'%k0,(1-blend_x)*blend_z),('cape_%d_b'%k1,blend_x*blend_z)]
            # The clasp and first row share a rigid spine anchor. Fade into
            # secondary motion over the next 22cm, before lower-chain blending.
            fade=max(0,min(1,(t-.02)/.16));fade=fade*fade*(3-2*fade)
            weights=[(name,weight*fade) for name,weight in weights]+[('spine',1-fade)]
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
    if obj.name in ['HumanHands','UniformGloves']:
        # The authored topology carries the silhouette; one subdivision softens
        # palm/finger facets and interpolates the joint weights before skinning.
        bm=bmesh.new();bm.from_mesh(obj.data)
        boundary={tuple(sorted((e.verts[0].index,e.verts[1].index))) for e in bm.edges if e.is_boundary}
        bm.free()
        crease=obj.data.attributes.new('crease_edge','FLOAT','EDGE')
        corner=obj.data.attributes.new('crease_vert','FLOAT','POINT')
        for edge in obj.data.edges:
            if tuple(sorted(edge.vertices)) in boundary:
                crease.data[edge.index].value=1.0
                for index in edge.vertices:corner.data[index].value=1.0
        bpy.context.view_layer.objects.active=obj
        if obj.name=='UniformGloves':
            soften=obj.modifiers.new('Leather bridges nail detail','SMOOTH');soften.factor=.25;soften.iterations=2
            bpy.ops.object.modifier_apply(modifier=soften.name)
        surface=obj.modifiers.new('Hand surface continuity','SUBSURF');surface.levels=1
        bpy.ops.object.modifier_apply(modifier=surface.name)
    # glTF's four skin influences are chosen explicitly, including interpolated
    # subdivision weights; no exporter-dependent pruning at finger webbing.
    for vertex in obj.data.vertices:
        influences=sorted([(g.group,g.weight) for g in vertex.groups],key=lambda item:item[1],reverse=True)
        if not influences:continue
        keep=influences[:4];total=sum(weight for _,weight in keep)
        for group,_ in influences[4:]:obj.vertex_groups[group].remove([vertex.index])
        for group,weight in keep:obj.vertex_groups[group].add([vertex.index],weight/total,'REPLACE')
    mod=obj.modifiers.new('Shared skeleton','ARMATURE');mod.object=rig
    obj.parent=rig
    # Preserve the original anatomical atlas across visibility boundaries.
    # Cloth is unwrapped separately below with a common physical weave scale.
    if not obj.data.uv_layers:
        bpy.context.view_layer.objects.active=obj
        bpy.ops.object.select_all(action='DESELECT');obj.select_set(True)
        bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT')
        bpy.ops.uv.smart_project(angle_limit=1.15,island_margin=.015)
        bpy.ops.object.mode_set(mode='OBJECT')

def body_x(x,z=None):
    v=abs(x)
    outer_scale=.57
    if z is not None:
        shoulder=max(0,min(1,(z-1.28)/.12,(1.58-z)/.12))
        outer_scale-=.08*shoulder
    compressed=math.copysign(v*.85 if v<=.24 else .204+(v-.24)*outer_scale,x)
    if z is None:return compressed
    neck=max(0,min(1,(z-1.52)/.04))*max(0,min(1,(.30-v)/.08))
    neck=neck*neck*(3-2*neck)
    return compressed*(1-neck)+x*neck


def arm_x(x,z):
    # Restore the anatomical cross-section around the existing arm centreline.
    # Fade at the wrist and deltoid; the torso keeps its approved proportions.
    lower=max(0,min(1,(z-.96)/.14));lower=lower*lower*(3-2*lower)
    upper=max(0,min(1,(1.57-z)/.15));upper=upper*upper*(3-2*upper)
    centre=math.copysign(.42,x)
    corrected=body_x(centre,z)+(x-centre)*.95
    return body_x(x,z)*(1-lower*upper)+corrected*lower*upper


def leg_x(x,z):
    if abs(x)<.015:return body_x(x,z)
    upper=max(0,min(1,(.88-z)/.12));upper=upper*upper*(3-2*upper)
    lower=max(0,min(1,(z-.08)/.08));lower=lower*lower*(3-2*lower)
    corrected=math.copysign(max(.012,.136+(abs(x)-.16)*.98),x)
    return body_x(x,z)*(1-upper*lower)+corrected*upper*lower


def hand_x(x,z):
    # Shift the hand to the gameplay wrist without flattening its cross-section
    # by the torso's 0.57 width factor. Blend only through the wrist, so this
    # pass does not alter the pending arm/torso work.
    t=max(0,min(1,(.98-z)/.10))
    t=t*t*(3-2*t)
    centered=math.copysign(.3066,x)+(x-math.copysign(.42,x))*.94
    return arm_x(x,z)*(1-t)+centered*t

# Slim the old procedural actor proportions while preserving room for its rig.
for obj in PARTS:
    if obj['fixed_bone']=='head' or obj.name in ['HumanHead','HumanHands','UniformGloves','HairCrop']:
        # Keep head width and translate hands without flattening their section.
        if obj.name in ['HumanHands','UniformGloves']:
            for v in obj.data.vertices:
                if abs(v.co.x)>.25:v.co.x=hand_x(v.co.x,v.co.z)
        elif obj.name=='HumanHead':
            for v in obj.data.vertices:
                if v.co.z<1.58:v.co.x=body_x(v.co.x,v.co.z)
        continue
    for v in obj.data.vertices:
        original=v.co.copy()
        v.co.x=body_x(original.x,original.z)
        if obj.name in ['BodyCovered','BaseTop','UniformJacket','UniformCollar'] or obj.name.startswith('UniformCuff_'):
            amount=sum(g.weight for g in v.groups if obj.vertex_groups[g.group].name.startswith(('upper_arm_','forearm_')))
            amount=max(0,min(1,(amount-.25)/.60));amount=amount*amount*(3-2*amount)
            v.co.x=v.co.x*(1-amount)+arm_x(original.x,original.z)*amount
        if obj.name=='BodyCovered' or obj.name.startswith(('BaseShorts','BaseShortHem','BaseWaistband','UniformTrousers')):
            amount=sum(g.weight for g in v.groups if obj.vertex_groups[g.group].name.startswith(('thigh_','shin_','foot_')))
            amount=max(0,min(1,(amount-.25)/.60));amount=amount*amount*(3-2*amount)
            v.co.x=v.co.x*(1-amount)+leg_x(original.x,original.z)*amount
bpy.context.view_layer.objects.active=rig
bpy.ops.object.mode_set(mode='EDIT')
for b in arm_data.edit_bones:
    warp=hand_x if b.name.startswith(('hand_','finger_')) else body_x
    b.head.x=warp(b.head.x,b.head.z);b.tail.x=warp(b.tail.x,b.tail.z)
bpy.ops.object.mode_set(mode='OBJECT')

# Both appearance roles meet on the same forearm loop. Give coincident seam
# vertices a common area-weighted normal, while keeping body visibility separate.
skin_parts=[o for o in PARTS if o.name in ['BodyCovered','HumanHands','HumanHead']]
seam={}
for obj in skin_parts:
    obj.data.update()
    bm=bmesh.new();bm.from_mesh(obj.data)
    boundary={v.index for e in bm.edges if e.is_boundary for v in e.verts}
    bm.free()
    for vertex in obj.data.vertices:
        if vertex.index in boundary:
            key=tuple(round(value,5) for value in vertex.co)
            seam.setdefault(key,[]).append((obj,vertex.index))
normals={obj.name:[v.normal.copy() for v in obj.data.vertices] for obj in skin_parts}
for members in seam.values():
    if len(members)<2 or len({obj.name for obj,_ in members})<2:continue
    normal=Vector()
    for obj,index in members:
        for polygon in obj.data.polygons:
            if index in polygon.vertices:normal+=polygon.normal*polygon.area
    normal.normalize()
    for obj,index in members:normals[obj.name][index]=normal
for obj in skin_parts:
    obj.data.normals_split_custom_set_from_vertices(normals[obj.name])
    # All skin roles preserve the same authored anatomical UV atlas.

grip_contact(PARTS,SOURCE/'grip_contact_fit.json')
skin_atlas(SKIN,PARTS)
cloth_coordinates(PARTS)
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
for role,name in [('always','HeadVisible'),('body','BodyCovered'),('base','BaseOutfit'),('uniform','UniformOutfit')]:
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
  'human_acceptance':'pending','textures':'original 1024x1024 anatomical skin color/roughness/normal atlas; 512x512 cloth/leather maps with shared physical weave scale; anatomy and UV layout adapted from pinned MakeHuman CC0',
 'anatomy_source_sha256':hashlib.sha256((SOURCE/'vendor/makehuman/base.obj').read_bytes()).hexdigest(),
 'anatomy_source_commit':(SOURCE/'vendor/makehuman/COMMIT.txt').read_text(encoding='utf-8-sig').strip(),
 'roles':{r:[o.name for o in PARTS if o['wardrobe_role']==r] for r in ['always','body','base','uniform']}}
(EVIDENCE/'export_report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print('CHARACTER_EXPORT_OK',json.dumps(report))
