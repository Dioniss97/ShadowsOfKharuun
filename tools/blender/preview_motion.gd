extends SceneTree
## Controlled root path and production action poses, not player-input QA.
var rig: KhCharacterRig
var viewport: SubViewport
var camera: Camera3D
var output := "res://art/references/character/iterations/quality_10/after"
var samples: Array = []
var captures: Array[String] = []
var invalid := 0
var latest: Array[Quaternion] = []
var reference: Array[Quaternion] = []
var max_angle := 0.0

func sample_cloth() -> void:
	latest.clear()
	for chain in range(15):
		var bone := rig.skeleton.find_bone(("cloth_%d_b" % chain) if chain<6 else ("cape_%d_b" % (chain-6)))
		var pose := rig.skeleton.get_bone_global_pose(bone)
		if not pose.origin.is_finite() or not pose.basis.is_finite(): invalid += 1
		latest.append(pose.basis.get_rotation_quaternion())
		if reference.size() == 15: max_angle = maxf(max_angle,reference[chain].angle_to(latest[chain]))

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): output = arg.trim_prefix("--out=")
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	viewport = SubViewport.new()
	viewport.size = Vector2i(960,1200)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.msaa_3d = Viewport.MSAA_4X
	root.add_child(viewport)
	var stage := Node3D.new()
	viewport.add_child(stage)
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(.035,.043,.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(.7,.76,.85)
	env.ambient_light_energy = .5
	env.tonemap_mode = Environment.TONE_MAPPER_AGX
	world.environment = env
	stage.add_child(world)
	for data in [[Vector3(-35,140,0),Color(1,.92,.8),1.8],[Vector3(-20,-40,0),Color(.65,.76,1),.45]]:
		var light := DirectionalLight3D.new()
		light.rotation_degrees = data[0]
		light.light_color = data[1]
		light.light_energy = data[2]
		stage.add_child(light)
	rig = KhCharacterRig.new()
	stage.add_child(rig)
	rig.build(Color.WHITE,Color(.25,.8,1))
	rig.set_uniform("umbral")
	rig.cloth.modification_processed.connect(sample_cloth)
	rig.sword.hide()
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.45
	stage.add_child(camera)
	camera.current = true
	for action in ["rest","walk","run","turn","guard","attack","cast","settle"]:
		rig.cancel_action()
		rig.guarding = action == "guard"
		if action == "attack": rig.swing()
		if action == "cast": rig.cast("push")
		max_angle = 0.0
		var intervals: Array[float] = []
		var previous := Time.get_ticks_usec()
		reference.assign(latest)
		for frame in range(180 if action == "settle" else 90):
			var speed := 6.6 if action == "run" else (3.6 if action in ["walk","turn"] else 0.0)
			if action == "turn": rig.rotation.y += PI/90.0
			rig.position -= rig.basis.z*speed/60.0
			rig.animate(1.0/60.0,speed)
			await physics_frame
			await process_frame
			var now := Time.get_ticks_usec()
			intervals.append((now-previous)/1000.0)
			previous = now
			if frame in ([179] if action == "settle" else ([89] if action == "rest" else [11,29,59])):
				await snap(action+"_%03d" % frame)
		intervals.sort()
		samples.append({"action":action,"frames":intervals.size(),"max_chain_angle_from_action_start_rad":max_angle,"median_frame_ms":intervals[intervals.size()/2],"p95_frame_ms":intervals[int(intervals.size()*.95)],"invalid_poses":invalid})
	var report := FileAccess.open(output+"/report.json",FileAccess.WRITE)
	report.store_string(JSON.stringify({"glb_sha256":FileAccess.get_sha256("res://assets/models/characters/adventurer.glb"),"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_current_rendering_method(),"resolution":[960,1200],"scope":"Controlled root translation/180-degree turn and production actions; presentation intervals include capture stalls, not GPU timings or a benchmark. Actual controller covered separately by wardrobe_runner.","samples":samples,"captures":captures,"invalid_poses":invalid,"human_acceptance":"pending"},"\t")+"\n")
	print("CHARACTER_MOTION_OK captures=",captures.size()," invalid=",invalid)
	quit(0 if invalid == 0 else 1)

func snap(label: String) -> void:
	for angle in ["front","back"]:
		var focus := rig.global_position+Vector3(0,1.02,0)
		camera.position = focus+rig.basis*(Vector3(-3,.43,-5) if angle == "front" else Vector3(2,.30,5))
		camera.look_at(focus)
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png(output+"/"+label+"_"+angle+".png")
		captures.append(label+"_"+angle)
