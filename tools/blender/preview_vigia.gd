extends SceneTree
## Studio preview of the exported GLB. This is not the temple or mission QA.

const MODEL_PATH := "res://assets/models/environment/vigia_umbral.glb"
const OUTPUT_DIR := "res://art/references/vigia_umbral/"
var stage: Node3D
var camera: Camera3D
var preview_viewport: SubViewport


func _initialize() -> void:
	call_deferred("capture")


func capture() -> void:
	preview_viewport = SubViewport.new()
	preview_viewport.size = Vector2i(960, 1200)
	preview_viewport.own_world_3d = true
	preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	preview_viewport.msaa_3d = Viewport.MSAA_4X
	root.add_child(preview_viewport)
	stage = Node3D.new()
	preview_viewport.add_child(stage)
	var scene := load(MODEL_PATH) as PackedScene
	if scene == null:
		push_error("No se puede importar el GLB del Vigía")
		quit(1)
		return
	stage.add_child(scene.instantiate())
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.025, 0.032, 0.04)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.62, 0.67, 0.73)
	environment.ambient_light_energy = 0.35
	environment.tonemap_mode = Environment.TONE_MAPPER_AGX
	environment.ssao_enabled = true
	environment.ssao_radius = 0.7
	environment.ssao_intensity = 1.2
	var world := WorldEnvironment.new()
	world.environment = environment
	stage.add_child(world)
	var key := DirectionalLight3D.new()
	key.light_color = Color(1.0, 0.95, 0.88)
	key.light_energy = 1.8
	key.shadow_enabled = true
	key.shadow_bias = 0.2
	key.shadow_normal_bias = 2.5
	key.directional_shadow_max_distance = 35.0
	stage.add_child(key)
	key.rotation_degrees = Vector3(-48, -32, 0)
	var fill := DirectionalLight3D.new()
	fill.light_color = Color(0.74, 0.82, 1.0)
	fill.light_energy = 0.45
	stage.add_child(fill)
	fill.rotation_degrees = Vector3(-30, 145, 0)
	var floor_node := MeshInstance3D.new()
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(200, 200)
	floor_node.mesh = floor_mesh
	floor_node.position.y = -0.03
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.065, 0.075, 0.085)
	floor_material.roughness = 0.9
	floor_node.material_override = floor_material
	stage.add_child(floor_node)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	camera.size = 7.1
	camera.current = true
	stage.add_child(camera)
	var material_names: Array[String] = []
	var mesh_count := 0
	for child in stage.find_children("*", "MeshInstance3D", true, false):
		if child == floor_node:
			continue
		mesh_count += 1
		for index in range(child.mesh.get_surface_count()):
			var mat := child.mesh.surface_get_material(index) as BaseMaterial3D
			if mat == null or mat.albedo_texture == null or mat.normal_texture == null or mat.roughness_texture == null:
				push_error("Falta un mapa PBR en el material importado")
				quit(2)
				return
			if not material_names.has(mat.resource_name):
				material_names.append(mat.resource_name)
	if mesh_count != 3 or material_names.size() != 3:
		push_error("El GLB debe tener tres grupos de material")
		quit(3)
		return
	var views := {
		"godot_three_quarter.png": {"position": Vector3(-12, 6.4, 18), "target": Vector3(0, 3.8, 0), "width": 7.1},
		"godot_front.png": {"position": Vector3(0, 4.9, 18), "target": Vector3(0, 3.8, 0), "width": 7.1},
		"godot_profile_right.png": {"position": Vector3(-18, 4.9, 0), "target": Vector3(0, 3.8, 0), "width": 7.1},
		"godot_back.png": {"position": Vector3(0, 4.9, -18), "target": Vector3(0, 3.8, 0), "width": 7.1},
		"godot_detail_cowl.png": {"position": Vector3(-7, 7.8, 16), "target": Vector3(0, 6.1, 0.15), "width": 2.8},
		"godot_detail_shoulders.png": {"position": Vector3(0, 6.2, 18), "target": Vector3(0, 5.48, 0.10), "width": 2.6},
		"godot_detail_stole.png": {"position": Vector3(-5, 4.2, 17), "target": Vector3(0, 2.7, 0.55), "width": 2.96},
		"godot_detail_inscription.png": {"position": Vector3(0, 4.0, 18), "target": Vector3(0, 3.1, 0.60), "width": 1.32},
		"godot_detail_hands.png": {"position": Vector3(-5, 6.5, 17), "target": Vector3(0, 4.83, 0.85), "width": 1.56},
	}
	for filename in views:
		camera.size = views[filename]["width"]
		camera.position = views[filename]["position"]
		camera.look_at(views[filename]["target"])
		for _frame in range(20):
			await process_frame
		await RenderingServer.frame_post_draw
		var image := preview_viewport.get_texture().get_image()
		var result := image.save_png(OUTPUT_DIR + filename)
		if result != OK:
			push_error("No se pudo guardar la captura: " + filename)
			quit(4)
			return
	var report := {
		"iteration": 8,
		"asset": MODEL_PATH,
		"glb_sha256": FileAccess.get_sha256(MODEL_PATH),
		"engine": Engine.get_version_info().string,
		"resolution": [preview_viewport.size.x, preview_viewport.size.y],
		"mesh_groups": mesh_count,
		"materials": material_names,
		"pbr_textures_present": true,
		"external_dependencies": ResourceLoader.get_dependencies(MODEL_PATH),
		"cameras": {"front": [0, 4.9, 18], "three_quarter": [-12, 6.4, 18]},
		"captures": views.keys(),
		"scope": "Actual Godot studio captures; not temple integration or mission QA",
		"visual_findings": ["Historical dark flecks addressed by sRGB fallback and adjacent-surface texel repair; inspect the current captures", "Rebuilt inner cowl/torso transition and upper grip; human acceptance remains pending"],
		"human_acceptance": "pending",
	}
	var report_file := FileAccess.open(OUTPUT_DIR + "godot_import_report.json", FileAccess.WRITE)
	report_file.store_string(JSON.stringify(report, "\t") + "\n")
	print("VIGIA_PREVIEW_OK ", JSON.stringify(report))
	quit()
