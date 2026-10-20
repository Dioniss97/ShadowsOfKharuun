extends SceneTree
## Repeatable Godot inspection cameras for regional character iterations.
var rig: KhCharacterRig
var viewport: SubViewport
var camera: Camera3D
var output := "res://art/references/character/iterations/quality_04/after"
var region := "hand"
var captures: Array[String] = []

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): output = arg.trim_prefix("--out=")
		if arg.begins_with("--region="): region = arg.trim_prefix("--region=")
	call_deferred("capture")

func capture() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	viewport = SubViewport.new()
	viewport.size = Vector2i(960, 1200)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.msaa_3d = Viewport.MSAA_4X
	root.add_child(viewport)
	var stage := Node3D.new()
	viewport.add_child(stage)
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.035, 0.043, 0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.7, 0.76, 0.85)
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_AGX
	world.environment = env
	stage.add_child(world)
	for data in [[Vector3(-35,140,0), Color(1,0.92,0.8), 1.8], [Vector3(-20,-40,0), Color(0.65,0.76,1),0.45]]:
		var light := DirectionalLight3D.new()
		light.rotation_degrees = data[0]
		light.light_color = data[1]
		light.light_energy = data[2]
		stage.add_child(light)
	rig = KhCharacterRig.new()
	stage.add_child(rig)
	rig.build(Color.WHITE, Color(0.25,0.8,1))
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	stage.add_child(camera)
	camera.current = true
	for outfit in ["base", "tunic"]:
		rig.set_uniform("" if outfit == "base" else "umbral")
		rig.sword.hide()
		for pose in ["rest", "guard", "attack", "cast", "walk", "run", "turn", "defeat"] if region == "leg" else ["rest", "guard", "attack", "cast"]:
			rig.dying = false
			rig.position = Vector3.ZERO
			rig.rotation = Vector3.ZERO
			rig.sword.visible = region == "arm" and pose in ["guard","attack"]
			rig.cancel_action()
			rig.guarding = pose == "guard"
			rig.phase = 0.0
			rig.animate(0,0)
			if pose == "attack": rig.swing()
			if pose == "cast": rig.cast("push")
			if pose == "turn": rig.rotation.y = PI/3.0
			if pose == "defeat": rig.dying = true
			for i in range(60 if pose == "defeat" else 24):
				rig.animate(1.0/60.0 if pose in ["attack","cast","walk","run","defeat"] else 0.0, 6.6 if pose == "run" else (3.6 if pose == "walk" else 0.0))
				await physics_frame
			camera.size = 2.4
			for angle in ["front", "three_quarter", "side", "back"] if pose == "rest" else ["three_quarter"]:
				var offset: Vector3 = {"front":Vector3(0,.16,-5),"three_quarter":Vector3(-3,.43,-5),"side":Vector3(5,.16,0),"back":Vector3(0,.16,5)}[angle]
				frame(rig.global_transform*Vector3(0,1.02,0),offset,2.8 if pose == "defeat" else 2.4)
				await save_view(outfit+"_"+pose+"_"+angle)
			for side in [""] if region == "torso" else ["L", "R"]:
				var bone_name: String = "spine" if region == "torso" else (("thigh_" if region == "leg" else "forearm_") if region in ["leg","arm"] else "hand_")+side
				var bone_index := rig.skeleton.find_bone(bone_name)
				var local_focus := Vector3(0,.27,0) if region == "torso" else Vector3(0,.32 if region == "leg" else (0 if region == "arm" else .065),0)
				var focus := rig.skeleton.to_global(rig.skeleton.get_bone_global_pose(bone_index)*local_focus)
				var angles := ["front","side","three_quarter","back"] if region == "torso" else ["front","side","three_quarter"]
				for angle in angles if pose == "rest" else ["three_quarter"]:
					var offset: Vector3 = {"front":Vector3(0,.02,-2),"side":Vector3(-2 if side == "L" else 2,.02,0),"three_quarter":Vector3(-1,.12,-2),"back":Vector3(0,.02,2)}[angle]
					frame(focus,offset,1.50 if region == "leg" else (1.25 if region == "torso" else (.90 if region == "arm" else .29)))
					await save_view(outfit+"_"+region+("_"+side if side != "" else "")+"_"+pose+"_"+angle)
				if region == "hand" and side == "R" and pose in ["guard","attack"]:
					rig.sword.show()
					await save_view(outfit+"_hand_R_"+pose+"_grip")
					rig.sword.hide()
			rig.guarding = false
			rig.cancel_action()
	var report := FileAccess.open(output+"/report.json",FileAccess.WRITE)
	report.store_string(JSON.stringify({"glb_sha256":FileAccess.get_sha256("res://assets/models/characters/adventurer.glb"),"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_current_rendering_method(),"resolution":[960,1200],"captures":captures,"human_acceptance":"pending"},"\t")+"\n")
	print("CHARACTER_DETAIL_OK captures=",captures.size())
	quit()

func frame(focus: Vector3, offset: Vector3, size: float) -> void:
	camera.size = size
	camera.position = focus+offset
	camera.look_at(focus)

func save_view(label: String) -> void:
	for _i in range(8): await process_frame
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png(output+"/"+label+".png")
	captures.append(label)
