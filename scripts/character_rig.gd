class_name KhCharacterRig
extends KhRig
## The existing action clock drives a skinned Blender character. NPCs continue
## to use KhRig. Its public action pivots retain the combat timing contract.

const MODEL = preload("res://assets/models/characters/adventurer.glb")
const PANEL_CHAINS := 6
const CAPE_CHAINS := 9
const RIGHT_GRIP_FLEX := [Vector3(0.68,1.035,0.68),Vector3(0.275,0.945,0.70),Vector3(0.56,1.105,0.745),Vector3(0.885,0.975,0.605),Vector3(1.20,0.52,0.325)]
const THUMB_OPPOSITION := Vector2(-0.50,-1.15)
const GRIP_FRAME := Transform3D(Basis(Vector3(0.55207076,0.79613009,-0.24777853),Vector3(0.19455521,0.16596613,0.96674841),Vector3(0.81078102,-0.58192100,-0.06326607)),Vector3(-0.04799622,0.07885034,-0.00110342))
var model: Node3D
var skeleton: Skeleton3D
var uniform_id := ""
var cloth: SpringBoneSimulator3D
var mesh_roles: Dictionary = {}

func build(tint: Color, blade_color: Color, guardian: bool = false) -> void:
	super.build(tint, blade_color, guardian)
	left_arm.position.x = -0.3066
	right_arm.position.x = 0.3066
	left_leg.position.x = -0.136
	right_leg.position.x = 0.136
	# Retain the existing weapon and action pivots, replace only actor geometry.
	for mesh in find_children("*", "MeshInstance3D", true, false):
		if not sword.is_ancestor_of(mesh): mesh.free()
	model = MODEL.instantiate()
	model.name = "CharacterVisual"
	add_child(model)
	skeleton = model.find_children("*", "Skeleton3D", true, false)[0]
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		KhCharacterMaterials.apply(mesh)
		var role := "always"
		if String(mesh.name).begins_with("Uniform"): role = "uniform"
		elif String(mesh.name).begins_with("Base"): role = "base"
		elif String(mesh.name).begins_with("BodyCovered"): role = "body"
		mesh_roles[mesh] = role
	set_uniform("")
	var grip := sword.get_node("SwordGrip") as MeshInstance3D
	var grip_mesh := grip.mesh.duplicate() as CylinderMesh
	grip_mesh.top_radius = 0.02
	grip_mesh.bottom_radius = 0.02
	grip_mesh.height = 0.22
	grip.mesh = grip_mesh
	_setup_cloth()
	_pose_elbows()
	_pose_fingers()
	_fit_grip()

func set_uniform(value: String) -> void:
	uniform_id = value
	for mesh in mesh_roles:
		mesh.visible = mesh_roles[mesh] == "always" or (mesh_roles[mesh] == "uniform" if value != "" else mesh_roles[mesh] in ["base", "body"])
	if is_instance_valid(cloth): cloth.active = value != ""

func animate(delta: float, speed: float) -> void:
	super.animate(delta, speed)
	if not is_instance_valid(skeleton): return
	model.position = body.position
	_pose("spine", body.rotation)
	# The source shoulders sit wide of the rib cage. Pull the hanging arm in,
	# then fade this rest-pose correction while an arm rises for combat or powers.
	var left_tuck := 1.0-smoothstep(0.25,0.9,absf(left_arm.rotation.x))
	var right_tuck := 1.0-smoothstep(0.25,0.9,absf(right_arm.rotation.x))
	var left_shoulder_pose := left_arm.rotation+Vector3(0.0,0.0,0.16*left_tuck)
	var right_shoulder_pose := right_arm.rotation+Vector3(0.0,0.0,-0.16*right_tuck)
	_pose("upper_arm_L", left_shoulder_pose)
	_pose("upper_arm_R", right_shoulder_pose)
	_pose("thigh_L", left_leg.rotation)
	_pose("thigh_R", right_leg.rotation)
	# Flex the trailing knee without changing the root movement or action clock.
	var knee_l := -maxf(0.0,-sin(phase))*minf(speed/4.0,1.0)*0.6
	var knee_r := -maxf(0.0,sin(phase))*minf(speed/4.0,1.0)*0.6
	_pose("shin_L",Vector3(knee_l,0,0))
	_pose("shin_R",Vector3(knee_r,0,0))
	# Counter-rotate the ankle during the existing stride so the sole does not
	# inherit the whole hip/knee rotation. This is not foot placement IK.
	_pose("foot_L",Vector3(-left_leg.rotation.x-knee_l,0,0))
	_pose("foot_R",Vector3(-right_leg.rotation.x-knee_r,0,0))
	_pose_elbows()
	_pose_fingers()
	_fit_grip()
	if is_instance_valid(cloth):
		cloth.external_force = global_basis.z*speed*0.006

func _cast_extension() -> float:
	if attack_time <= 0.0 or action_kind not in ["push", "lightning", "heal", "medkit"]: return 0.0
	var elapsed: float = attack_duration-attack_time
	return smoothstep(0.0,0.32,elapsed)*(1.0-smoothstep(0.54,0.9,elapsed))

func _pose_elbows() -> void:
	var swing_flex := 0.0
	if attack_time > 0.0 and action_kind in ["basic","flurry"]:
		swing_flex = sin(clampf(1.0-attack_time/attack_duration,0.0,1.0)*PI)*0.30
	_pose("forearm_R",Vector3(0.18+(0.20 if guarding or combat_stance else 0.0)+swing_flex,0,0))
	_pose("forearm_L",Vector3(lerpf(0.16,0.28,_cast_extension())+(0.14 if guarding else 0.0),0,0))

func _pose_fingers() -> void:
	for side in ["L", "R"]:
		var extension := _cast_extension() if side == "L" else 0.0
		var wrist := skeleton.find_bone("hand_"+side)
		if wrist >= 0:
			var twist := -PI/2.0 if side == "R" else lerpf(PI/2.0,0.0,extension)
			var wrist_rest := skeleton.get_bone_rest(wrist).basis.orthonormalized().get_rotation_quaternion()
			skeleton.set_bone_pose_rotation(wrist,wrist_rest*Quaternion(Vector3.UP,twist))
		for finger in range(1,6):
			for segment in range(3):
				var index := skeleton.find_bone("finger_%s_%d_%d" % [side,finger,segment])
				if index < 0: continue
				var flex: float
				if side == "R":
					flex = RIGHT_GRIP_FLEX[finger-1][segment]
				else:
					flex = lerpf([0.10,0.16,0.12][segment],0.02,extension)
				var joint_rest := skeleton.get_bone_rest(index).basis.orthonormalized().get_rotation_quaternion()
				var delta := Quaternion(Vector3.RIGHT,flex)
				if side == "R" and finger == 1 and segment == 0:
					delta = Quaternion(Vector3.UP,THUMB_OPPOSITION.x)*Quaternion(Vector3.BACK,THUMB_OPPOSITION.y)*delta
				skeleton.set_bone_pose_rotation(index,joint_rest*delta)

func _fit_grip() -> void:
	var hand := skeleton.find_bone("hand_R")
	if hand < 0: return
	var hand_pose := skeleton.global_transform*skeleton.get_bone_global_pose(hand)
	var grip_pose := hand_pose*GRIP_FRAME
	sword.global_basis = grip_pose.basis.orthonormalized()
	sword.global_position = grip_pose.origin-sword.global_basis*Vector3(0,0.04,0)
	var free_hand := skeleton.find_bone("hand_L")
	left_palm.global_position = skeleton.global_transform*(skeleton.get_bone_global_pose(free_hand)*Vector3(0,.085,.015))

func _pose(name: String, angles: Vector3) -> void:
	var index := skeleton.find_bone(name)
	if index < 0: return
	var rest := skeleton.get_bone_global_rest(index).basis.orthonormalized()
	var local_rest := skeleton.get_bone_rest(index).basis.orthonormalized()
	skeleton.set_bone_pose_rotation(index, (local_rest*rest.inverse()*Basis.from_euler(angles)*rest).get_rotation_quaternion())

func _setup_cloth() -> void:
	cloth = SpringBoneSimulator3D.new()
	cloth.name = "WardrobeSecondaryMotion"
	skeleton.add_child(cloth)
	cloth.setting_count = PANEL_CHAINS + CAPE_CHAINS
	_add_collision_guard("spine", 0.52, 0.165, Vector3(0, 0.26, 0))
	_add_collision_guard("hips", 0.30, 0.13, Vector3(0, 0.07, 0))
	for side in ["L", "R"]:
		_add_collision_guard("upper_arm_"+side, 0.33, 0.09, Vector3(0, 0.15, 0))
	for limb in ["thigh_L", "thigh_R", "shin_L", "shin_R"]:
		var radius := 0.105 if limb.begins_with("thigh") else 0.085
		_add_collision_guard(limb, 0.48, radius, Vector3(0, 0.19, 0))
	for i in range(PANEL_CHAINS + CAPE_CHAINS):
		var is_cape := i >= PANEL_CHAINS
		var chain_index := i-PANEL_CHAINS if is_cape else i
		var prefix := "cape_" if is_cape else "cloth_"
		var root_name := prefix+"%d_a" % chain_index
		var end_name := prefix+"%d_b" % chain_index
		cloth.set_root_bone_name(i, root_name)
		cloth.set_end_bone_name(i, end_name)
		cloth.set_extend_end_bone(i, true)
		cloth.set_end_bone_length(i, 0.27 if is_cape else 0.38)
		cloth.set_center_from(i, SpringBoneSimulator3D.CENTER_FROM_WORLD_ORIGIN)
		cloth.set_stiffness(i, 7.0 if is_cape else 10.5)
		cloth.set_drag(i, 0.88)
		cloth.set_gravity(i, 0.65 if is_cape else 1.2)
		cloth.set_radius(i, 0.022 if is_cape else 0.025)
		cloth.set_enable_all_child_collisions(i, true)
	cloth.active = uniform_id != ""

func _add_collision_guard(bone_name: String, height: float, radius: float, offset: Vector3) -> void:
	var collider := SpringBoneCollisionCapsule3D.new()
	collider.name = "ClothGuard_"+bone_name
	cloth.add_child(collider)
	collider.bone_name = bone_name
	collider.height = height
	collider.radius = radius
	collider.position_offset = offset
