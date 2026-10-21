"""Original anatomical surface masks and cloth coordinates for the shared palette."""
import math
import json
import bpy
import numpy as np
from mathutils import Vector
from mathutils.kdtree import KDTree


def grip_contact(objects, path):
    """Apply the authored contact sculpt in rest space; skin keeps driving it."""
    if not path.exists():return
    data=json.loads(path.read_text(encoding='utf-8'))
    for obj in objects:
        entries=data['corrections'].get(obj.name)
        if not entries:continue
        tree=KDTree(len(obj.data.vertices))
        for vertex in obj.data.vertices:tree.insert(vertex.co,vertex.index)
        tree.balance();matched=0
        for entry in entries:
            point=Vector(entry['point']);_co,index,distance=tree.find(point)
            if distance>.00015:continue
            obj.data.vertices[index].co+=Vector(entry['delta']);matched+=1
        obj.data.update()
        print('GRIP_CONTACT_SOURCE',obj.name,matched,'/',len(entries))
        if matched<len(entries)*.98:raise RuntimeError('Grip correction source geometry changed; refit before export')


def skin_atlas(material, objects):
    """Paint low-frequency anatomy into the retained CC0 UV layout, not world XZ."""
    n=1024
    xyz=np.zeros((n,n,3),np.float32);occupied=np.zeros((n,n),bool)
    for obj in objects:
        if obj.name not in ['HumanHead','HumanHands','BodyCovered']:continue
        mesh=obj.data;mesh.calc_loop_triangles();uv=mesh.uv_layers.active
        for triangle in mesh.loop_triangles:
            coords=np.array([uv.data[i].uv[:] for i in triangle.loops])*[n-1,n-1]
            p=np.array([mesh.vertices[i].co[:] for i in triangle.vertices])
            low=np.maximum(np.floor(coords.min(0)).astype(int),0)
            high=np.minimum(np.ceil(coords.max(0)).astype(int),n-1)
            if np.any(high<low):continue
            yy,xx=np.mgrid[low[1]:high[1]+1,low[0]:high[0]+1]
            a,b,c=coords;ab=b-a;ac=c-a;den=ab[0]*ac[1]-ab[1]*ac[0]
            if abs(den)<1e-8:continue
            u=((xx-a[0])*ac[1]-(yy-a[1])*ac[0])/den
            v=(ab[0]*(yy-a[1])-ab[1]*(xx-a[0]))/den
            inside=(u>=-.001)&(v>=-.001)&(u+v<=1.001)
            values=p[0]+u[:,:,None]*(p[1]-p[0])+v[:,:,None]*(p[2]-p[0])
            area=xyz[low[1]:high[1]+1,low[0]:high[0]+1];area[inside]=values[inside]
            occupied[low[1]:high[1]+1,low[0]:high[0]+1]|=inside
    # Pad islands with anatomical values to avoid dark mip seams.
    for _ in range(10):
        old=occupied.copy();total=np.zeros_like(xyz);count=np.zeros((n,n),np.float32)
        for axis,shift in [(0,1),(0,-1),(1,1),(1,-1)]:
            mask=np.roll(old,shift,axis);total+=np.roll(xyz,shift,axis)*mask[:,:,None];count+=mask
        update=(~old)&(count>0);xyz[update]=total[update]/count[update,None];occupied[update]=True
    x,y,z=xyz[:,:,0],xyz[:,:,1],xyz[:,:,2]
    def spot(cx,cz,sx,sz):return np.exp(-((np.abs(x)-cx)/sx)**2-((z-cz)/sz)**2)
    front=np.clip((y-.015)/.10,0,1)
    cheeks=spot(.055,1.78,.03,.045)*front
    joints=spot(.31,1.16,.10,.055)+spot(.14,.54,.10,.055)
    hands=spot(.32,.85,.13,.10)
    rng=np.random.default_rng(2304);noise=rng.normal(0,1,(n,n)).astype(np.float32)
    variation=.008*np.sin(x*27+z*9)*np.sin(z*31)+noise*.0015
    pixels=np.ones((n,n,4),np.float32)
    pixels[:,:,:3]=np.array([.44,.285,.205])*(1+variation[:,:,None])
    pixels[:,:,0]+=cheeks*.012+joints*.004+hands*.004
    pixels[:,:,1]-=cheeks*.003
    rough=np.clip(.70-cheeks*.04+hands*.025+joints*.015+noise*.006,.58,.80)
    # Pores are subtle and anatomical color/roughness remains the main signal.
    height=noise*.0025+np.sin(x*470+z*51)*.001
    dy,dx=np.gradient(height);normals=np.stack((-dx*2,-dy*2,np.ones_like(dx)),2)
    normals/=np.linalg.norm(normals,axis=2,keepdims=True)
    nodes=material.node_tree.nodes;links=material.node_tree.links;bsdf=nodes.get('Principled BSDF')
    for suffix,array,socket,data in [('anatomical_color',pixels,'Base Color',False),('anatomical_roughness',rough,'Roughness',True),('anatomical_normal',normals*.5+.5,'Normal',True)]:
        rgba=np.ones((n,n,4),np.float32)
        rgba[:,:,:3]=array[:,:,:3] if array.ndim==3 else array[:,:,None]
        image=bpy.data.images.new('Skin_'+suffix,width=n,height=n)
        if data:image.colorspace_settings.name='Non-Color'
        image.pixels.foreach_set(rgba.ravel());image.pack()
        tex=nodes.new('ShaderNodeTexImage');tex.image=image
        if socket=='Normal':
            normal=nodes.new('ShaderNodeNormalMap');normal.inputs['Strength'].default_value=.55
            links.new(tex.outputs['Color'],normal.inputs['Color']);links.new(normal.outputs['Normal'],bsdf.inputs[socket])
        else:links.new(tex.outputs['Color'],bsdf.inputs[socket])


def cloth_coordinates(objects):
    """A 32cm material tile gives all panels a common millimetric thread scale."""
    for obj in objects:
        if obj.name in ['HumanHead','HumanHands','BodyCovered','UniformGloves','HairCrop']:continue
        if not obj.name.startswith(('BaseTop','BaseShort','BaseWaist','Uniform')):continue
        if any(s in obj.name for s in ['Boot','Shoe','Buckle','Clasp']):continue
        uv=obj.data.uv_layers.active or obj.data.uv_layers.new(name='TailoredWeave')
        sleeve=obj.name in ['UniformJacket','UniformCuff_L','UniformCuff_R']
        for polygon in obj.data.polygons:
            centre=polygon.center
            arm=sleeve and abs(centre.x)>.25 and centre.z<1.48
            flat=obj.name.startswith(('UniformCape','UniformPanel','UniformLapel'))
            centre_x=math.copysign(.3066,centre.x) if arm else 0
            if obj.name.startswith(('BaseShort','UniformTrousers')):centre_x=math.copysign(.136,centre.x)
            reference=math.atan2(centre.x-centre_x,centre.y)
            for loop in polygon.loop_indices:
                p=obj.data.vertices[obj.data.loops[loop].vertex_index].co
                angle=math.atan2(p.x-centre_x,p.y)
                while angle-reference>math.pi:angle-=math.pi*2
                while angle-reference<-math.pi:angle+=math.pi*2
                across=p.x if flat else angle*(.06 if arm else (.09 if centre_x else .20))
                uv.data[loop].uv=(across/.32,p.z/.32)
