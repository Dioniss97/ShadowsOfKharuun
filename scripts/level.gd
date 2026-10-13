class_name KhLevel
extends Node3D

signal reached_gate
signal npc_interacted(enemy: KhEnemy)
var player: KhPlayer
var enemies: Array = []
var guardian: KhEnemy
var combat: Node
var duel_mode = false
var fx: KhEffects
var audio: KhAudio
var menu_camera: Camera3D
var mission: KhMission
var gate_triggered = false
var stone: ShaderMaterial
var lighter: ShaderMaterial
var bronze: StandardMaterial3D
var red: StandardMaterial3D
var rng = RandomNumberGenerator.new()
var module_scene = preload("res://scenes/architecture.tscn")
var temple_gate: StaticBody3D
var portal_surface: MeshInstance3D
var relic: MeshInstance3D
var relic_label: Label3D
var relic_position = Vector3(0,3.3,-34.5)
var temple_open = false

func can_talk(enemy: KhEnemy) -> bool:
	if not combat.enabled or not combat.selection_valid(enemy) or enemy.active: return false
	return mission.state in [KhMission.State.EXPLORATION, KhMission.State.GUARDIAN_WAIT, KhMission.State.TEMPLE]

func request_talk(enemy: KhEnemy) -> bool:
	if not can_talk(enemy): return false
	player.interaction_target = enemy
	combat.last_result = "Acercándose para hablar con %s" % enemy.display_name
	return true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	rng.seed = 4772
	stone = ShaderMaterial.new()
	stone.shader = preload("res://assets/basalt.gdshader")
	stone.set_shader_parameter("base_color",Color(0.10,0.115,0.14))
	lighter = stone.duplicate()
	lighter.set_shader_parameter("base_color",Color(0.16,0.16,0.175))
	bronze = KhGeometry.material(Color(0.35,0.215,0.095),0.42)
	red = KhGeometry.material(Color(0.5,0.13,0.055))
	build_environment()
	build_courtyard()
	build_temple()
	build_horizon()
	fx = KhEffects.new()
	add_child(fx)
	audio = KhAudio.new()
	add_child(audio)
	spawn_actors()
	menu_camera = Camera3D.new()
	add_child(menu_camera)
	menu_camera.position = Vector3(15,9.5,23)
	menu_camera.look_at(Vector3(-11,10,-22))
	menu_camera.fov = 62
	menu_camera.current = true
	player.visible = false

func build_environment() -> void:
	var we = WorldEnvironment.new()
	add_child(we)
	var env = Environment.new()
	we.environment = env
	env.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	var sm = ShaderMaterial.new()
	sm.shader = preload("res://assets/sky.gdshader")
	sky.sky_material = sm
	sky.radiance_size = Sky.RADIANCE_SIZE_128
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.52,0.53,0.65)
	env.ambient_light_energy = 0.70
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.1
	env.glow_enabled = true
	env.glow_intensity = 0.5
	env.glow_bloom = 0.06
	env.fog_enabled = true
	env.fog_light_color = Color(0.28,0.12,0.10)
	env.fog_density = 0.0035
	env.fog_height = -5
	env.fog_height_density = 0.03
	env.fog_sky_affect = 0.0
	var sun = DirectionalLight3D.new()
	add_child(sun)
	sun.rotation_degrees = Vector3(-32,-32,0)
	sun.light_color = Color(1,0.71,0.51)
	sun.light_energy = 1.5
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 95
	var fill = DirectionalLight3D.new()
	add_child(fill)
	fill.rotation_degrees = Vector3(-55,145,0)
	fill.light_color = Color(0.40,0.51,0.73)
	fill.light_energy = 0.85

func module(kind: String, pos: Vector3, turn: float = 0.0) -> Node3D:
	var m = module_scene.instantiate()
	m.kind = kind
	m.stone = stone
	m.position = pos
	m.rotation.y = turn
	add_child(m)
	return m

func build_courtyard() -> void:
	KhGeometry.box(self,Vector3(0,-0.45,0),Vector3(40,0.9,55),stone,true)
	KhGeometry.box(self,Vector3(0,-0.80,0),Vector3(260,0.3,240),KhGeometry.material(Color(0.22,0.085,0.046)))
	# The floor is one physical surface with separate visual stone slabs.
	for x in range(-7,8):
		for z in range(-9,10):
			KhGeometry.box(self,Vector3(x*2.55,0.015,z*2.75),Vector3(2.49,0.026,2.68),stone if (x+z)%4 else lighter)
	KhGeometry.box(self,Vector3(0,0.04,9),Vector3(7.4,0.035,33),lighter)
	for x in [-3.8,3.8]:
		KhGeometry.box(self,Vector3(x,0.065,9),Vector3(0.09,0.025,33),bronze)
	for z in range(-4,25,4):
		KhGeometry.box(self,Vector3(0,0.07,z),Vector3(1.6,0.018,0.11),bronze)
	for radius in [4.9,5.3,6.0]:
		KhGeometry.ring(self,Vector3(0,0.075,-4.5),radius,bronze,0.035)
	for x in [-19.8,19.8]:
		KhGeometry.box(self,Vector3(x,1.2,0),Vector3(0.7,2.4,55),stone,true)
		KhGeometry.box(self,Vector3(x,2.4,0),Vector3(1.1,0.24,55),lighter)
		for z in [-24,-16,-8,0,8,16,24]:
			KhGeometry.box(self,Vector3(x,2.7,z),Vector3(1.35,0.9,1.35),stone)
	KhGeometry.box(self,Vector3(0,0.8,27.1),Vector3(40,1.6,0.8),stone,true)
	for side in [-1,1]:
		KhGeometry.box(self,Vector3(side*12.5,5,-27.6),Vector3(15,10,0.8),stone,true)
	for x in [-14.5,14.5]:
		for z in [-4,6,17]:
			module("column",Vector3(x,0,z))
		for z in [-8,2,13,23]:
			module("brazier",Vector3(x*0.63,0,z))
		module("obelisk",Vector3(x,0,24))
	for x in [-10.8,10.8]:
		module("statue",Vector3(x,0,-13.8),0 if x < 0 else -0.05)
	for i in range(18):
		var side = -1 if i%2 else 1
		var pos = Vector3(side*rng.randf_range(16.4,18.6),0.20,rng.randf_range(-20,23))
		var rock = KhGeometry.sphere(self,pos,rng.randf_range(0.4,0.9),stone)
		rock.scale = Vector3(1.4,0.9,1.1)
		rock.rotation = Vector3(rng.randf(),rng.randf()*TAU,rng.randf())
	# Wind-borne embers: one inexpensive emitter for the entire courtyard.
	var ash = GPUParticles3D.new()
	add_child(ash)
	ash.position = Vector3(0,6,0)
	ash.amount = 80
	ash.lifetime = 9
	ash.visibility_aabb = AABB(Vector3(-25,-8,-35),Vector3(50,25,70))
	var pm = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(18,5,24)
	pm.direction = Vector3(1,0.2,0.2)
	pm.initial_velocity_min = 0.3
	pm.initial_velocity_max = 0.8
	pm.gravity = Vector3(0,0.04,0)
	pm.scale_min = 0.6
	pm.scale_max = 1.2
	ash.process_material = pm
	var speck = SphereMesh.new()
	speck.radius = 0.015
	speck.height = 0.03
	speck.material = KhGeometry.material(Color(1,0.36,0.06),0.4,2.0)
	ash.draw_pass_1 = speck

func build_temple() -> void:
	KhGeometry.box(self,Vector3(0,1.2,-22.5),Vector3(28,2.4,9),stone,true)
	# Visual steps never provide collision: a single convex ramp handles traversal.
	for i in range(16):
		var h = (i+1)*0.15
		KhGeometry.box(self,Vector3(0,h*0.5,-10.25-i*0.5),Vector3(10.5,h,0.5),lighter)
		KhGeometry.box(self,Vector3(0,h+0.018,-10.02-i*0.5),Vector3(10.5,0.025,0.055),bronze)
	var ramp = StaticBody3D.new()
	add_child(ramp)
	var collider = CollisionShape3D.new()
	var wedge = ConvexPolygonShape3D.new()
	wedge.points = PackedVector3Array([
		Vector3(-5.3,-0.1,-10),Vector3(5.3,-0.1,-10),Vector3(-5.3,0,-10),Vector3(5.3,0,-10),
		Vector3(-5.3,-0.1,-18),Vector3(5.3,-0.1,-18),Vector3(-5.3,2.4,-18),Vector3(5.3,2.4,-18)])
	collider.shape = wedge
	ramp.add_child(collider)
	for side in [-1,1]:
		KhGeometry.box(self,Vector3(side*6.0,1.2,-14),Vector3(0.8,2.4,8),stone,true)
		KhGeometry.box(self,Vector3(side*8.0,8.3,-24.5),Vector3(5.4,11.8,7),stone,true)
		KhGeometry.box(self,Vector3(side*15.5,7.0,-29),Vector3(9.8,14,18),stone)
		KhGeometry.box(self,Vector3(side*5.1,8.7,-20.9),Vector3(0.52,12.6,0.55),bronze)
		module("brazier",Vector3(side*4.1,2.4,-19.3))
		for x in range(3):
			KhGeometry.box(self,Vector3(side*(11.3+x*2.5),7.8,-19.88),Vector3(0.35,9.5,0.4),bronze)
		KhGeometry.box(self,Vector3(side*8,15,-24),Vector3(6.6,1.0,8),lighter)
		var banner = MeshInstance3D.new()
		var plane = PlaneMesh.new()
		plane.orientation = PlaneMesh.FACE_Z
		plane.size = Vector2(2.1,7.4)
		banner.mesh = plane
		var bm = ShaderMaterial.new()
		bm.shader = preload("res://assets/banner.gdshader")
		banner.material_override = bm
		add_child(banner)
		banner.position = Vector3(side*8.1,10.1,-20.88)
		KhGeometry.box(self,Vector3(side*8.1,13.9,-20.8),Vector3(2.65,0.12,0.15),bronze)
	KhGeometry.box(self,Vector3(0,15.1,-24.1),Vector3(23,1.4,8),lighter)
	KhGeometry.box(self,Vector3(0,16.0,-24.1),Vector3(26,0.4,9),bronze)
	for tier in range(6):
		KhGeometry.box(self,Vector3(0,16.8+tier*1.5,-30.5-tier*0.2),Vector3(28-tier*3.4,1.5,14-tier*1.25),stone)
	KhGeometry.cylinder(self,Vector3(0,29,-31.5),3.6,10,stone,0.1,4).rotation.y = PI/4
	portal_surface = KhGeometry.box(self,Vector3(0,8,-27.02),Vector3(9.6,11.1,0.18),KhGeometry.material(Color(0.014,0.008,0.016)))
	temple_gate = StaticBody3D.new()
	add_child(temple_gate)
	var seal = CollisionShape3D.new()
	var seal_shape = BoxShape3D.new()
	seal_shape.size = Vector3(9.6,9.0,0.5)
	seal.shape = seal_shape
	seal.position = Vector3(0,6.5,-26.9)
	temple_gate.add_child(seal)
	# A small chamber completes the existing temple objective, without a new zone.
	KhGeometry.box(self,Vector3(0,2.2,-32.5),Vector3(9.6,0.4,14),lighter,true)
	for side in [-1,1]:
		KhGeometry.box(self,Vector3(side*4.9,5.2,-32.5),Vector3(0.4,6,14),stone,true)
	KhGeometry.box(self,Vector3(0,5.2,-39.5),Vector3(10,6,0.4),stone,true)
	KhGeometry.cylinder(self,Vector3(0,2.75,-34.5),0.7,0.7,bronze)
	relic = KhGeometry.sphere(self,relic_position,0.3,KhGeometry.material(Color(0.5,0.85,1),0.2,3))
	relic_label = Label3D.new()
	add_child(relic_label)
	relic_label.position = Vector3(0,4.8,-34.5)
	relic_label.text = "NÚCLEO DE KHARUUN\n[E] Reclamar"
	relic_label.font_size = 44
	relic_label.pixel_size = 0.007
	relic_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	relic_label.modulate = Color(0.7,0.9,1)
	relic_label.outline_size = 8
	relic_label.hide()
	KhGeometry.light(self,relic_position,Color(0.4,0.7,1),3,8)
	# Portal carvings and an original geometric sigil.
	var rune = KhGeometry.material(Color(1,0.24,0.045),0.4,2.2)
	for side in [-1,1]:
		for i in range(8):
			KhGeometry.box(self,Vector3(side*4.1,4.4+i*1.12,-26.87),Vector3(0.18,0.48,0.06),rune)
	var sigil = KhGeometry.ring(self,Vector3(0,9.9,-26.82),1.85,rune,0.047)
	sigil.rotation.x = PI/2
	KhGeometry.box(self,Vector3(0,9.7,-26.73),Vector3(0.1,3.7,0.1),rune)
	KhGeometry.box(self,Vector3(0,9.7,-26.72),Vector3(2.6,0.10,0.1),rune).rotation.z = -0.7
	KhGeometry.box(self,Vector3(0,9.7,-26.72),Vector3(2.6,0.10,0.1),rune).rotation.z = 0.7
	KhGeometry.light(self,Vector3(0,7,-23),Color(1,0.16,0.05),3.6,13)

func build_horizon() -> void:
	for i in range(30):
		var angle = float(i)/30*TAU
		var distance = rng.randf_range(75,125)
		var h = rng.randf_range(14,38)
		var p = Vector3(sin(angle)*distance,h*0.5-0.8,cos(angle)*distance)
		var mountain = KhGeometry.mesh(self,mountain_mesh(rng.randf_range(14,29),h),p-Vector3(0,h*0.5,0),KhGeometry.material(Color(0.085,0.041,0.049)))
		mountain.rotation.y = rng.randf()*TAU
	for side in [-1,1]:
		var citadel = Node3D.new()
		add_child(citadel)
		citadel.position = Vector3(side*51,0,-52)
		for tier in range(5):
			KhGeometry.box(citadel,Vector3(0,2+tier*4,0),Vector3(25-tier*4,4,23-tier*3),stone)
		KhGeometry.cylinder(citadel,Vector3(0,27,0),2.8,14,stone,0,4).rotation.y = PI/4
		for x in [-12,12]:
			KhGeometry.cylinder(citadel,Vector3(x,11,2),2.0,22,stone,1.3,4)

func mountain_mesh(radius: float, height: float) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var peak = Vector3(radius*0.18,height,-radius*0.13)
	var rim: Array[Vector3] = []
	for i in range(9):
		var a = float(i)/9.0*TAU
		var r = radius*rng.randf_range(0.75,1.25)
		rim.append(Vector3(cos(a)*r,rng.randf_range(0,2),sin(a)*r))
	for i in range(9):
		var a = rim[i]
		var b = rim[(i+1)%9]
		var mid = (a+b+peak)/3+Vector3(rng.randf_range(-3,3),rng.randf_range(-2,2),rng.randf_range(-3,3))
		for triangle in [[a,mid,b],[a,peak,mid],[mid,peak,b]]:
			for v in triangle: st.add_vertex(v)
	st.generate_normals()
	return st.commit()

func spawn_actors() -> void:
	player = preload("res://scenes/player.tscn").instantiate()
	player.position = Vector3(0,0.1,6) if duel_mode else Vector3(0,0.1,22)
	add_child(player)
	var positions = [Vector3(-5,0.1,-6),Vector3(5,0.1,-7),Vector3(3,0.1,-3)]
	for i in range(1 if duel_mode else 4):
		var e = preload("res://scenes/enemy.tscn").instantiate()
		e.guardian = i == 3
		e.tactical_mode = true
		if not duel_mode:
			e.max_health = 160
			e.health = e.max_health
			e.display_name = "Acólito %s" % ["del Juramento", "de la Ceniza", "del Umbral"][mini(i,2)]
		if duel_mode:
			e.display_name = "Centinela del umbral"
			e.max_health = 360
			e.health = e.max_health
		e.level = self
		e.target = player
		e.position = Vector3(0,0.1,-2) if duel_mode else (positions[i] if i < 3 else Vector3(0,2.5,-21))
		add_child(e)
		e.rig.rotation.y = PI
		enemies.append(e)
		if i == 3 or duel_mode: guardian = e
	combat = KhTacticalCombat.new()
	combat.player = player
	combat.level = self
	add_child(combat)
	player.combat = combat

func begin_mission() -> void:
	player.visible = true
	player.control_enabled = true
	player.camera.make_current()
	player.snap_camera()
	gate_triggered = false
	combat.enabled = true

func _process(_delta: float) -> void:
	if mission != null and mission.state == KhMission.State.EXPLORATION and not gate_triggered:
		if player.global_position.z < -10.0:
			gate_triggered = true
			player.interaction_target = null
			reached_gate.emit()
	var npc = player.interaction_target
	if is_instance_valid(npc) and not npc.active and player.global_position.distance_to(npc.global_position) <= 3.8:
		var ray = PhysicsRayQueryParameters3D.create(player.global_position+Vector3.UP,npc.global_position+Vector3.UP,1)
		if get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
			player.interaction_target = null
			player.velocity.x = 0
			player.velocity.z = 0
			player.face_target(npc.global_position)
			npc_interacted.emit(npc)

func start_acolytes() -> void:
	combat.enabled = true
	for e in enemies:
		if not e.guardian: e.activate()

func start_boss() -> void:
	combat.enabled = true
	guardian.activate()
	fx.wave(guardian.global_position,4,Color(1,0.12,0.03))

func open_temple() -> void:
	temple_open = true
	temple_gate.collision_layer = 0
	portal_surface.hide()
	relic_label.show()
	if mission.guardian_resolution == "peaceful":
		guardian.stop_tactical()
		guardian.rig.combat_stance = false
		guardian.position = Vector3(3.5,2.5,-22)
	fx.wave(relic_position,1.7,Color(0.4,0.8,1))

func claim_relic() -> bool:
	if not temple_open or mission.state != KhMission.State.TEMPLE or player.global_position.distance_to(relic_position) > 2.3: return false
	if not mission.claim_temple(): return false
	relic.hide()
	relic_label.hide()
	return true

func stop_combat() -> void:
	combat.enabled = false
	combat.stop()
	player.control_enabled = false
	player.interaction_target = null
	player.automation_direction = Vector3.ZERO
	for e in enemies:
		e.active = false
		e.telegraph.visible = false
		e.stop_tactical()
