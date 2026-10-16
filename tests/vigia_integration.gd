extends SceneTree

# Real mission scene; fixed actor placement only for comparable art captures.
# Gameplay regressions and the normal playthrough run separately in temple_runner.
var main: Node
var report: Dictionary = {}
var failures: Array = []
var phase := "after"
var output := ""

func _initialize() -> void:
	if "--before" in OS.get_cmdline_user_args(): phase = "before"
	output = "res://art/references/vigia_umbral/integration/"+phase
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error(message)

func frames(count: int) -> void:
	for _i in range(count): await process_frame

func collisions(node: Node, result: Array) -> void:
	if node is CollisionShape3D and node.shape != null:
		var entry = {"position":str(node.global_position),"basis":str(node.global_basis),
			"shape":node.shape.get_class(),"disabled":node.disabled}
		if node.shape is BoxShape3D: entry["size"] = str(node.shape.size)
		elif node.shape is CapsuleShape3D:
			entry["radius"] = node.shape.radius
			entry["height"] = node.shape.height
		elif node.shape is ConvexPolygonShape3D: entry["points"] = str(node.shape.points)
		result.append(JSON.stringify(entry))
	for child in node.get_children(): collisions(child,result)

func find_statues() -> Array:
	var statues: Array = []
	for child in main.level.get_children():
		if child.get("kind") == "statue": statues.append(child)
	return statues

func capture_view(label: String, eye: Vector3, target: Vector3, fov: float) -> void:
	var camera: Camera3D = main.level.menu_camera
	camera.global_position = eye
	camera.look_at(target)
	camera.fov = fov
	camera.make_current()
	await frames(35)
	var times: Array = []
	var last_tick := Time.get_ticks_usec()
	for _i in range(60):
		await RenderingServer.frame_post_draw
		var tick := Time.get_ticks_usec()
		times.append((tick-last_tick)/1000.0)
		last_tick = tick
	times.sort()
	var image: Image = root.get_texture().get_image()
	check(image.get_size() == Vector2i(1280,720),"Resolution 1280x720: "+label)
	var path := output+"/"+label+".png"
	check(image.save_png(ProjectSettings.globalize_path(path)) == OK,"Save "+path)
	report["views"].append({"name":label,"camera":str(eye),"target":str(target),"fov":fov,
		"file":label+".png","sha256":FileAccess.get_sha256(path),
		"frame_interval_median_ms":times[30],"frame_interval_p95_ms":times[56],
		"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"rendered_primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		"texture_memory_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)})

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await frames(8)
	main.new_game()
	await frames(8)
	main.level.player.set_physics_process(false)
	main.level.player.global_position = Vector3(0,0.1,1.5)
	main.level.player.velocity = Vector3.ZERO
	for actor in main.level.enemies: actor.set_physics_process(false)
	# Let the normal chapter announcement fade before it covers the sculpture.
	await create_timer(5.0).timeout
	var statues := find_statues()
	check(statues.size() == 2,"Exactly two statues")
	var statue_records: Array = []
	for statue in statues:
		var models: Array = []
		for child in statue.get_children():
			if child.scene_file_path.ends_with("vigia_umbral.glb"):
				models.append({"resource":child.scene_file_path,"transform":str(child.transform)})
		if phase == "after": check(models.size() == 1,"Each statue uses the GLB once")
		else: check(models.is_empty(),"Baseline requires the provisional statue module")
		statue_records.append({"position":str(statue.position),"rotation":str(statue.rotation),"models":models})
	if not failures.is_empty():
		quit(1)
		return
	var collision_records: Array = []
	collisions(main.level,collision_records)
	collision_records.sort()
	report = {"phase":phase,"engine":Engine.get_version_info().string,
		"renderer":RenderingServer.get_current_rendering_method(),"resolution":[1280,720],
		"glb_sha256":FileAccess.get_sha256("res://assets/models/environment/vigia_umbral.glb"),
		"statues":statue_records,"collisions":collision_records,"views":[],
		"fixture":"Production mission/environment; actors frozen/placed for visual comparison; no gameplay validation here",
		"performance_scope":"60 rendered frame intervals per view, includes CPU/presentation; not GPU-only timing or a gameplay FPS guarantee"}
	await capture_view("courtyard",Vector3(0,3.4,13),Vector3(0,5.5,-16),62)
	await capture_view("stairs",Vector3(0,4.5,-2),Vector3(0,5.5,-16),72)
	await capture_view("close_left",Vector3(-5.5,5.4,-5),Vector3(-10.8,4.3,-13.8),48)
	await capture_view("close_right",Vector3(15.8,5.1,-6),Vector3(10.8,4.3,-13.8),48)
	main.mission.transition(KhMission.State.DIALOGUE)
	main.dialogue.choose(0)
	main.dialogue.continue_dialogue()
	await frames(8)
	main.tactical_ui.hide_help()
	main.level.combat.select_target(main.level.enemies[0])
	await capture_view("combat",Vector3(0,3.8,7),Vector3(0,3.8,-12),64)
	if phase == "after":
		var before = JSON.parse_string(FileAccess.get_file_as_string(output.get_base_dir()+"/before/report.json"))
		check(before != null,"Baseline report exists")
		if before != null:
			check(before.collisions == collision_records,"Collision geometry/transforms unchanged")
			for i in range(statues.size()):
				check(before.statues[i].position == statue_records[i].position and before.statues[i].rotation == statue_records[i].rotation,"Statue parent transforms unchanged")
			for i in range(report.views.size()):
				check(before.views[i].camera == report.views[i].camera and before.views[i].target == report.views[i].target and before.views[i].fov == report.views[i].fov,"Comparable cameras: "+report.views[i].name)
	report["failures"] = failures
	var file := FileAccess.open(output+"/report.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	file.close()
	print("VIGIA_INTEGRATION_RESULT ",phase," failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
