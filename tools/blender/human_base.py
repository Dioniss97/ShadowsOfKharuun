"""Adapt the pinned MakeHuman CC0 anatomy to this character's shared rig.

Only body faces are used; helper geometry and source program code are excluded.
See art/source/characters/vendor/makehuman for provenance and CC0 text.
"""
import math
import bpy
import bmesh
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree


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

    # Moderate the paired chest protrusion into a broad pectoral plane, blending
    # into ribs and clavicles. This changes the production body, not its identity.
    for p in mapped.values():
        if p.y<=0 or abs(p.x)>=.32:continue
        t=max(0,min(1,(p.z-1.20)/.10,(1.58-p.z)/.08))
        t=t*t*(3-2*t)
        cap=.138*math.sqrt(max(0,1-(p.x/.34)**2))
        p.y=min(p.y,p.y*(1-t)+cap*t)

    # The source already contains authored finger loops and joint markers.
    # Retarget those markers with the hand frame, rather than approximating
    # fingers with independent primitives or letting one rigid hand bone bend them.
    finger_chains={}
    for label,mh in [('L','r'),('R','l')]:
        hand_name='hand_'+label
        hand_frame=sr.pose.bones[hand_name].matrix @ sd.bones[hand_name].matrix_local.inverted()
        chains={f:[joint('%s-finger-%d-%d'%(mh,f,j)) for j in range(1,5)] for f in range(1,6)}
        palm_normal=(chains[2][0]-chains[5][0]).cross(chains[3][3]-chains[3][0]).normalized()
        finger_chains[label]=(chains,hand_frame,palm_normal)

    bpy.context.view_layer.objects.active=target_rig
    bpy.ops.object.mode_set(mode='EDIT')
    for label,(chains,frame,palm_normal) in finger_chains.items():
        for finger,chain in chains.items():
            for k in range(3):
                name='finger_%s_%d_%d'%(label,finger,k)
                b=target_rig.data.edit_bones.new(name)
                b.head=frame @ chain[k];b.tail=frame @ chain[k+1]
                b.parent=target_rig.data.edit_bones['hand_'+label if k==0 else 'finger_%s_%d_%d'%(label,finger,k-1)]
                b.align_roll((frame.to_3x3() @ palm_normal).normalized())
                target_bones[name]=(b.head.copy(),b.tail.copy())
    bpy.ops.object.mode_set(mode='OBJECT')

    for i in used:
        original_weights=dict(weights[i])
        for label,(chains,frame,palm_normal) in finger_chains.items():
            hand_name='hand_'+label
            hand_weight=original_weights.get(hand_name,0)
            if hand_weight<.15:continue
            candidates=[]
            for finger,chain in chains.items():
                root_direction=(chain[1]-chain[0]).normalized()
                root_distance=(points[i]-chain[0]).dot(root_direction)
                if root_distance<-.008:continue
                for k in range(3):
                    delta=chain[k+1]-chain[k]
                    raw_t=(points[i]-chain[k]).dot(delta)/delta.length_squared
                    t=max(0,min(1,raw_t))
                    distance=(points[i]-chain[k]-delta*t).length
                    candidates.append((distance,finger,k,t,root_distance))
            if not candidates:continue
            distance,finger,k,t,root_distance=min(candidates)
            if distance>(.022 if finger==1 else .017):continue
            amount=max(0,min(1,(root_distance+.006)/.018))
            amount=amount*amount*(3-2*amount)
            if amount<=0:continue
            influence=[(k,1.0)]
            if t<.25 and k>0:influence=[(k-1,.5*(1-t/.25)),(k,.5+.5*t/.25)]
            elif t>.75 and k<2:influence=[(k,1-.5*(t-.75)/.25),(k+1,.5*(t-.75)/.25)]
            original_weights[hand_name]=hand_weight*(1-amount)
            for segment,factor in influence:
                name='finger_%s_%d_%d'%(label,finger,segment)
                original_weights[name]=hand_weight*amount*factor
        weights[i]=[(name,value) for name,value in original_weights.items() if value>.00001]

    # Soften the hand/finger transitions over the authored edge loops. This
    # keeps the MCP webbing attached to the palm when the grip closes.
    neighbours={i:set() for i in used}
    for face in faces:
        for a,b in zip(face,face[1:]+face[:1]):
            neighbours[a].add(b);neighbours[b].add(a)
    hand_ids=[i for i in used if sum(w for name,w in weights[i] if name.startswith(('hand_','finger_')))>.5]
    for _ in range(3):
        updates={}
        for i in hand_ids:
            merged={name:w*.65 for name,w in weights[i]}
            for neighbour in neighbours[i]:
                for name,w in weights[neighbour]:
                    merged[name]=merged.get(name,0)+w*.35/len(neighbours[i])
            top=sorted(merged.items(),key=lambda item:item[1],reverse=True)[:4]
            total=sum(w for _,w in top)
            updates[i]=[(name,w/total) for name,w in top]
        weights.update(updates)
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

    head_faces=[];hand_faces=[];exposed=[];scalp=[]
    for face in faces:
        p=sum((mapped[i] for i in face),Vector())/len(face)
        # Covered anatomy is kept as reference in the source, not rendered below
        # the default underwear. Both outfits retain continuous head and hands.
        original=sum((points[i] for i in face),Vector())/len(face)
        # Keep continuous shoulder/arm skin in the base appearance; the complete
        # covered body is disabled in the uniform appearance.
        head_weight=sum(dict(weights[i]).get('head',0) for i in face)/len(face)
        is_head=head_weight>.55 and p.z>1.50
        # Select in the retargeted limb space. The old source-X threshold cut
        # across the inward-pointing thumb and split it between wardrobe roles.
        # Keep the seam up the forearm, outside the wrist correction envelope.
        is_hand=abs(p.x)>.30 and p.z<1.06
        if is_head:head_faces.append(face)
        elif is_hand:hand_faces.append(face)
        elif p.z>.20 and not ((.80<p.z<1.03 and abs(p.x)<.30) or (.71<p.z<=.80 and abs(p.x)<.09)):exposed.append(face)
        if original.z>1.92 or (original.y<-.014 and original.z>1.83):scalp.append(face)
    make('HumanHead',head_faces,skin,'always')
    make('HumanHands',hand_faces,skin,'always')
    covered=make('BodyCovered',exposed,skin,'body')
    # Recess the concealed anatomy under the fitted opaque base garments,
    # retaining the original full surface in AnatomyReference for future fitting.
    for v in covered.data.vertices:
        p=v.co
        dominant=max(overrides['BodyCovered'][v.index],key=lambda entry:entry[1])[0]
        if dominant not in ['hips','spine']:continue
        if .72<p.z<=1.0 and abs(p.x)<.30:
            center=.16 if p.x>=0 else -.16
            amount=min(1,(p.z-.72)/.06)
            p.x=center+(p.x-center)*(1-.22*amount);p.y*=1-.28*amount
    make('HairCrop',scalp,hair,'always',.003)
    # A hidden full anatomical reference supports fitting future clothes.
    reference=make('AnatomyReference',faces,skin,'reference')
    reference.hide_render=True;reference.hide_set(True)
    result.remove(reference)

    # Fit a sleeveless base garment to the intact anatomy. Clip along continuous
    # scalar fields, interpolating both coordinates and skin weights at each cut;
    # selecting whole faces would leave a visibly jagged edge around the arms.
    reference.data.update()
    source_normals={i:reference.data.vertices[j].normal.copy() for j,i in enumerate(used)}
    garment_fields=[lambda v:v['p'].z-1.01,lambda v:1.64-v['p'].z,
                    lambda v:(v['p'].x/.13)**2+(v['p'].y/.13)**2+((v['p'].z-1.70)/.25)**2-1,
                    lambda v:sum(v['w'].get(name,0) for name in ['spine','hips','head'])-.40]
    def mix(a,b,t):
        keys=set(a['w'])|set(b['w'])
        return {'p':a['p'].lerp(b['p'],t),'n':a['n'].lerp(b['n'],t).normalized(),
                'w':{key:a['w'].get(key,0)*(1-t)+b['w'].get(key,0)*t for key in keys}}
    def clip(poly,field):
        out=[]
        for a,b in zip(poly,poly[1:]+poly[:1]):
            fa,fb=field(a),field(b)
            if fa>=0:out.append(a)
            if (fa>=0)!=(fb>=0):out.append(mix(a,b,fa/(fa-fb)))
        return out
    garment_vertices=[];garment_faces=[];garment_weights=[];lookup={}
    for face in faces:
        poly=[{'p':mapped[i],'n':source_normals[i],'w':dict(weights[i])} for i in face]
        for field in garment_fields:
            if not poly:break
            poly=clip(poly,field)
        if len(poly)<3:continue
        indices=[]
        for point in poly:
            key=tuple(round(v,6) for v in point['p'])
            if key not in lookup:
                lookup[key]=len(garment_vertices)
                garment_vertices.append(point['p']+point['n']*.006)
                garment_weights.append([(name,value) for name,value in point['w'].items() if value>.00001])
            indices.append(lookup[key])
        if len(set(indices))>=3:garment_faces.append(indices)
    # Scalar cuts may also catch a tiny disconnected patch near the jaw. Keep
    # the torso component only; it is the garment's single connected surface.
    adjacency={i:set() for i in range(len(garment_vertices))}
    for face in garment_faces:
        for a,b in zip(face,face[1:]+face[:1]):adjacency[a].add(b);adjacency[b].add(a)
    remaining=set(adjacency);components=[]
    while remaining:
        stack=[remaining.pop()];component=set(stack)
        while stack:
            for neighbour in adjacency[stack.pop()]:
                if neighbour in remaining:
                    remaining.remove(neighbour);component.add(neighbour);stack.append(neighbour)
        components.append(component)
    component=max(components,key=len);chosen=sorted(component);remap={old:new for new,old in enumerate(chosen)}
    garment_faces=[[remap[i] for i in face] for face in garment_faces if all(i in component for i in face)]
    garment_vertices=[garment_vertices[i] for i in chosen];garment_weights=[garment_weights[i] for i in chosen]
    data=bpy.data.meshes.new('FittedBaseTop')
    data.from_pydata(garment_vertices,[],garment_faces);data.update()
    top=bpy.data.objects.new('BaseTop',data);bpy.context.collection.objects.link(top)
    data.materials.append(base_cloth);top['wardrobe_role']='base';top['fixed_bone']=''
    for polygon in data.polygons:polygon.use_smooth=True
    # Smooth the cut contour on the anatomical surface, transferring its skin
    # weights barycentrically. Projecting prevents smoothing from sinking fabric
    # into the skin and preserves deforming coverage around collar and armholes.
    bm=bmesh.new();bm.from_mesh(data)
    boundary={}
    for edge in bm.edges:
        if edge.is_boundary:
            a,b=(v.index for v in edge.verts)
            boundary.setdefault(a,set()).add(b);boundary.setdefault(b,set()).add(a)
    neighbours={v.index:{n.other_vert(v).index for n in v.link_edges} for v in bm.verts}
    bm.free()
    # Interior fabric bridges small anatomical features instead of copying skin
    # detail. Keep the fitted contour fixed while relaxing the broad surface.
    for _ in range(4):
        relaxed={i:data.vertices[i].co.lerp(sum((data.vertices[n].co for n in ns),Vector())/len(ns),.6)
                 for i,ns in neighbours.items() if i not in boundary and ns}
        for i,point in relaxed.items():data.vertices[i].co=point
    reference.data.calc_loop_triangles()
    triangles=[tuple(t.vertices) for t in reference.data.loop_triangles]
    reference_points=[v.co.copy() for v in reference.data.vertices]
    tree=BVHTree.FromPolygons(reference_points,triangles,all_triangles=True)
    for _ in range(3):
        updates={}
        for index,neighbours in boundary.items():
            mean=sum((data.vertices[n].co for n in neighbours),Vector())/len(neighbours)
            point,normal,triangle,_distance=tree.find_nearest(data.vertices[index].co.lerp(mean,.5))
            ids=triangles[triangle];a,b,c=(reference_points[i] for i in ids)
            ab,ac,ap=b-a,c-a,point-a
            denom=ab.dot(ab)*ac.dot(ac)-ab.dot(ac)**2
            if abs(denom)<1e-12:continue
            v=(ac.dot(ac)*ap.dot(ab)-ab.dot(ac)*ap.dot(ac))/denom
            w=(ab.dot(ab)*ap.dot(ac)-ab.dot(ac)*ap.dot(ab))/denom
            bary=[1-v-w,v,w];merged={}
            for original,factor in zip(ids,bary):
                for name,weight in weights[used[original]]:merged[name]=merged.get(name,0)+weight*factor
            updates[index]=(point+normal*.008,[(name,value) for name,value in merged.items() if value>.00001])
        for index,(point,skin_weights) in updates.items():
            data.vertices[index].co=point;garment_weights[index]=skin_weights
    data.update()
    # Retain a thin physical edge rather than a paper sheet.
    original_count=len(data.vertices)
    bpy.context.view_layer.objects.active=top
    shell=top.modifiers.new('Base fabric thickness','SOLIDIFY');shell.thickness=.003;shell.offset=-1
    bpy.ops.object.modifier_apply(modifier=shell.name)
    overrides['BaseTop']={i:garment_weights[i%original_count] for i in range(len(top.data.vertices))}
    result.append(top)
    # Recess only skin inside the fitted garment, fading to zero at its contour.
    # The old rectangular torso squeeze also changed exposed shoulder/neck skin.
    covered_ids=sorted(set(i for face in exposed for i in face))
    for vertex,original in zip(covered.data.vertices,covered_ids):
        point={'p':mapped[original],'w':dict(weights[original])}
        values=[field(point) for field in garment_fields]
        amount=min(max(0,min(1,value/scale)) for value,scale in zip(values,[.015,.015,.25,.12]))
        amount=amount*amount*(3-2*amount)
        vertex.co-=source_normals[original]*(.012*amount)
        if vertex.co.z<.27:
            # The boot opening covers this interval. Keep the full foot in the
            # hidden fitting reference, recess only the rendered ankle inside it.
            amount=max(0,min(1,(.27-vertex.co.z)/.03))
            amount=amount*amount*(3-2*amount)
            centre=.16 if vertex.co.x>=0 else -.16
            vertex.co.x=centre+(vertex.co.x-centre)*(1-.20*amount)
            vertex.co.y=-.005+(vertex.co.y+.005)*(1-.20*amount)
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
