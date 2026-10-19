extends SceneTree
## Real Godot renders of the skinned character, without mission gameplay.
var rig: KhCharacterRig
var viewport: SubViewport
var camera: Camera3D

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://art/references/character/studio"))
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
	env.background_color = Color(0.035,0.043,0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.7,0.76,0.85)
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_AGX
	world.environment = env
	stage.add_child(world)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-35,140,0)
	key.light_color = Color(1,0.92,0.8)
	key.light_energy = 1.8
	stage.add_child(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20,-40,0)
	fill.light_color = Color(0.65,0.76,1)
	fill.light_energy = 0.45
	stage.add_child(fill)
	rig = KhCharacterRig.new()
	stage.add_child(rig)
	rig.build(Color.WHITE, Color(0.25,0.8,1))
	rig.sword.hide()
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.4
	stage.add_child(camera)
	camera.current = true
	for outfit in ["base","tunic"]:
		rig.set_uniform("" if outfit == "base" else "umbral")
		for angle in ["front","three_quarter","back"]:
			camera.position = {"front":Vector3(0,1.18,-5),"three_quarter":Vector3(-3,1.45,-5),"back":Vector3(0,1.18,5)}[angle]
			camera.look_at(Vector3(0,1.02,0))
			await save_view(outfit+"_"+angle)
		camera.position = Vector3(-3,1.45,-5)
		camera.look_at(Vector3(0,1.02,0))
		for i in range(25):
			rig.animate(1.0/60.0,3.6)
			await physics_frame
		await save_view(outfit+"_walk")
		rig.cast("push")
		for i in range(25):
			rig.animate(1.0/60.0,0)
			await physics_frame
		await save_view(outfit+"_cast")
		rig.cancel_action()
		rig.animate(0.1,0)
	print("CHARACTER_STUDIO_OK")
	var report := FileAccess.open("res://art/references/character/studio/report.json",FileAccess.WRITE)
	report.store_string(JSON.stringify({"glb_sha256":FileAccess.get_sha256("res://assets/models/characters/adventurer.glb"),
		"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_current_rendering_method(),
		"resolution":[960,1200],"human_acceptance":"pending","scope":"Real Godot studio captures, not human gameplay QA"},"\t")+"\n")
	quit()

func save_view(label: String) -> void:
	for _i in range(12): await process_frame
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png("res://art/references/character/studio/"+label+".png")
