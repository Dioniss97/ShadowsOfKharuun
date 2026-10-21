extends RefCounted
## Pose driver for the isolated Blender Studio rig trial, not the game actor.
var skeleton: Skeleton3D
var model: Node3D
var metadata: Dictionary
var config: Dictionary
var bones: Dictionary = {}
var rest: Dictionary = {}

func setup(node: Node3D) -> void:
	model = node
	skeleton = node.find_children("*", "Skeleton3D", true, false)[0]
	metadata = JSON.parse_string(FileAccess.get_file_as_string("res://assets/models/characters/studio_trial/rig_metadata.json"))
	config = JSON.parse_string(FileAccess.get_file_as_string("res://tools/blender/studio_trial_poses.json"))
	for i in skeleton.get_bone_count():
		var name := String(skeleton.get_bone_name(i))
		bones[name] = i
		rest[name] = skeleton.get_bone_rest(i)

func reset() -> void:
	for name in bones:
		skeleton.set_bone_pose(bones[name], rest[name])

func local_rotation(name: String, angles: Vector3) -> void:
	var q: Quaternion = rest[name].basis.get_rotation_quaternion()
	skeleton.set_bone_pose_rotation(bones[name], q*Quaternion.from_euler(angles))

func global_rotation(name: String, axis: Vector3, angle: float) -> void:
	var basis := skeleton.get_bone_global_rest(bones[name]).basis.orthonormalized()
	var local_axis := basis.inverse()*axis
	var q: Quaternion = rest[name].basis.get_rotation_quaternion()
	skeleton.set_bone_pose_rotation(bones[name],q*Quaternion(local_axis,angle))

func pose(mode: String, phase: float = 0.0, closure: float = 1.0) -> void:
	reset()
	if mode == "native": return
	for side in ["R","L"]:
		# Native hand orientation is preserved; no fixed 90-degree wrist twist.
		global_rotation("upper_arm_"+side,Vector3.FORWARD,0.34 if side == "R" else -0.34)
		local_rotation("forearm_"+side,Vector3(.10,0,0))
		for finger in range(5):
			for segment in range(3):
				local_rotation("finger_%s_%d_%d" % [side,finger,segment],Vector3(0.025 if finger == 0 else [0.03,0.06,0.025][segment],0,0))
	if mode in ["walk","turn"]:
		var stride := sin(phase)*.45
		var bob := -.028-.008*cos(phase*2.0)
		skeleton.set_bone_pose_position(bones.root,rest.root.origin+Vector3(0,bob,0))
		local_rotation("spine_02",Vector3(.015,sin(phase)*.035,0))
		for side in ["R","L"]:
			var sign_value := 1.0 if side == "R" else -1.0
			var leg := stride*sign_value
			var rest_ankle := skeleton.get_bone_global_rest(bones["foot_"+side]).origin
			var local_phase := phase+(0.0 if side == "R" else PI)
			var goal := rest_ankle+Vector3(0,maxf(0.0,sin(local_phase))*.065,cos(local_phase)*.17)
			leg_ik(side,goal)
			var q: Quaternion = skeleton.get_bone_pose_rotation(bones["upper_arm_"+side])
			skeleton.set_bone_pose_rotation(bones["upper_arm_"+side],q*Quaternion(Vector3.RIGHT,-leg*.45))
	if mode == "shoulder":
		local_rotation("clavicle_R",Vector3(0,0,-.12))
		local_rotation("upper_arm_R",Vector3(.75,0,-.30))
		local_rotation("forearm_R",Vector3(1.15,0,0))
	if mode == "grip":
		local_rotation("upper_arm_R",Vector3(.22,0,0))
		local_rotation("forearm_R",Vector3(1.10,0,0))
		for finger in range(5):
			for segment in range(3):
				var angle: float = float(config.grip_flex[finger][segment])*closure
				var thumb_root := finger == 0 and segment == 0
				local_rotation("finger_R_%d_%d" % [finger,segment],Vector3(angle,float(config.get("thumb_twist",0))*closure if thumb_root else 0.0,float(config.thumb_opposition)*closure if thumb_root else 0.0))

func aim(name: String, direction: Vector3) -> void:
	skeleton.force_update_all_bone_transforms()
	var index: int = bones[name]
	var original := skeleton.get_bone_global_rest(index).basis.orthonormalized()
	var target := Basis(Quaternion(original.y.normalized(),direction.normalized()))*original
	var parent := skeleton.get_bone_parent(index)
	var parent_basis := skeleton.get_bone_global_pose(parent).basis.orthonormalized() if parent >= 0 else Basis.IDENTITY
	skeleton.set_bone_pose_rotation(index,(parent_basis.inverse()*target).get_rotation_quaternion())

func leg_ik(side: String, goal: Vector3) -> void:
	skeleton.force_update_all_bone_transforms()
	var hip: Vector3 = skeleton.get_bone_global_pose(bones["thigh_"+side]).origin
	var original_hip := skeleton.get_bone_global_rest(bones["thigh_"+side]).origin
	var original_knee := skeleton.get_bone_global_rest(bones["shin_"+side]).origin
	var original_ankle := skeleton.get_bone_global_rest(bones["foot_"+side]).origin
	var upper := original_hip.distance_to(original_knee)
	var lower := original_knee.distance_to(original_ankle)
	var delta := goal-hip
	var distance := clampf(delta.length(),.1,upper+lower-.001)
	var direction := delta.normalized()
	var projection := (upper*upper-lower*lower+distance*distance)/(2.0*distance)
	var height := sqrt(maxf(0,upper*upper-projection*projection))
	var pole := (Vector3.FORWARD-direction*Vector3.FORWARD.dot(direction)).normalized()
	var knee := hip+direction*projection+pole*height
	aim("thigh_"+side,knee-hip)
	aim("shin_"+side,goal-knee)
	skeleton.force_update_all_bone_transforms()
	var original := skeleton.get_bone_global_rest(bones["foot_"+side]).basis.orthonormalized()
	var parent := skeleton.get_bone_global_pose(bones["shin_"+side]).basis.orthonormalized()
	skeleton.set_bone_pose_rotation(bones["foot_"+side],(parent.inverse()*original).get_rotation_quaternion())

func grip_transform() -> Transform3D:
	var frame: Dictionary = metadata.grips.R
	var columns: Array = frame.basis_columns
	var basis := Basis(vec(columns[0]),vec(columns[1]),vec(columns[2]))
	var local := Transform3D(basis,vec(frame.origin)+vec(config.grip_socket_offset))
	return skeleton.global_transform*skeleton.get_bone_global_pose(bones.hand_R)*local

func vec(a: Array) -> Vector3:
	return Vector3(a[0],a[1],a[2])
