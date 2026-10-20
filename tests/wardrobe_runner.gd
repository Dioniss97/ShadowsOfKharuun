extends SceneTree
## Exercises real scene, input and buttons; capture fixtures are identified.
var main: Node
var checks: Array = []
var failures := 0
var capture := false
var output := "res://art/references/character/integration"
var cloth_samples: Array[Quaternion] = []
var cape_samples: Array[Quaternion] = []
var view_metrics: Array = []

func _initialize() -> void:
	capture = "--wardrobe-capture" in OS.get_cmdline_user_args()
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	checks.append({"name":label,"passed":condition})
	if not condition:
		failures += 1
		push_error(label)
	print("PASS " if condition else "FAIL ",label)

func frames(count: int) -> void:
	for _i in range(count): await process_frame

func key(code: Key) -> void:
	for pressed in [true,false]:
		var e := InputEventKey.new()
		e.physical_keycode = code
		e.pressed = pressed
		Input.parse_input_event(e)
		await frames(3)

func click(button: Button) -> void:
	var point: Vector2 = root.get_final_transform()*button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	Input.parse_input_event(motion)
	await frames(2)
	for pressed in [true,false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.position = point
		e.pressed = pressed
		Input.parse_input_event(e)
		await frames(3)

func snap(label: String) -> void:
	if not capture: return
	await frames(15)
	var intervals: Array[float] = []
	var previous := Time.get_ticks_usec()
	for _i in range(30):
		await RenderingServer.frame_post_draw
		var now := Time.get_ticks_usec()
		intervals.append((now-previous)/1000.0)
		previous = now
	intervals.sort()
	view_metrics.append({"view":label,"frame_interval_median_ms":intervals[15],"frame_interval_p95_ms":intervals[28],
		"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		"texture_memory_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED),
		"scope":"30 frame presentation intervals, includes CPU/render/presentation; not GPU-only or FPS guarantee"})
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(output+"/"+label+".png") == OK,"Capture "+label)

func roles(rig: KhCharacterRig, uniform: bool) -> bool:
	for mesh in rig.mesh_roles:
		var role: String = rig.mesh_roles[mesh]
		var expected := role == "always" or (role == "uniform" if uniform else role in ["body","base"])
		if mesh.visible != expected: return false
	return rig.mesh_roles.size() == 4

func hand_skin_valid(rig: KhCharacterRig) -> bool:
	var finger_vertices := {"base":0,"uniform":0}
	for instance in rig.mesh_roles:
		var role: String = rig.mesh_roles[instance]
		if role not in finger_vertices: continue
		var mesh_instance := instance as MeshInstance3D
		for surface in range(mesh_instance.mesh.get_surface_count()):
			var arrays := mesh_instance.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
			var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
			if weights.size() != vertices.size()*4: return false
			for vertex in range(vertices.size()):
				var total := 0.0
				var has_finger := false
				for influence in range(4):
					var index := vertex*4+influence
					var weight := weights[index]
					total += weight
					if weight <= 0.00001: continue
					var bind := bones[index]
					if bind < 0 or bind >= mesh_instance.skin.get_bind_count(): return false
					var bone_name := String(mesh_instance.skin.get_bind_name(bind))
					if bone_name.is_empty(): bone_name = rig.skeleton.get_bone_name(mesh_instance.skin.get_bind_bone(bind))
					if bone_name.begins_with("finger_"): has_finger = true
				if absf(total-1.0)>0.002: return false
				if has_finger: finger_vertices[role] += 1
	return finger_vertices.base>200 and finger_vertices.uniform>200

func forearm_seam_valid(rig: KhCharacterRig) -> bool:
	var sides := {"base":{},"body":{}}
	for instance in rig.mesh_roles:
		var role: String = rig.mesh_roles[instance]
		if role not in sides: continue
		for surface in range(instance.mesh.get_surface_count()):
			var arrays: Array = instance.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
			for i in range(vertices.size()):
				if vertices[i].y<1.01 or vertices[i].y>1.12: continue
				sides[role][vertices[i].snapped(Vector3.ONE*0.00001)] = [normals[i],uv[i]]
	var shared := 0
	for position in sides.base:
		if not sides.body.has(position): continue
		shared += 1
		if sides.base[position][0].distance_to(sides.body[position][0])>0.002: return false
		if sides.base[position][1].distance_to(sides.body[position][1])>0.0001: return false
	return shared>20

func check_hands(rig: KhCharacterRig) -> void:
	var all_fingers := true
	for side in ["L","R"]:
		for finger in range(1,6):
			for segment in range(3):
				all_fingers = all_fingers and rig.skeleton.find_bone("finger_%s_%d_%d" % [side,finger,segment])>=0
	check(all_fingers,"Thirty articulated finger joints imported")
	check(hand_skin_valid(rig),"Finger joints deform both bare hands and uniform gloves with four normalized influences")
	check(forearm_seam_valid(rig),"Forearm visibility seam preserves common normals and skin texture coordinates")
	rig.cancel_action()
	rig.animate(0.0,0.0)
	var wrist := rig.skeleton.find_bone("hand_L")
	var left_finger := rig.skeleton.find_bone("finger_L_3_1")
	var rest_wrist := rig.skeleton.get_bone_pose_rotation(wrist)
	var rest_finger := rig.skeleton.get_bone_pose_rotation(left_finger)
	var right_hand := rig.skeleton.global_transform*rig.skeleton.get_bone_global_pose(rig.skeleton.find_bone("hand_R"))
	var grip := rig.sword.get_node("SwordGrip") as MeshInstance3D
	var grip_mesh := grip.mesh as CylinderMesh
	check(rig.sword.to_global(Vector3(0,0.04,0)).distance_to(right_hand*Vector3(0,.085,.025))<0.001 and is_equal_approx(grip_mesh.top_radius,.02),"Sword grip follows the posed palm with a four centimetre diameter")
	rig.cast("push")
	rig.animate(0.4,0.0)
	var left_hand := rig.skeleton.global_transform*rig.skeleton.get_bone_global_pose(wrist)
	var palm_tracks := rig.left_palm.global_position.distance_to(left_hand*Vector3(0,.085,.015))<0.001
	var opens := rest_wrist.angle_to(rig.skeleton.get_bone_pose_rotation(wrist))>1.0 and rest_finger.angle_to(rig.skeleton.get_bone_pose_rotation(left_finger))>0.10 and palm_tracks
	rig.cancel_action()
	rig.animate(0.0,0.0)
	check(opens and rest_wrist.angle_to(rig.skeleton.get_bone_pose_rotation(wrist))<0.001,"Free hand opens for powers, effect origin follows palm and relaxed pose returns")

func fabric_normals_valid(rig: KhCharacterRig) -> bool:
	var cloth := false
	var leather := false
	for instance in rig.mesh_roles:
		if rig.mesh_roles[instance] != "uniform": continue
		for surface in range(instance.mesh.get_surface_count()):
			var mat := instance.get_active_material(surface) as StandardMaterial3D
			if mat == null or not mat.normal_enabled or mat.normal_texture == null: continue
			var arrays: Array = instance.mesh.surface_get_arrays(surface)
			if arrays[Mesh.ARRAY_TANGENT] == null: return false
			if arrays[Mesh.ARRAY_TANGENT].size() != arrays[Mesh.ARRAY_VERTEX].size()*4: return false
			if mat.normal_texture.get_width() != 512 or mat.normal_texture.get_height() != 512: return false
			cloth = cloth or mat.resource_name.begins_with("Robe_graphite")
			leather = leather or mat.resource_name.begins_with("Leather_dark")
	return cloth and leather

func cape_anchor_valid(rig: KhCharacterRig) -> bool:
	var anchored := 0
	for instance in rig.mesh_roles:
		if rig.mesh_roles[instance] != "uniform": continue
		for surface in range(instance.mesh.get_surface_count()):
			var mat := instance.get_active_material(surface) as StandardMaterial3D
			if mat == null or not mat.resource_name.begins_with("Robe_slate"): continue
			var arrays: Array = instance.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
			var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
			for i in range(vertices.size()):
				if vertices[i].y<1.528 or vertices[i].z<.08 or absf(vertices[i].x)>.16: continue
				var spine_weight := 0.0
				for influence in range(4):
					var bind := bones[i*4+influence]
					var name := String(instance.skin.get_bind_name(bind))
					if name.is_empty(): name = rig.skeleton.get_bone_name(instance.skin.get_bind_bone(bind))
					if name == "spine": spine_weight += weights[i*4+influence]
				if spine_weight<.999: return false
				anchored += 1
	return anchored>=17

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await frames(8)
	check(not main.open_inventory(),"Inventory blocked in menu")
	main.new_game()
	await frames(8)
	var player: KhPlayer = main.level.player
	check(player.wardrobe.uniform_id == "" and roles(player.rig,false),"New game starts with base body/underwear/shoes")
	check(player.rig.skeleton.get_bone_count() == 76,"Imported deforming skeleton has 76 bones including fingers and cape dynamics")
	check_hands(player.rig)
	check(fabric_normals_valid(player.rig),"Cloth and leather import real normal maps with tangent data")
	check(cape_anchor_valid(player.rig),"Imported cape top shares the rigid spine anchor of its clasp")
	check(not player.wardrobe.equip_uniform("missing"),"Unknown item cannot be equipped")
	var original_stats := [player.max_health,player.defence,player.attack_bonus]
	await key(KEY_I)
	check(main.inventory_open and paused and main.inventory_ui.panel.visible,"I opens inventory and pauses gameplay")
	var elapsed: float = main.mission.elapsed
	await frames(10)
	check(main.mission.elapsed == elapsed,"Mission clock frozen in inventory")
	await snap("inventory_base")
	await click(main.inventory_ui.equip_button)
	check(player.wardrobe.uniform_id == KhWardrobe.TUNIC and roles(player.rig,true),"Mouse equip changes complete outfit including body coverage")
	check(main.inventory_ui.preview_rig.uniform_id == KhWardrobe.TUNIC and main.inventory_ui.equip_button.disabled,"3D preview and buttons synchronized")
	check(player.rig.cloth.active and player.rig.cloth.setting_count == 15 and player.rig.cloth.get_child_count() == 8,"Fifteen cloth chains and eight torso, waist, arm and leg collision guards enabled")
	check(original_stats == [player.max_health,player.defence,player.attack_bonus],"Appearance does not change combat statistics")
	await snap("inventory_uniform")
	await click(main.inventory_ui.remove_button)
	check(player.wardrobe.uniform_id == "" and roles(player.rig,false) and not player.rig.cloth.active,"Mouse remove restores all base parts and footwear")
	await key(KEY_ESCAPE)
	check(not paused and not main.inventory_open and not main.paused,"ESC returns to previous running state")
	main.toggle_tactical_pause()
	await key(KEY_I)
	check(main.inventory_open and main.tactical_paused,"Inventory opens over tactical pause")
	await click(main.inventory_ui.equip_button)
	await key(KEY_I)
	check(not main.inventory_open and main.tactical_paused and paused,"I closes and preserves previous tactical pause")
	main.toggle_tactical_pause()
	await frames(4)
	player.automation_mode = true
	player.automation_direction = Vector3.ZERO
	var start: Vector3 = player.global_position
	var cloth_bone := player.rig.skeleton.find_bone("cloth_0_b")
	var cape_bone := player.rig.skeleton.find_bone("cape_4_b")
	player.rig.cloth.modification_processed.connect(func():
		cloth_samples.append(player.rig.skeleton.get_bone_global_pose(cloth_bone).basis.get_rotation_quaternion())
		cape_samples.append(player.rig.skeleton.get_bone_global_pose(cape_bone).basis.get_rotation_quaternion())
	)
	for _i in range(45): await physics_frame
	var pose_before := player.rig.skeleton.get_bone_global_pose(cloth_bone).basis.get_rotation_quaternion()
	var cape_before := player.rig.skeleton.get_bone_global_pose(cape_bone).basis.get_rotation_quaternion()
	cloth_samples.clear()
	cape_samples.clear()
	player.automation_direction = Vector3.FORWARD
	for _i in range(60): await physics_frame
	player.automation_direction = Vector3.ZERO
	for _i in range(8): await physics_frame
	var pose_after := player.rig.skeleton.get_bone_global_pose(cloth_bone).basis.get_rotation_quaternion()
	check(start.distance_to(player.global_position)>1.0,"Skinned character moves with production controller")
	var soles_level := true
	for side in ["L","R"]:
		var foot := player.rig.skeleton.find_bone("foot_"+side)
		var delta := player.rig.skeleton.get_bone_global_pose(foot).basis*player.rig.skeleton.get_bone_global_rest(foot).basis.inverse()
		soles_level = soles_level and delta.get_rotation_quaternion().angle_to(Quaternion.IDENTITY)<0.003
	check(soles_level,"Ankle compensation preserves sole orientation during the existing stride")
	var max_motion := pose_before.angle_to(pose_after)
	for sample in cloth_samples: max_motion = maxf(max_motion,pose_before.angle_to(sample))
	print("CLOTH_MAX_ANGLE ",max_motion," samples ",cloth_samples.size())
	check(max_motion>0.001,"Tunic reacts during real movement")
	check(player.rig.skeleton.get_bone_global_pose(cloth_bone).origin.is_finite(),"Cloth remains finite after movement")
	var max_cape_motion := cape_before.angle_to(player.rig.skeleton.get_bone_global_pose(cape_bone).basis.get_rotation_quaternion())
	for sample in cape_samples: max_cape_motion = maxf(max_cape_motion,cape_before.angle_to(sample))
	print("CAPE_MAX_ANGLE ",max_cape_motion," samples ",cape_samples.size())
	check(max_cape_motion>0.001,"Separate cape reacts during real movement")
	check(player.rig.skeleton.get_bone_global_pose(cape_bone).origin.is_finite(),"Cape remains finite after movement")
	# Frozen-placement capture is visual evidence, not a human playthrough.
	if capture:
		player.set_physics_process(false)
		var camera: Camera3D = main.level.menu_camera
		camera.position = player.global_position+Vector3(-2.7,1.9,-4.3)
		camera.look_at(player.global_position+Vector3(0,1.05,0))
		camera.fov = 36
		camera.make_current()
		await snap("temple_uniform")
		player.wardrobe.remove_uniform()
		await snap("temple_base")
	main.mission.transition(KhMission.State.DIALOGUE)
	check(not main.open_inventory(),"Inventory blocked during dialogue")
	main.show_menu()
	main.new_game()
	await frames(8)
	check(main.level.player.wardrobe.uniform_id == "" and not main.inventory_open and not paused,"Restart clears wardrobe and inventory pause")
	main.mission.transition(KhMission.State.DEFEAT)
	check(not main.open_inventory(),"Inventory blocked after defeat")
	var report := {"checks":checks,"failures":failures,"engine":Engine.get_version_info().string,
		"glb_sha256":FileAccess.get_sha256("res://assets/models/characters/adventurer.glb"),
		"renderer":RenderingServer.get_current_rendering_method(),"capture":capture,
		"clean_import":"--clean-import" in OS.get_cmdline_user_args(),"views":view_metrics,
		"human_acceptance":"pending","scope":"Real input and production scene; visual captures use frozen placement. Not human QA."}
	var file := FileAccess.open(output+("/gpu_report.json" if capture else "/logic_report.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")+"\n")
	print("WARDROBE_RESULT checks=",checks.size()," failures=",failures)
	quit(0 if failures == 0 else 1)
