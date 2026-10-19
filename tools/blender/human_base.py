"""Adapt the pinned MakeHuman CC0 anatomy to this character's shared rig.

Only body faces are used; helper geometry and source program code are excluded.
See art/source/characters/vendor/makehuman for provenance and CC0 text.
"""
import math
import bpy
from mathutils import Vector, Matrix


def build(root, target_bones, target_rig, skin, hair, eye, iris, base_cloth):
    path = root/'art/source/characters/vendor/makehuman/base.obj'
    raw=[]; faces=[]; groups={}; current=''
    for line in path.read_text(encoding='utf-8-sig').splitlines():
        row=line.split()
        if not row: continue
        if row[0]=='v': raw.append(Vector(tuple(map(float,row[1:4]))))
        elif row[0]=='g': current=row[1];groups.setdefault(current,set())
        elif row[0]=='f':
            # Y-up -> Z-up swaps two axes, so reverse polygon winding.
            face=tuple(reversed([int(w.split('/')[0])-1 for w in row[1:]]))
            groups[current].update(face)
            if current=='body': faces.append(face)
    scale=2.0/(8.4913+8.1676)
    points=[Vector((p.x*scale,p.z*scale,(p.y+8.1676)*scale)) for p in raw]

    def joint(name):
        ids=groups['joint-'+name]
        return sum((points[i] for i in ids),Vector())/len(ids)

    source={'hips':(joint('pelvis'),joint('spine-3')),
            'spine':(joint('spine-3'),joint('neck')),
            'head':(joint('neck'),joint('head-2'))}
    # Source left/right are anatomical. Existing game rig uses x sign labels.
    for label,mh in [('L','r'),('R','l')]:
        source['upper_arm_'+label]=(joint(mh+'-shoulder'),joint(mh+'-elbow'))
        source['forearm_'+label]=(joint(mh+'-elbow'),joint(mh+'-hand'))
        source['hand_'+label]=(joint(mh+'-hand'),joint(mh+'-finger-3-4'))
        source['thigh_'+label]=(joint(mh+'-upper-leg'),joint(mh+'-knee'))
        source['shin_'+label]=(joint(mh+'-knee'),joint(mh+'-ankle'))
        source['foot_'+label]=(joint(mh+'-ankle'),joint(mh+'-foot-2'))

    # Heat weights on the intact anatomical surface preserve shoulder topology.
    # Apply the source A-pose -> target rest deformation before splitting roles.
    used=sorted(set(i for face in faces for i in face));index={i:j for j,i in enumerate(used)}
    data=bpy.data.meshes.new('AnatomicalRetarget')
    data.from_pydata([points[i] for i in used],[],[tuple(index[i] for i in f) for f in faces]);data.update()
    body=bpy.data.objects.new('AnatomicalRetarget',data);bpy.context.collection.objects.link(body)
    sd=bpy.data.armatures.new('SourcePose');sr=bpy.data.objects.new('SourcePose',sd)
    bpy.context.collection.objects.link(sr);bpy.context.view_layer.objects.active=sr
    bpy.ops.object.mode_set(mode='EDIT')
    parents={'hips':None,'spine':'hips','head':'spine'}
    for label in ['L','R']:
        parents.update({'upper_arm_'+label:'spine','forearm_'+label:'upper_arm_'+label,'hand_'+label:'forearm_'+label,
                        'thigh_'+label:'hips','shin_'+label:'thigh_'+label,'foot_'+label:'shin_'+label})
    for name,(a,b) in source.items():
        bone=sd.edit_bones.new(name);bone.head=a;bone.tail=b
        if parents[name]:bone.parent=sd.edit_bones[parents[name]]
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.select_all(action='DESELECT');body.select_set(True);sr.select_set(True)
    bpy.context.view_layer.objects.active=sr
    bpy.ops.object.parent_set(type='ARMATURE_AUTO')
    for name in source:
        target=target_rig.data.bones[name]
        sr.pose.bones[name].matrix=target.matrix_local @ Matrix.Diagonal((1,target.length/sd.bones[name].length,1,1))
        bpy.context.view_layer.update()
    bpy.context.view_layer.objects.active=body
    bpy.ops.object.modifier_apply(modifier=body.modifiers[0].name)
    head_deform=sr.pose.bones['head'].matrix @ sd.bones['head'].matrix_local.inverted()
    mapped={i:body.data.vertices[j].co.copy() for j,i in enumerate(used)}
    names={group.index:group.name for group in body.vertex_groups}
    weights={i:[(names[g.group],g.weight) for g in body.data.vertices[j].groups] for j,i in enumerate(used)}
    for i in used:
        if not weights[i]:weights[i]=[('head' if mapped[i].z>1.6 else 'spine',1)]
    bpy.data.objects.remove(body,do_unlink=True);bpy.data.objects.remove(sr,do_unlink=True)

    result=[];overrides={}

    def make(name,selected,mat,role,offset=0):
        ids=sorted(set(i for face in selected for i in face))
        ix={old:new for new,old in enumerate(ids)}
        data=bpy.data.meshes.new(name)
        data.from_pydata([mapped[i] for i in ids],[],[tuple(ix[i] for i in f) for f in selected])
        data.update()
        if offset:
            for v in data.vertices:v.co+=v.normal*offset
        obj=bpy.data.objects.new(name,data);bpy.context.collection.objects.link(obj)
        obj.data.materials.append(mat);obj['wardrobe_role']=role;obj['fixed_bone']=''
        for p in data.polygons:p.use_smooth=True
        overrides[name]={ix[i]:weights[i] for i in ids}
        result.append(obj)
        return obj

    head_hands=[];exposed=[];scalp=[]
    for face in faces:
        p=sum((mapped[i] for i in face),Vector())/len(face)
        # Covered anatomy is kept as reference in the source, not rendered below
        # the default underwear. Both outfits retain continuous head and hands.
        original=sum((points[i] for i in face),Vector())/len(face)
        # Keep continuous shoulder/arm skin in the base appearance; the complete
        # covered body is disabled in the uniform appearance.
        always=(p.z>1.67 or (p.z>1.60 and abs(p.x)<.095 and abs(p.y)<.10)) or (abs(original.x)>.48 and original.z<1.31)
        if always:head_hands.append(face)
        elif p.z>.17 and not ((.80<p.z<1.03 and abs(p.x)<.30) or (.71<p.z<=.80 and abs(p.x)<.09)):exposed.append(face)
        if original.z>1.92 or (original.y<-.014 and original.z>1.83):scalp.append(face)
    make('HumanHeadHands',head_hands,skin,'always')
    covered=make('BodyCovered',exposed,skin,'body')
    # Recess the concealed anatomy under the fitted opaque base garments,
    # retaining the original full surface in AnatomyReference for future fitting.
    for v in covered.data.vertices:
        p=v.co
        if 1.0<p.z<1.56 and abs(p.x)<.30:
            p.x*=.80;p.y*=.75
        elif .72<p.z<=1.0 and abs(p.x)<.30:
            center=.16 if p.x>=0 else -.16
            amount=min(1,(p.z-.72)/.06)
            p.x=center+(p.x-center)*(1-.22*amount);p.y*=1-.28*amount
    make('HairCrop',scalp,hair,'always',.003)
    # A hidden full anatomical reference supports fitting future clothes.
    reference=make('AnatomyReference',faces,skin,'reference')
    reference.hide_render=True;reference.hide_set(True)
    result.remove(reference)
    for mh in ['l','r']:
        center=head_deform @ joint(mh+'-eye')
        for suffix,mat,shape,forward in [('Sclera',eye,(.018,.016,.012),0),('Iris',iris,(.006,.002,.006),.015)]:
            bpy.ops.mesh.primitive_uv_sphere_add(segments=24,ring_count=12,location=center+Vector((0,forward,0)))
            obj=bpy.context.object;obj.name='Eye_'+mh+'_'+suffix;obj.scale=shape
            bpy.ops.object.transform_apply(location=True,rotation=False,scale=True)
            obj.data.materials.append(mat);obj['wardrobe_role']='always';obj['fixed_bone']='head'
            for p in obj.data.polygons:p.use_smooth=True
            result.append(obj)
    return result,overrides
