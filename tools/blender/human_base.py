"""Adapt the pinned MakeHuman CC0 anatomy to this character's shared rig.

Only body faces are used; helper geometry and source program code are excluded.
See art/source/characters/vendor/makehuman for provenance and CC0 text.
"""
import math
import bpy
import bmesh
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree


def build(root, target_bones, target_rig, skin, hair, eye, iris, base_cloth, base_trim, robe, leather):
    path = root/'art/source/characters/vendor/makehuman/base.obj'
    raw=[]; faces=[]; face_uvs={};texcoords=[]; groups={}; current=''
    for line in path.read_text(encoding='utf-8-sig').splitlines():
        row=line.split()
        if not row: continue
        if row[0]=='v': raw.append(Vector(tuple(map(float,row[1:4]))))
        elif row[0]=='vt':texcoords.append(tuple(map(float,row[1:3])))
        elif row[0]=='g': current=row[1];groups.setdefault(current,set())
        elif row[0]=='f':
            # Y-up -> Z-up swaps two axes, so reverse polygon winding.
            face=tuple(reversed([int(w.split('/')[0])-1 for w in row[1:]]))
            groups[current].update(face)
            if current=='body':
                faces.append(face)
                face_uvs[face]=[texcoords[int(w.split('/')[1])-1] for w in reversed(row[1:])]
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

    # Broaden the rib cage and waist slightly so the shoulders do not dominate
    # the torso silhouette. Keep the change on the weighted body core, fading
    # through the shoulder and hip joints instead of scaling the whole figure.
    for i,p in mapped.items():
        w=dict(weights[i])
        core=w.get('spine',0)+w.get('hips',0)
        ribcage=math.exp(-((p.z-1.32)/.21)**2)*core
        waist=math.exp(-((p.z-1.10)/.18)**2)*core
        p.x*=1+.11*ribcage+.08*waist
        p.y*=1+.07*ribcage+.04*waist
        arm=sum(value for name,value in w.items() if name.startswith('upper_arm_'))
        shoulder=math.exp(-((p.z-1.46)/.085)**2)*arm
        p.y*=1-.13*shoulder
        wrist=math.exp(-((p.z-1.025)/.065)**2)*sum(value for name,value in w.items() if name.startswith(('forearm_','hand_')))
        if abs(p.x)>.30:
            centre=math.copysign(.42,p.x)
            p.x=centre+(p.x-centre)*(1+.12*wrist)
            p.y=.015+(p.y-.015)*(1+.08*wrist)

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
        if role in ['always','body','base'] and mat==skin:
            uv=data.uv_layers.new(name='UVMap')
            for polygon,original_face in zip(data.polygons,selected):
                for loop,co in zip(polygon.loop_indices,face_uvs[original_face]):uv.data[loop].uv=co
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
        is_head=(head_weight>.55 and p.z>1.50) or (p.z>1.50 and abs(p.x)<.19 and head_weight>.05)
        # Select in the retargeted limb space. The old source-X threshold cut
        # across the inward-pointing thumb and split it between wardrobe roles.
        # Keep the seam up the forearm, outside the wrist correction envelope.
        is_hand=abs(p.x)>.30 and p.z<1.06
        if is_head:head_faces.append(face)
        elif is_hand:hand_faces.append(face)
        elif p.z>.20:exposed.append(face)
        if original.z>1.92 or (original.y<-.014 and original.z>1.83):scalp.append(face)
    make('HumanHead',head_faces,skin,'always')
    hands=make('HumanHands',hand_faces,skin,'base')
    gloves=hands.copy();gloves.data=hands.data.copy();gloves.name='UniformGloves'
    bpy.context.collection.objects.link(gloves)
    gloves['wardrobe_role']='uniform'
    gloves.data.materials.clear();gloves.data.materials.append(leather)
    hands.data.update()
    for vertex in gloves.data.vertices:vertex.co+=hands.data.vertices[vertex.index].normal*.0018
    overrides['UniformGloves']={i:list(values) for i,values in overrides['HumanHands'].items()}
    result.append(gloves)
    covered=make('BodyCovered',exposed,skin,'body')
    make('HairCrop',scalp,hair,'always',.003)
    # A hidden full anatomical reference supports fitting future clothes.
    reference=make('AnatomyReference',faces,skin,'reference')
    reference.hide_render=True;reference.hide_set(True)
    result.remove(reference)

    # Fit clothing to the intact anatomy. Clip along continuous
    # scalar fields, interpolating both coordinates and skin weights at each cut;
    # selecting whole faces would leave a visibly jagged edge around the arms.
    reference.data.update()
    source_normals={i:reference.data.vertices[j].normal.copy() for j,i in enumerate(used)}
    garment_fields=[lambda v:v['p'].z-1.01,lambda v:1.64-v['p'].z,
                    lambda v:(v['p'].x/.13)**2+(v['p'].y/.13)**2+((v['p'].z-1.70)/.25)**2-1,
                    lambda v:.30+.025*math.exp(-((v['p'].z-1.50)/.07)**2)-abs(v['p'].x)]
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
    garment_surfaces={}
    def garment(garment_name,material,role,fields,outset=.006,thickness=.003,max_components=1,boundary_iterations=3):
        garment_vertices=[];garment_faces=[];garment_weights=[];lookup={}
        for face in faces:
            poly=[{'p':mapped[i],'n':source_normals[i],'w':dict(weights[i])} for i in face]
            for field in fields:
                if not poly:break
                poly=clip(poly,field)
            if len(poly)<3:continue
            indices=[]
            for point in poly:
                key=tuple(round(v,6) for v in point['p'])
                if key not in lookup:
                    lookup[key]=len(garment_vertices)
                    garment_vertices.append(point['p']+point['n']*outset)
                    garment_weights.append([(name,value) for name,value in point['w'].items() if value>.00001])
                indices.append(lookup[key])
            if len(set(indices))>=3:garment_faces.append(indices)
        # Scalar cuts may catch disconnected patches. Keep the intended main
        # surface, or both leg bands when explicitly requested.
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
        component=set().union(*sorted(components,key=len,reverse=True)[:max_components])
        chosen=sorted(component);remap={old:new for new,old in enumerate(chosen)}
        garment_faces=[[remap[i] for i in face] for face in garment_faces if all(i in component for i in face)]
        garment_vertices=[garment_vertices[i] for i in chosen];garment_weights=[garment_weights[i] for i in chosen]
        data=bpy.data.meshes.new('Fitted'+garment_name)
        data.from_pydata(garment_vertices,[],garment_faces);data.update()
        top=bpy.data.objects.new(garment_name,data);bpy.context.collection.objects.link(top)
        data.materials.append(material);top['wardrobe_role']=role;top['fixed_bone']=''
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
        for _ in range(10 if garment_name=='UniformJacket' else 4):
            relaxed={i:data.vertices[i].co.lerp(sum((data.vertices[n].co for n in ns),Vector())/len(ns),.6)
                     for i,ns in neighbours.items() if i not in boundary and ns}
            for i,point in relaxed.items():data.vertices[i].co=point
        reference.data.calc_loop_triangles()
        triangles=[tuple(t.vertices) for t in reference.data.loop_triangles]
        reference_points=[v.co.copy() for v in reference.data.vertices]
        tree=BVHTree.FromPolygons(reference_points,triangles,all_triangles=True)
        for _ in range(boundary_iterations):
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
                updates[index]=(point+normal*(outset+.002),[(name,value) for name,value in merged.items() if value>.00001])
            for index,(point,skin_weights) in updates.items():
                data.vertices[index].co=point;garment_weights[index]=skin_weights
        data.update()
        # Restrained broad folds follow points of support rather than adding
        # skin detail to a body offset. They are part of the deforming mesh.
        if garment_name in ['UniformJacket','UniformTrousers','BaseTop','BaseShorts']:
            for vertex in data.vertices:
                p=vertex.co;n=vertex.normal
                front=max(0,min(1,p.y/.10))
                if garment_name=='UniformJacket':
                    chest=math.exp(-((p.z-1.27)/.18)**2)*max(0,1-abs(p.x)/.29)
                    gather=math.exp(-((p.z-1.12)/.055)**2)
                    elbow=math.exp(-((p.z-1.22)/.06)**2)*max(0,min(1,(abs(p.x)-.27)/.06))
                    fold=.0035*math.sin(p.z*53+abs(p.x)*14)*chest*front
                    fold+=.004*math.cos(p.x*62)*gather
                    fold+=.004*math.sin(p.z*104+p.y*12)*elbow
                elif garment_name=='UniformTrousers':
                    fold=.0035*math.sin(p.z*94+p.x*11)*math.exp(-((p.z-.55)/.07)**2)
                else:
                    fold=.0015*math.sin(p.z*68+p.x*19)*front
                vertex.co+=n*fold
            data.update()
        # Retain a thin physical edge rather than a paper sheet.
        original_count=len(data.vertices)
        garment_surfaces[garment_name]=(top,original_count,boundary,garment_weights)
        bpy.context.view_layer.objects.active=top
        shell=top.modifiers.new('Base fabric thickness','SOLIDIFY');shell.thickness=thickness;shell.offset=-1
        bpy.ops.object.modifier_apply(modifier=shell.name)
        overrides[garment_name]={i:garment_weights[i%original_count] for i in range(len(top.data.vertices))}
        result.append(top)
        return top

    def edge_trim(source_name,name,material,upper=True,drop=.024,loops_to_keep=1):
        from mathutils.bvhtree import BVHTree
        source,count,boundary,skin_weights=garment_surfaces[source_name]
        outer_faces=[tuple(p.vertices) for p in source.data.polygons if all(i<count for i in p.vertices)]
        surface=BVHTree.FromPolygons([v.co.copy() for v in source.data.vertices[:count]],outer_faces)
        remaining=set(boundary);loops=[]
        while remaining:
            start=next(iter(remaining));order=[];current=start;previous=-1
            while current in remaining:
                remaining.remove(current);order.append(current)
                candidates=[n for n in boundary[current] if n!=previous and n in remaining]
                if not candidates:break
                previous,current=current,candidates[0]
            if len(order)>6:loops.append(order)
        loops.sort(key=lambda loop:sum(source.data.vertices[i].co.z for i in loop)/len(loop),reverse=upper)
        vertices=[];polygons=[];skin=[]
        for loop in loops[:loops_to_keep]:
            coords=[source.data.vertices[i].co.copy() for i in loop]
            base=len(vertices);size=len(loop)
            for row in range(3):
                t=row/2
                for i,p in enumerate(coords):
                    target=p+Vector((0,0,-drop*t if upper else drop*t))
                    fitted,normal,_,_=surface.find_nearest(target)
                    # Follow the actual garment surface, including each thigh.
                    # A radial band from the world origin crosses the shorts.
                    vertices.append(fitted+normal*.0045);skin.append(skin_weights[loop[i]])
            for row in range(2):
                for i in range(size):
                    j=(i+1)%size
                    polygons.append((base+row*size+i,base+row*size+j,base+(row+1)*size+j,base+(row+1)*size+i))
        data=bpy.data.meshes.new(name);data.from_pydata(vertices,[],polygons);data.update()
        if sum(p.normal.dot(Vector((p.center.x,p.center.y,0))) for p in data.polygons)<0:
            bm=bmesh.new();bm.from_mesh(data)
            bmesh.ops.reverse_faces(bm,faces=list(bm.faces));bm.to_mesh(data);bm.free();data.update()
        obj=bpy.data.objects.new(name,data);bpy.context.collection.objects.link(obj)
        data.materials.append(material);obj['wardrobe_role']=source['wardrobe_role'];obj['fixed_bone']=''
        for p in data.polygons:p.use_smooth=True
        bpy.context.view_layer.objects.active=obj
        shell=obj.modifiers.new('Tailored edge thickness','SOLIDIFY');shell.thickness=.003;shell.offset=0
        bpy.ops.object.modifier_apply(modifier=shell.name)
        overrides[name]={i:skin[i%len(skin)] for i in range(len(obj.data.vertices))}
        result.append(obj)
        return obj

    garment('BaseTop',base_cloth,'base',garment_fields,boundary_iterations=10)
    shorts_fields=[lambda v:v['p'].z-.735,lambda v:1.055-v['p'].z,
                   lambda v:sum(value for name,value in v['w'].items() if name=='hips' or name.startswith(('thigh_','shin_')))-.60]
    garment('BaseShorts',base_cloth,'base',shorts_fields,outset=.012,thickness=.004)
    edge_trim('BaseShorts','BaseWaistband',base_trim,upper=True,drop=.016)
    edge_trim('BaseShorts','BaseShortHem',base_trim,upper=False,drop=.014,loops_to_keep=2)
    jacket_fields=[lambda v:v['p'].z-.935,lambda v:1.65-v['p'].z,
                   lambda v:(v['p'].x/.11)**2+(v['p'].y/.105)**2+((v['p'].z-1.70)/.23)**2-1]
    garment('UniformJacket',robe,'uniform',jacket_fields,outset=.026,thickness=.004,boundary_iterations=8)
    edge_trim('UniformJacket','UniformCollar',base_trim,upper=True,drop=.024)
    garment('UniformTrousers',base_cloth,'uniform',[lambda v:v['p'].z-.32,lambda v:1.09-v['p'].z,shorts_fields[2]],outset=.014,thickness=.004)
    garment('UniformBelt',leather,'uniform',[lambda v:v['p'].z-1.025,lambda v:1.09-v['p'].z,garment_fields[3]],outset=.035,thickness=.008)
    # Recess only skin inside the fitted garment, fading to zero at its contour.
    # The old rectangular torso squeeze also changed exposed shoulder/neck skin.
    covered_ids=sorted(set(i for face in exposed for i in face))
    for vertex,original in zip(covered.data.vertices,covered_ids):
        point={'p':mapped[original],'w':dict(weights[original])}
        values=[field(point) for field in garment_fields]
        amount=min(max(0,min(1,value/scale)) for value,scale in zip(values,[.015,.015,.25,.12]))
        shorts_values=[field(point) for field in shorts_fields]
        shorts_amount=min(max(0,min(1,value/scale)) for value,scale in zip(shorts_values,[.018,.018,.12]))
        amount=max(amount,shorts_amount)
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
