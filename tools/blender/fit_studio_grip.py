"""Fit articulated grip poses against the intact trial hand; no mesh sculpting."""
from pathlib import Path
import bpy,json,math
import numpy as np

ROOT=Path(__file__).resolve().parents[2]
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'art/source/characters/studio_trial/studio_rig_trial.blend'))
body=bpy.data.objects['StudioTrialBody'];rig=bpy.data.objects['StudioTrialRig']
metadata=json.loads((ROOT/'assets/models/characters/studio_trial/rig_metadata.json').read_text())
path=ROOT/'tools/blender/studio_trial_poses.json';config=json.loads(path.read_text())
names=[f'finger_R_{f}_{k}' for f in range(5) for k in range(3)]
rest={n:np.array(rig.data.bones[n].matrix_local) for n in ['hand_R']+names}
inverse={n:np.linalg.inv(rest[n]) for n in names}
local={n:np.linalg.inv(rest['hand_R' if k==0 else f'finger_R_{f}_{k-1}']) @ rest[n] for f in range(5) for k in range(3) for n in [f'finger_R_{f}_{k}']}
selected=[]
for v in body.data.vertices:
    hand=sum(g.weight for g in v.groups if body.vertex_groups[g.group].name=='hand_R' or body.vertex_groups[g.group].name in names)
    if hand>.5:selected.append(v.index)
points=np.array([[*body.data.vertices[i].co,1] for i in selected])
weights=np.zeros((len(points),len(names)))
for j,i in enumerate(selected):
    for group in body.data.vertices[i].groups:
        name=body.vertex_groups[group.group].name
        if name in names:weights[j,names.index(name)]=group.weight
static=points*(1-weights.sum(1))[:,None]
weighted={n:points*weights[:,i,None] for i,n in enumerate(names)}
palm=weights.sum(1)<.15
frame=np.eye(4);frame[:3,:3]=np.array(metadata['grips']['R']['basis_columns']).T
frame[:3,3]=metadata['grips']['R']['origin']
radius=config['grip_radius']

def rx(a):
    c,s=math.cos(a),math.sin(a)
    return np.array([[1,0,0,0],[0,c,-s,0],[0,s,c,0],[0,0,0,1.]])
def rz(a):
    c,s=math.cos(a),math.sin(a)
    return np.array([[c,-s,0,0],[s,c,0,0],[0,0,1,0],[0,0,0,1.]])
def ry(a):
    c,s=math.cos(a),math.sin(a)
    return np.array([[c,0,s,0],[0,1,0,0],[-s,0,c,0],[0,0,0,1.]])

def skin(params,closure=1.0,center_handle=True):
    poses={'hand_R':rest['hand_R']};posed=static.copy()
    for f in range(5):
        for k in range(3):
            n=f'finger_R_{f}_{k}';parent='hand_R' if k==0 else f'finger_R_{f}_{k-1}'
            delta=rx(params[f*3+k]*closure)
            if f==0 and k==0:delta=ry(params[19]*closure) @ delta @ rz(params[15]*closure)
            poses[n]=poses[parent] @ local[n] @ delta
            posed+=weighted[n] @ (poses[n] @ inverse[n]).T
    grip=frame.copy();grip[:3,3]+=params[16:19]
    transform=np.linalg.inv(rest['hand_R'] @ grip)
    pts=posed @ transform.T
    tips=[]
    for f in range(5):
        n=f'finger_R_{f}_2'
        tail=np.array([*rig.data.bones[n].tail_local,1])
        tips.append(transform @ poses[n] @ inverse[n] @ tail)
    tips=np.array(tips)
    # Center the finite handle on the actual hand span. Otherwise an optimizer
    # can evade a contact constraint by putting the thumb beyond the shaft end.
    center=(float(pts[:,1].min())+float(pts[:,1].max()))*.5 if center_handle else 0.0
    pts[:,1]-=center;tips[:,1]-=center
    return pts,tips,center

prior=np.array([v for digit in config['grip_flex'] for v in digit]+[config['thumb_opposition']]+config['grip_socket_offset']+[config.get('thumb_twist',0)],float)
bounds=[(-.8,.8),(-1.1,1.1),(-1.1,1.1)]+[(.10,1.1),(.70,1.65),(.30,1.1)]*4+[(-1.5,1.5),(-.060,.060),(-.060,.060),(-.040,.060),(-1.5,1.5)]

def score(params,details=False):
    pts,tips,center=skin(params)
    radial=np.linalg.norm(pts[:,[0,2]],axis=1)
    valid=np.abs(pts[:,1])<config['grip_length']*.5
    depth=np.maximum(radius+.0008-radial[valid],0)
    loss=35000*float(np.max(depth,initial=0)**2)+45000*float(np.mean(depth**2))
    # Report interpolation with the same fixed socket used by the end pose.
    transition=[]
    if details:
        centered=params.copy();centered[16:19]+=frame[:3,1]*center
        for closure in [0.0,.25,.5,.75]:
            intermediate,_,_=skin(centered,closure,False)
            radial_i=np.linalg.norm(intermediate[:,[0,2]],axis=1)
            valid_i=np.abs(intermediate[:,1])<config['grip_length']*.5
            # Interpolation is a diagnostic, not a grasp animation.
            transition.append(int(np.sum(radial_i[valid_i]<radius-.0005)))
    tiprad=np.linalg.norm(tips[:,[0,2]],axis=1)
    loss+=50*float(np.mean((tiprad[1:]-(radius+.005))**2))
    # Fingers must come around the far side; thumb closes the opposite side.
    loss+=10*float(np.mean(np.maximum(.010-tips[1:,2],0)**2))
    loss+=100*float((tiprad[0]-(radius+.006))**2)
    loss+=2*float(max(0,tips[0,2]+.006)**2)
    loss+=20*float(np.mean(np.maximum(np.abs(tips[:,1])-.075,0)**2))
    loss+=12*float((tips[0,1]-(tips[1,1]-.010))**2)
    palmr=radial[palm & valid]
    if len(palmr):loss+=15*float((palmr.min()-(radius+.0015))**2)
    loss+=.10*float(np.sum(params[16:19]**2))
    natural=np.array([-.15,-.4,-.5]+[.8,1.2,.6]*4)
    loss+=.00012*float(np.sum((params[:15]-natural)**2))
    if details:return {'loss':loss,'inside_vertices':int(np.sum(radial[valid]<radius-.0005)),
        'minimum_radius':float(radial[valid].min()),'shaft_recentering_m':center,'transition_inside_vertices':transition,'tip_radials':tiprad.tolist(),'tip_positions':tips.tolist()}
    return loss

rng=np.random.default_rng(2914)
import sys
if '--report-only' in sys.argv:
    (ROOT/'art/references/character/studio_rig_trial/grip_fit_report.json').write_text(json.dumps(score(prior,True),indent=2),encoding='utf8')
    print('GRIP_REPORT_ONLY',score(prior,True),flush=True)
    sys.exit(0)
best=prior.copy();bestscore=score(best)
print('GRIP_FIT_START',score(best,True),flush=True)
for restart in range(10):
    current=best.copy() if restart<2 else prior+rng.normal(0,.45,len(prior))
    current=np.array([np.clip(v,*bounds[i]) for i,v in enumerate(current)])
    current_score=score(current)
    for step in [.25,.10,.04,.015,.005,.002]:
        for iteration in range(5):
            improved=False
            for i in rng.permutation(len(current)):
                spacing=step*(.035 if 16<=i<19 else 1)
                for sign in [-1,1]:
                    trial=current.copy();trial[i]=np.clip(trial[i]+sign*spacing,*bounds[i])
                    value=score(trial)
                    if value<current_score:
                        current,current_score=trial,value;improved=True
            if not improved:break
    if current_score<bestscore:best,bestscore=current,current_score
    print('GRIP_FIT_RESTART',restart,score(best,True),flush=True)
_,_,center=skin(best)
best[16:19]+=frame[:3,1]*center
config['grip_flex']=best[:15].reshape((5,3)).tolist()
config['thumb_opposition']=float(best[15])
config['grip_socket_offset']=best[16:19].tolist()
config['thumb_twist']=float(best[19])
path.write_text(json.dumps(config,indent=2)+'\n',encoding='utf8')
(ROOT/'art/references/character/studio_rig_trial/grip_fit_report.json').write_text(json.dumps(score(best,True),indent=2),encoding='utf8')
print('GRIP_FIT_OK',config,flush=True)
