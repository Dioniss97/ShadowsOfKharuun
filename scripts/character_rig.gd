class_name KhCharacterRig
extends KhRig
## The existing action clock drives a skinned Blender character. NPCs continue
## to use KhRig. Its public action pivots retain the combat timing contract.

const MODEL = preload("res://assets/models/characters/adventurer.glb")
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
	sword.position = Vector3(0, -0.655, -0.06)
	_setup_cloth()

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
	if is_instance_valid(cloth):
		cloth.external_force = global_basis.z*speed*0.018

func _pose(name: String, angles: Vector3) -> void:
	var index := skeleton.find_bone(name)
	if index < 0: return
	var rest := skeleton.get_bone_global_rest(index).basis.orthonormalized()
	var local_rest := skeleton.get_bone_rest(index).basis.orthonormalized()
	skeleton.set_bone_pose_rotation(index, (local_rest*rest.inverse()*Basis.from_euler(angles)*rest).get_rotation_quaternion())

func _setup_cloth() -> void:
	cloth = SpringBoneSimulator3D.new()
	cloth.name = "TunicMotion"
	skeleton.add_child(cloth)
	cloth.setting_count = 6
	for limb in ["thigh_L", "thigh_R", "shin_L", "shin_R"]:
		var collider := SpringBoneCollisionCapsule3D.new()
		collider.name = "ClothGuard_"+limb
		cloth.add_child(collider)
		collider.bone_name = limb
		collider.height = 0.48
		collider.radius = 0.105 if limb.begins_with("thigh") else 0.085
		collider.position_offset = Vector3(0, 0.19, 0)
	for i in range(6):
		cloth.set_root_bone_name(i, "cloth_%d_a" % i)
		cloth.set_end_bone_name(i, "cloth_%d_b" % i)
		cloth.set_extend_end_bone(i, true)
		cloth.set_end_bone_length(i, 0.38)
		cloth.set_center_from(i, SpringBoneSimulator3D.CENTER_FROM_WORLD_ORIGIN)
		cloth.set_stiffness(i, 3.2)
		cloth.set_drag(i, 0.8)
		cloth.set_gravity(i, 0.25)
		cloth.set_radius(i, 0.025)
		cloth.set_enable_all_child_collisions(i, true)
	cloth.active = uniform_id != ""
