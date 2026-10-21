extends SceneTree
## Standalone deformation review. Does not instantiate or replace a game actor.
const DRIVER = preload("res://tools/blender/studio_trial_pose.gd")
const PROBE = preload("res://tools/blender/studio_trial_probe.gd")
const MODEL_PATH := "res://assets/models/characters/studio_trial/studio_rig_trial.glb"
const OUTPUT := "res://art/references/character/studio_rig_trial"
var viewport: SubViewport
var stage: Node3D
var model: Node3D
var camera: Camera3D
var sword: Node3D
var driver: RefCounted
var probe: RefCounted
var interactive := false
var verify_only := false
var mode := "rest"
var elapsed := 0.0
var yaw := 0.0
var detail := false
var scale_view := 2.12
var captures: Array[String] = []
var results: Dictionary = {}
var checks: Array = []
var failures := 0
var floor_samples: Array = []

func _initialize() -> void:
	interactive = "--interactive" in OS.get_cmdline_user_args()
	verify_only = "--verify" in OS.get_cmdline_user_args()
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	viewport = SubViewport.new()
	viewport.size = Vector2i(960,1100)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.msaa_3d = Viewport.MSAA_4X
	root.add_child(viewport)
	stage = Node3D.new()
	viewport.add_child(stage)
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(.04,.052,.065)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(.72,.78,.86)
	env.ambient_light_energy = .55
	env.tonemap_mode = Environment.TONE_MAPPER_AGX
	world.environment = env
	stage.add_child(world)
	for data in [[Vector3(-32,140,0),Color(1,.93,.84),1.6],[Vector3(-24,-35,0),Color(.72,.82,1),.55]]:
		var light := DirectionalLight3D.new()
		light.rotation_degrees = data[0]
		light.light_color = data[1]
		light.light_energy = data[2]
		light.shadow_enabled = false
		stage.add_child(light)
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(10,10)
	floor_mesh.mesh = plane
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(.07,.09,.11)
	floor_mat.roughness = 1
	floor_mesh.material_override = floor_mat
	floor_mesh.position.y = -.008
	stage.add_child(floor_mesh)
	model = load(MODEL_PATH).instantiate()
	stage.add_child(model)
	driver = DRIVER.new()
	driver.setup(model)
	probe = PROBE.new()
	probe.setup(model,driver.skeleton)
	# Engine-side neutral materials make shape and skinning the subject of review.
	for instance in model.find_children("*","MeshInstance3D",true,false):
		for surface in instance.mesh.get_surface_count():
			var mat := instance.get_active_material(surface) as StandardMaterial3D
			if mat != null:
				var copy := mat.duplicate() as StandardMaterial3D
				copy.roughness = .78
				copy.metallic_specular = .22
				instance.set_surface_override_material(surface,copy)
	sword = Node3D.new()
	stage.add_child(sword)
	shaft("Handle",float(driver.config.grip_radius),float(driver.config.grip_length),0,Color(.20,.13,.075))
	shaft("Guard",.030,.018,.115,Color(.32,.29,.22))
	shaft("Blade",.012,.88,.56,Color(.24,.72,.84),true)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = scale_view
	stage.add_child(camera)
	camera.current = true
	apply("rest")
	if interactive:
		build_ui()
		if "--ui-smoke" in OS.get_cmdline_user_args():
			for i in 12: await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OUTPUT+"/viewer.png")
			quit()
		return
	await audit()
	if not verify_only:
		await capture_all()
	var report := {"checks":checks,"failures":failures,"grip_samples":results,"captures":captures,
		"glb_sha256":FileAccess.get_sha256(MODEL_PATH),"engine":Engine.get_version_info().string,
		"renderer":RenderingServer.get_current_rendering_method(),"scope":"isolated deformation trial; not mission gameplay",
		"human_acceptance":"pending","capture":not verify_only,"feet_samples":floor_samples}
	var interpolation_clear := true
	for sample in results.values():
		interpolation_clear = interpolation_clear and sample.penetrating_vertices == 0 and sample.intersecting_triangles == 0
	report["diagnostic_grasp_interpolation_clear"] = interpolation_clear
	report["known_limitations"] = ["The fixed-hilt open/closed hand interpolation is a pose diagnostic, not a gameplay pickup animation.","No finger/finger, cloth, guard or blade collision checks.","Base shirt, shorts and shoes are first fit prototypes with plain materials; no uniform, cloth motion or clothing intersection probe.","In-place diagnostic gait, not the gameplay controller; no final skin materials."]
	var file := FileAccess.open(OUTPUT+("/logic_report.json" if verify_only else "/gpu_report.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")+"\n")
	print("STUDIO_TRIAL_RESULT checks=",checks.size()," failures=",failures)
	quit(0 if failures == 0 else 1)

func shaft(name: String, radius: float, height: float, y: float, color: Color, glow: bool = false) -> void:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 32
	node.mesh = mesh
	node.position.y = y
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = .7
	if glow:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 1.4
	node.material_override = mat
	sword.add_child(node)

func apply(value: String, phase: float = 0, closure: float = 1) -> void:
	driver.pose(value,phase,closure)
	model.rotation.y = sin(phase)*.9 if value == "turn" else 0.0
	driver.skeleton.force_update_all_bone_transforms()
	sword.global_transform = driver.grip_transform()
	sword.visible = value == "grip"
	frame_view(Vector3(0,.94,0),Vector3(-2,1,-5),scale_view)

func frame_view(focus: Vector3, offset: Vector3, size: float) -> void:
	camera.size = size
	camera.position = focus+offset.rotated(Vector3.UP,yaw)
	camera.look_at(focus)

func check(ok: bool, message: String) -> void:
	checks.append({"ok":ok,"message":message})
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",message)

func audit() -> void:
	check(driver.skeleton.get_bone_count() == 53,"Imported complete deform rig has 53 named bones")
	check(probe.weight_errors == 0 and probe.bind_errors == 0,"Imported skin weights are normalized and every bind resolves")
	for value in ["native","rest","shoulder","walk","turn"]:
		var finite := true
		for phase in [0.0,PI*.5,PI,PI*1.5]:
			apply(value,phase)
			for i in driver.skeleton.get_bone_count():
				finite = finite and driver.skeleton.get_bone_global_pose(i).origin.is_finite()
		check(finite,"Finite transforms across "+value+" motion samples")
	for sample in 21:
		var closure := float(sample)/20.0
		apply("grip",0,closure)
		var result: Dictionary = probe.evaluate(driver.grip_transform(),driver.config.grip_radius,driver.config.grip_length)
		results[str(closure)] = result
		check(result.non_finite_vertices == 0,"Finite imported skin during grip closure "+str(closure))
		if closure == 1.0:
			check(result.sampled_vertices > 100,"Grip probe covers the imported right hand")
			check(result.penetrating_vertices == 0 and result.intersecting_triangles == 0,"Closed grip skin clears the shaft within 0.5 mm")
	var feet_clear := true
	for i in 32:
		apply("walk",TAU*float(i)/32.0)
		var sample: Dictionary = probe.feet_height()
		feet_clear = feet_clear and sample.minimum_y_m >= -.0081 and sample.minimum_y_m <= .0051
		floor_samples.append(sample)
	var low_support := INF
	var high_support := -INF
	var support_failures: Array[int] = []
	for i in floor_samples.size():
		low_support = minf(low_support,float(floor_samples[i].minimum_y_m))
		high_support = maxf(high_support,float(floor_samples[i].minimum_y_m))
		if floor_samples[i].minimum_y_m < -.0081 or floor_samples[i].minimum_y_m > .0051: support_failures.append(i)
	print("WALK_FOOT_SUPPORT min_y=",low_support," max_y=",high_support," failing_samples=",support_failures)
	check(feet_clear and low_support >= -.0081 and high_support <= .0051,
		"Walk samples retain floor support within 0.1 mm numeric tolerance")
	apply("rest")
	var before: Transform3D = driver.skeleton.get_bone_global_pose(driver.bones.hand_R)
	for i in 10:
		apply("grip",0,1)
		apply("rest")
	var after: Transform3D = driver.skeleton.get_bone_global_pose(driver.bones.hand_R)
	check(before.is_equal_approx(after),"Returning from grip restores the neutral hand transform")

func capture_all() -> void:
	for value in ["native","rest","shoulder"]:
		apply(value)
		for angle in ["front","three_quarter","side","back"]:
			var offset: Vector3 = {"front":Vector3(0,.1,-5),"three_quarter":Vector3(-3,.4,-5),"side":Vector3(5,.1,0),"back":Vector3(0,.1,5)}[angle]
			frame_view(Vector3(0,.94,0),offset,2.08)
			await snap(value+"_"+angle)
		if value != "native":
			frame_view(Vector3(.10,1.35,0),Vector3(-2,.4,-5),.85)
			await snap(value+"_shoulder_detail")
		if value == "rest":
			frame_view(driver.grip_transform().origin,Vector3(-2,.3,-3),.32)
			await snap("rest_hand_oblique")
	for closure in [0.0,.25,.5,.75,1.0]:
		apply("grip",0,closure)
		var focus: Vector3 = sword.global_position
		frame_view(focus,Vector3(-2,.2,-4),.32)
		await snap("grip_close_"+str(roundi(closure*100)))
	apply("grip")
	await snap("grip_full")
	for angle in ["front","back","side","oblique"]:
		var offset: Vector3 = {"front":Vector3(0,.1,-3),"back":Vector3(0,.1,3),"side":Vector3(3,.1,0),"oblique":Vector3(-2,.3,-3)}[angle]
		frame_view(sword.global_position,offset,.32)
		await snap("grip_hand_"+angle)
	for angle in ["palm","dorsal","thumb"]:
		var local_offset: Vector3 = {"palm":Vector3(-1,.1,3),"dorsal":Vector3(1,.1,-3),"thumb":Vector3(-3,.2,1)}[angle]
		frame_view(sword.global_position,sword.global_basis*local_offset,.32)
		await snap("grip_hand_"+angle)
	for i in 16:
		apply("walk",TAU*float(i)/16)
		frame_view(Vector3(0,.94,0),Vector3(-3,.45,-5),2.08)
		await snap("walk_%02d" % i)
	for i in 4:
		apply("turn",TAU*float(i)/4)
		await snap("turn_%02d" % i)

func snap(name: String) -> void:
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	var absolute_path := ProjectSettings.globalize_path(OUTPUT+"/"+name+".png")
	var image := viewport.get_texture().get_image()
	var file := FileAccess.open(absolute_path,FileAccess.WRITE)
	if file == null:
		push_error("Could not open preview capture %s: %s" % [absolute_path,FileAccess.get_open_error()])
	else:
		file.store_buffer(image.save_png_to_buffer())
		file.close()
	captures.append(name)

func build_ui() -> void:
	var image := TextureRect.new()
	image.texture = viewport.get_texture()
	root.add_child(image)
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var panel := VBoxContainer.new()
	panel.position = Vector2(16,16)
	root.add_child(panel)
	var title := Label.new()
	title.text = "Prueba de anatomía · Blender Studio"
	panel.add_child(title)
	for item in [["Reposo","rest"],["A-pose original","native"],["Andar","walk"],["Giro","turn"],["Agarre","grip"],["Hombro y codo","shoulder"]]:
		var button := Button.new()
		button.text = item[0]
		button.pressed.connect(func(): mode = item[1])
		panel.add_child(button)
	var hand := CheckButton.new()
	hand.text = "Detalle de mano"
	hand.toggled.connect(func(value: bool): detail = value)
	panel.add_child(hand)
	var hint := Label.new()
	hint.text = "A/D: girar vista · W/S: zoom · Esc: salir"
	panel.add_child(hint)

func _process(delta: float) -> bool:
	if not interactive or driver == null: return false
	elapsed += delta
	if Input.is_physical_key_pressed(KEY_ESCAPE): quit()
	if Input.is_physical_key_pressed(KEY_A): yaw -= delta
	if Input.is_physical_key_pressed(KEY_D): yaw += delta
	if Input.is_physical_key_pressed(KEY_W): scale_view = maxf(.3,scale_view-delta)
	if Input.is_physical_key_pressed(KEY_S): scale_view = minf(3.5,scale_view+delta)
	apply(mode,elapsed*3.2)
	if detail: frame_view(sword.global_position,Vector3(-2,.25,-4),.35)
	return false
