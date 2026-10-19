class_name KhCharacterRig
extends KhRig
## The existing action clock drives a skinned Blender character. NPCs continue
## to use KhRig. Its public action pivots retain the combat timing contract.

const MODEL = preload("res://assets/models/characters/adventurer.glb")
const PANEL_CHAINS := 6
const CAPE_CHAINS := 9
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
	_pose("upper_arm_L", left_arm.rotation)
	_pose("upper_arm_R", right_arm.rotation)
	_pose("thigh_L", left_leg.rotation)
	_pose("thigh_R", right_leg.rotation)
	# Flex the trailing knee without changing the root movement or action clock.
	_pose("shin_L", Vector3(-maxf(0.0, -sin(phase))*minf(speed/4.0, 1.0)*0.6, 0, 0))
	_pose("shin_R", Vector3(-maxf(0.0, sin(phase))*minf(speed/4.0, 1.0)*0.6, 0, 0))
	_pose_fingers()
	_fit_grip()
	if is_instance_valid(cloth):
		cloth.external_force = global_basis.z*speed*0.018

func _pose_fingers() -> void:
	for side in ["L", "R"]:
		var casting: bool = side == "L" and attack_time > 0.0 and action_kind in ["push", "lightning", "heal", "medkit"]
		var extension := 0.0
		if casting:
			var elapsed: float = attack_duration-attack_time
			extension = smoothstep(0.0,0.32,elapsed)*(1.0-smoothstep(0.54,0.9,elapsed))
		var wrist := skeleton.find_bone("hand_"+side)
		if wrist >= 0:
			var twist := -PI/2.0 if side == "R" else lerpf(PI/2.0,0.0,extension)
			skeleton.set_bone_pose_rotation(wrist,Quaternion(Vector3.UP,twist))
		for finger in range(1,6):
			for segment in range(3):
				var index := skeleton.find_bone("finger_%s_%d_%d" % [side,finger,segment])
				if index < 0: continue
				var flex: float
				if side == "R":
					flex = [0.55,0.70,0.40][segment] if finger == 1 else [0.95,1.25,0.85][segment]
				else:
					flex = lerpf([0.10,0.16,0.12][segment],0.02,extension)
				skeleton.set_bone_pose_rotation(index,Quaternion(Vector3.RIGHT,flex))

func _fit_grip() -> void:
	var hand := skeleton.find_bone("hand_R")
	if hand < 0: return
	var hand_pose := skeleton.global_transform*skeleton.get_bone_global_pose(hand)
	var centre := hand_pose*Vector3(0,0.085,0.025)
	sword.global_position = centre-sword.global_basis*Vector3(0,0.04,0)

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
		cloth.set_stiffness(i, 4.1 if is_cape else 3.2)
		cloth.set_drag(i, 0.84 if is_cape else 0.8)
		cloth.set_gravity(i, 0.16 if is_cape else 0.25)
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
