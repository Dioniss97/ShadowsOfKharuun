extends SceneTree
## Frozen placement inside the actual temple; no lighting/material overrides.
var main: Node
var output := "res://art/references/character/integration/final"
var views: Array = []

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	for _i in range(10): await process_frame
	main.new_game()
	for _i in range(10): await process_frame
	var player: KhPlayer = main.level.player
	# Keep presentation reproducible without enemy or player simulation.
	player.set_physics_process(false)
	for enemy in main.level.enemies: enemy.set_physics_process(false)
	player.global_position = Vector3(-7.7,.025,-6.0)
	player.rig.rotation.y = 0.0
	player.yaw = .22
	player.pitch = -.20
	player.snap_camera()
	for _i in range(240): await process_frame
	for outfit in ["base","uniform"]:
		if outfit == "uniform": player.wardrobe.equip_uniform(KhWardrobe.TUNIC)
		else: player.wardrobe.remove_uniform()
		player.rig.animate(0,0)
		player.camera.make_current()
		await snap(outfit+"_game_camera",player.camera,"Production player camera, fixed placement; no player input")
		var camera: Camera3D = main.level.menu_camera
		camera.position = player.global_position+Vector3(2.7,1.9,-4.3)
		camera.look_at(player.global_position+Vector3(0,1.02,0))
		camera.fov = 36
		camera.make_current()
		await snap(outfit+"_near",camera,"Inspection camera in temple, fixed placement")
		camera.position = Vector3(-4.4,2.8,.5)
		camera.look_at(Vector3(-10,2.6,-12.7))
		camera.fov = 62
		await snap(outfit+"_vigia",camera,"Player and existing Vigia in unchanged temple light; different physical scales")
	var report := FileAccess.open(output+"/report.json",FileAccess.WRITE)
	report.store_string(JSON.stringify({"glb_sha256":FileAccess.get_sha256("res://assets/models/characters/adventurer.glb"),"vigia_glb_sha256":FileAccess.get_sha256("res://assets/models/environment/vigia_umbral.glb"),"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_current_rendering_method(),"resolution":[root.size.x,root.size.y],"views":views,"human_acceptance":"pending"},"\t")+"\n")
	print("CHARACTER_TEMPLE_OK views=",views.size())
	quit()

func snap(label: String, camera: Camera3D, scope: String) -> void:
	for _i in range(30): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output+"/"+label+".png")
	views.append({"name":label,"camera_position":str(camera.global_position),"fov":camera.fov,"scope":scope})
