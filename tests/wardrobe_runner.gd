extends SceneTree
## Exercises real scene, input and buttons; capture fixtures are identified.
var main: Node
var checks: Array = []
var failures := 0
var capture := false
var output := "res://art/references/character/integration"
var cloth_samples: Array[Quaternion] = []
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
	check(player.rig.skeleton.get_bone_count() == 28,"Imported deforming skeleton has 28 bones")
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
	check(player.rig.cloth.active and player.rig.cloth.get_child_count() == 4,"Cloth chains and four body collision guards enabled")
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
	player.automation_direction = Vector3.FORWARD
	var start: Vector3 = player.global_position
	var cloth_bone := player.rig.skeleton.find_bone("cloth_0_b")
	var pose_before := player.rig.skeleton.get_bone_global_pose(cloth_bone).basis.get_rotation_quaternion()
	player.rig.cloth.modification_processed.connect(func(): cloth_samples.append(player.rig.skeleton.get_bone_global_pose(cloth_bone).basis.get_rotation_quaternion()))
	for _i in range(60): await physics_frame
	player.automation_direction = Vector3.ZERO
	var pose_after := player.rig.skeleton.get_bone_global_pose(cloth_bone).basis.get_rotation_quaternion()
	check(start.distance_to(player.global_position)>1.0,"Skinned character moves with production controller")
	var max_motion := pose_before.angle_to(pose_after)
	for sample in cloth_samples: max_motion = maxf(max_motion,pose_before.angle_to(sample))
	print("CLOTH_MAX_ANGLE ",max_motion," samples ",cloth_samples.size())
	check(max_motion>0.001,"Tunic reacts during real movement")
	check(player.rig.skeleton.get_bone_global_pose(cloth_bone).origin.is_finite(),"Cloth remains finite after movement")
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
		"renderer":RenderingServer.get_current_rendering_method(),"capture":capture,"views":view_metrics,
		"human_acceptance":"pending","scope":"Real input and production scene; visual captures use frozen placement. Not human QA."}
	var file := FileAccess.open(output+("/gpu_report.json" if capture else "/logic_report.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")+"\n")
	print("WARDROBE_RESULT checks=",checks.size()," failures=",failures)
	quit(0 if failures == 0 else 1)
