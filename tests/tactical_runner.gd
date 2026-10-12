extends Node

var main: Node
var capture = false
var results: Array = []
var failures = 0
var bot_report: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run")

func check(condition: bool, name: String, details: String = "") -> void:
	results.append({"name": name, "passed": condition, "details": details})
	if condition:
		print("PASS | ", name, " | ", details)
	else:
		failures += 1
		push_error("FAIL | %s | %s" % [name, details])

func frames(count: int) -> void:
	for _index in range(count):
		await get_tree().physics_frame

func fresh_duel() -> void:
	main.new_duel(true)
	await frames(4)

func tap_key(code: Key) -> void:
	var event = InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await frames(2)
	event = InputEventKey.new()
	event.physical_keycode = code
	event.pressed = false
	Input.parse_input_event(event)
	await frames(2)

func click_control(control: Control) -> void:
	var pos = get_viewport().get_final_transform()*control.get_global_rect().get_center()
	var event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = pos
	event.global_position = pos
	Input.parse_input_event(event)
	await frames(2)
	event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = false
	event.position = pos
	event.global_position = pos
	Input.parse_input_event(event)
	await frames(2)

func wait_started(combat: Node, count: int, budget: int) -> bool:
	for _index in range(budget):
		if combat.clock.started_count >= count:
			return true
		if main.mission.state != KhMission.State.DUEL:
			return false
		await get_tree().physics_frame
	return combat.clock.started_count >= count

func player_events(combat: Node) -> Array:
	var selected_events: Array = []
	for event in combat.event_log:
		if event.get("source", "") == "player":
			selected_events.append(event)
	return selected_events

func close_fixture() -> void:
	var player = main.level.player
	var enemy = main.level.enemies[0]
	player.global_position = Vector3(0, 0.1, 1.6)
	player.velocity = Vector3.ZERO
	enemy.global_position = Vector3(0, 0.1, 0)
	enemy.velocity = Vector3.ZERO
	# Freeze only the opponent in isolated player-action tests. Its body remains solid.
	enemy.set_physics_process(false)

func screenshot(name: String) -> void:
	if not capture:
		return
	await RenderingServer.frame_post_draw
	var rendered_image = get_viewport().get_texture().get_image()
	var path = ProjectSettings.globalize_path("res://screenshots/%s.png" % name)
	var error = rendered_image.save_png(path)
	check(error == OK and rendered_image.get_width() > 0, "Captura real: " + name,
		"%dx%d" % [rendered_image.get_width(), rendered_image.get_height()])

func test_clock() -> void:
	var clock = KhRoundQueue.new()
	for id in ["attack", "push", "lightning", "defend"]:
		clock.enqueue({"id": id})
	check(clock.pending.size() == 4 and not clock.enqueue({"id": "attack"}),
		"Reloj: cuatro órdenes pendientes y rechazo de la quinta")
	var removed = clock.cancel(1)
	check(removed and not clock.cancel(-1) and not clock.cancel(9)
		and clock.pending[0].id == "attack" and clock.pending[1].id == "lightning",
		"Reloj: cancelar preserva el orden de las órdenes restantes")
	var started = clock.start(clock.pending.pop_front())
	check(started and clock.current.id == "attack" and not clock.start({"id": "defend"}),
		"Reloj: una sola acción en ejecución")
	clock.advance(0.40)
	check(clock.impact_count == 0 and not clock.impact_done, "Reloj: preparación sin impacto anticipado")
	clock.advance(0.03)
	clock.advance(0.90)
	check(clock.impact_count == 1 and clock.impact_done, "Reloj: un único impacto al cruzar 0,42 segundos")
	clock.advance(3.0)
	clock.advance(99.0)
	check(clock.finished_count == 1 and clock.current.is_empty() and clock.round_left == 0
		and clock.impact_count == 1, "Reloj: final de ronda y avance sobrante sin duplicar daño")
	var interrupted = KhRoundQueue.new()
	interrupted.start({"id": "attack"})
	interrupted.advance(0.1)
	interrupted.interrupt()
	interrupted.advance(0.5)
	check(interrupted.current.is_empty() and interrupted.round_left > 0 and interrupted.impact_count == 0,
		"Reloj: retirada cancela el golpe y conserva recuperación")
	interrupted.enqueue({"id": "defend"})
	interrupted.reset()
	check(interrupted.current.is_empty() and interrupted.pending.is_empty() and interrupted.round_left == 0,
		"Reloj: reinicio elimina acciones y tiempos pendientes")
	var fumble = KhCombatRules.hit_result(1, 999, 1)
	check(not fumble.hit and not fumble.critical and KhCombatRules.scaled_damage(58, fumble) == 0,
		"Reglas: un 1 natural falla sin daño")
	var critical = KhCombatRules.hit_result(20, -99, 999)
	check(critical.hit and critical.critical and KhCombatRules.scaled_damage(58, critical) == 87,
		"Reglas: un 20 natural acierta y multiplica el daño por 1,5")
	check(KhCombatRules.hit_result(5, 7, 12).hit and not KhCombatRules.hit_result(5, 7, 13).hit,
		"Reglas: tirada más bonificación debe alcanzar la defensa")
	var snapshots: Array = []
	for fps in [30,60,144]:
		var timed = KhRoundQueue.new()
		timed.start({"id":"attack"})
		for _i in range(fps*3): timed.advance(1.0/fps)
		snapshots.append([timed.impact_count,timed.finished_count,timed.round_left])
	check(snapshots[0] == snapshots[1] and snapshots[1] == snapshots[2],
		"Rondas: el mismo resultado con pasos de 30, 60 y 144 Hz",str(snapshots))

func test_paused_ui() -> void:
	main.ui.menu.duel_requested.emit()
	await frames(4)
	var player = main.level.player
	var enemy = main.level.enemies[0]
	var combat = main.level.combat
	var tactical_ui = main.tactical_ui
	check(main.mission.state == KhMission.State.DUEL and main.level.duel_mode
		and main.level.enemies.size() == 1 and player.max_health == 340 and enemy.max_health == 360,
		"El menú abre un duelo real con un centinela y estadísticas normales")
	check(main.tactical_paused and get_tree().paused and not main.paused,
		"El duelo comienza en pausa táctica")
	check(tactical_ui.root.visible and tactical_ui.pause_banner.visible
		and tactical_ui.action_buttons.size() == 4 and tactical_ui.queue_buttons.size() == 4,
		"Interfaz táctica visible y operativa mientras el mundo está en pausa")
	var click = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	var click_position = player.camera.unproject_position(enemy.global_position+Vector3(0,1.2,0))
	# Input events arrive in window pixels. Headless uses a 64x64 dummy window,
	# so convert logical viewport coordinates through its scale/letterbox transform.
	click.position = get_viewport().get_final_transform()*click_position
	click.global_position = click.position
	Input.parse_input_event(click)
	await frames(2)
	click = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = false
	click.position = get_viewport().get_final_transform()*click_position
	click.global_position = click.position
	Input.parse_input_event(click)
	check(combat.selected == enemy and combat.engaged,
		"Un clic real sobre la proyección del enemigo selecciona objetivo durante la pausa",str(click_position))
	await tap_key(KEY_3)
	check(combat.queue.size() == 1 and combat.queue[0].id == "attack",
		"El teclado encola ataque durante pausa táctica")
	var repeated = InputEventKey.new()
	repeated.physical_keycode = KEY_3
	repeated.pressed = true
	repeated.echo = true
	Input.parse_input_event(repeated)
	await frames(2)
	check(combat.queue.size() == 1,"Mantener una tecla no rellena la cola mediante autorepetición")
	combat.clear_queue()
	var energy_before: float = player.energy
	for index in [1, 2, 0, 3]:
		await click_control(tactical_ui.action_buttons[index])
	await frames(2)
	check(combat.queue.size() == 4 and player.energy == energy_before
		and combat.clock.started_count == 0 and combat.push_cooldown == 0 and combat.lightning_cooldown == 0,
		"Los botones preparan cuatro órdenes sin consumir energía ni recargas en pausa")
	check(not combat.enqueue_action("attack") and combat.queue.size() == 4,
		"La cola de producción rechaza una quinta orden")
	check(combat.queue[0].id == "push" and combat.queue[1].id == "lightning"
		and combat.queue[0].target == enemy and combat.queue[0].target_name == enemy.display_name,
		"Cada orden conserva su objetivo y el orden de inserción")
	await screenshot("tactical_01_pause")
	tactical_ui.queue_buttons[1].pressed.emit()
	check(combat.queue.size() == 3 and combat.queue[1].id == "attack",
		"Clic en una ranura cancela únicamente esa orden pendiente")
	var player_position: Vector3 = player.global_position
	var enemy_position: Vector3 = enemy.global_position
	var health_before: float = player.health
	var enemy_health_before: float = enemy.health
	var elapsed_before: float = main.mission.elapsed
	await frames(30)
	check(player.global_position == player_position and enemy.global_position == enemy_position
		and player.health == health_before and enemy.health == enemy_health_before
		and player.energy == energy_before and combat.round_left == 0 and enemy.round_clock.round_left == 0
		and main.mission.elapsed == elapsed_before,
		"La pausa congela cuerpos, salud, energía, rondas y cronómetro")
	tactical_ui.clear_button.pressed.emit()
	check(combat.queue.is_empty(), "Limpiar cola funciona desde la interfaz en pausa")
	await tap_key(KEY_SPACE)
	check(not main.tactical_paused and not get_tree().paused,
		"La tecla espacio reanuda el mundo")
	var old_yaw: float = player.yaw
	var window_pos = get_viewport().get_final_transform()*click_position
	var right = InputEventMouseButton.new()
	right.button_index = MOUSE_BUTTON_RIGHT
	right.pressed = true
	right.position = window_pos
	right.global_position = window_pos
	Input.parse_input_event(right)
	var motion = InputEventMouseMotion.new()
	motion.position = window_pos
	motion.global_position = window_pos
	motion.button_mask = MOUSE_BUTTON_MASK_RIGHT
	motion.relative = get_viewport().get_final_transform().basis_xform(Vector2(30,0))
	Input.parse_input_event(motion)
	await frames(3)
	right = InputEventMouseButton.new()
	right.button_index = MOUSE_BUTTON_RIGHT
	right.pressed = false
	right.position = window_pos
	right.global_position = window_pos
	Input.parse_input_event(right)
	check(not is_equal_approx(player.yaw,old_yaw),"Arrastrar con botón derecho gira la cámara con el cursor libre")
	player.yaw = old_yaw
	player.snap_camera()
	main.toggle_tactical_pause()
	await tap_key(KEY_ESCAPE)
	var menu_preserves_pause: bool = main.paused and main.tactical_paused and get_tree().paused
	await tap_key(KEY_ESCAPE)
	check(menu_preserves_pause and not main.paused and main.tactical_paused and get_tree().paused,
		"Escape abre y cierra el menú conservando la pausa táctica")

func test_approach_and_impact() -> void:
	await fresh_duel()
	var player = main.level.player
	var enemy = main.level.enemies[0]
	var combat = main.level.combat
	enemy.set_physics_process(false)
	var start_position: Vector3 = player.global_position
	var health_before: float = enemy.health
	combat.select_target(enemy)
	combat.enqueue_action("attack")
	main.toggle_tactical_pause()
	var started: bool = await wait_started(combat, 1, 250)
	check(started and player.global_position.distance_to(start_position) > 4.0
		and player.global_position.distance_to(enemy.global_position) <= 2.2,
		"La orden hace aproximarse al héroe mediante el movimiento real hasta alcance", str(player.global_position))
	await frames(8)
	check(started and enemy.health == health_before and combat.resolved_actions == 0
		and not combat.current_action.is_empty(),
		"El ataque empieza su animación sin aplicar daño al pulsar ni durante la preparación")
	await screenshot("tactical_02_attack")
	await frames(25)
	var events = player_events(combat)
	var impact_matches: bool = events.size() == 1
	if impact_matches:
		impact_matches = events[0].id == "attack" and is_equal_approx(health_before - enemy.health, float(events[0].damage))
	check(impact_matches and combat.clock.impact_count == 1 and combat.resolved_actions == 1,
		"El impacto aplica una sola vez el resultado real de la tirada, incluido un fallo", str(events))
	await frames(60)
	check(combat.clock.impact_count == 1 and combat.resolved_actions == 1,
		"El resto de la ronda no vuelve a infligir daño")
	var automatic_started: bool = await wait_started(combat, 2, 150)
	check(automatic_started and combat.current_action.get("automatic", false) and combat.queue.is_empty(),
		"La cola vacía continúa con un ataque básico automático")
	await frames(8)
	var sword_tip: Vector3 = player.rig.sword.to_global(Vector3(0, 1.50, 0))
	var front: Vector3 = player.forward()
	check((sword_tip - player.global_position).dot(front) > 0.25
		and front.dot((enemy.global_position - player.global_position).normalized()) > 0.9,
		"El héroe mira al objetivo y la punta del arma queda delante durante el ataque", str(sword_tip))
	if capture:
		main.toggle_tactical_pause()
		var midpoint: Vector3 = (player.global_position + enemy.global_position) * 0.5
		main.level.menu_camera.global_position = midpoint + Vector3(5.4, 2.3, 0.2)
		main.level.menu_camera.look_at(midpoint + Vector3(0, 1.0, 0))
		main.level.menu_camera.make_current()
		await screenshot("tactical_03_side")
		player.camera.make_current()
	enemy.set_physics_process(true)

func test_costs_and_cooldowns() -> void:
	await fresh_duel()
	close_fixture()
	var player = main.level.player
	var enemy = main.level.enemies[0]
	var combat = main.level.combat
	combat.select_target(enemy)
	combat.enqueue_action("push")
	combat.enqueue_action("lightning")
	main.toggle_tactical_pause()
	var first_started: bool = await wait_started(combat, 1, 12)
	check(first_started and combat.current_action.id == "push" and combat.queue.size() == 1
		and player.energy >= 75.9 and player.energy < 77.0 and combat.push_cooldown > 6.8,
		"Energía y recarga de empuje comienzan al ejecutar, no al añadir a la cola", str(player.energy))
	var second_started: bool = await wait_started(combat, 2, 190)
	check(second_started and combat.current_action.id == "lightning" and combat.queue.is_empty()
		and player.energy > 49 and player.energy < 60 and combat.lightning_cooldown > 9.8,
		"La siguiente ronda ejecuta descarga en el orden pedido y cobra su coste", str(player.energy))
	enemy.set_physics_process(true)
	await fresh_duel()
	close_fixture()
	player = main.level.player
	enemy = main.level.enemies[0]
	combat = main.level.combat
	player.energy = 0
	combat.select_target(enemy)
	combat.enqueue_action("lightning")
	main.toggle_tactical_pause()
	await frames(10)
	check(combat.queue.is_empty() and combat.lightning_cooldown == 0
		and combat.ability_error.contains("energía insuficiente")
		and combat.current_action.get("id", "") == "attack",
		"Una habilidad sin energía se descarta sin bloquear el ataque automático")
	enemy.set_physics_process(true)
	await fresh_duel()
	close_fixture()
	player = main.level.player
	enemy = main.level.enemies[0]
	combat = main.level.combat
	combat.select_target(enemy)
	combat.enqueue_action("lightning")
	combat.enqueue_action("lightning")
	main.toggle_tactical_pause()
	await wait_started(combat, 1, 12)
	await frames(180)
	check(combat.clock.started_count == 1 and combat.queue.size() == 1
		and combat.lightning_cooldown > 6.5 and combat.current_action.is_empty(),
		"Una segunda descarga espera a su recarga tras terminar la primera ronda")
	main.toggle_tactical_pause()
	var recarga_before: float = combat.lightning_cooldown
	var health_before: float = enemy.health
	var energy_before: float = player.energy
	await frames(24)
	check(combat.lightning_cooldown == recarga_before and enemy.health == health_before and player.energy == energy_before,
		"La pausa también congela recargas y regeneración ya activas")
	main.tactical_ui.pause_button.pressed.emit()
	var recast_started: bool = await wait_started(combat, 2, 480)
	check(recast_started and combat.current_action.id == "lightning" and combat.lightning_cooldown > 9.8,
		"La descarga pendiente se ejecuta cuando vence su recarga natural")
	enemy.set_physics_process(true)

func test_targets() -> void:
	await fresh_duel()
	close_fixture()
	var player = main.level.player
	var enemy = main.level.enemies[0]
	var combat = main.level.combat
	var invalid = Node.new()
	check(not combat.enqueue_action("attack") and not combat.enqueue_action("unknown")
		and not combat.enqueue_action("attack", invalid) and combat.queue.is_empty(),
		"Órdenes sin objetivo, con identificador desconocido o con un nodo inválido se rechazan")
	invalid.free()
	var temporary = preload("res://scenes/enemy.tscn").instantiate()
	temporary.display_name = "Objetivo de prueba"
	temporary.health = 50
	temporary.max_health = 50
	temporary.level = main.level
	temporary.target = player
	temporary.tactical_mode = true
	main.level.add_child(temporary)
	main.level.enemies.append(temporary)
	temporary.global_position = Vector3(1, 0.1, 0)
	temporary.activate()
	temporary.set_physics_process(false)
	combat.select_target(temporary)
	combat.enqueue_action("attack")
	combat.select_target(enemy)
	combat.enqueue_action("attack")
	check(combat.queue[0].target == temporary and combat.queue[1].target == enemy
		and combat.queue[0].target_name == "Objetivo de prueba",
		"Cambiar la selección conserva el objetivo original de cada orden pendiente")
	temporary.take_damage(temporary.health)
	main.toggle_tactical_pause()
	var valid_started: bool = await wait_started(combat, 1, 12)
	check(valid_started and combat.current_action.target == enemy and combat.queue.is_empty()
		and temporary.mode == KhEnemy.Mode.DEAD,
		"Una orden contra un objetivo muerto se descarta y la siguiente se ejecuta")
	enemy.set_physics_process(true)
	await fresh_duel()
	close_fixture()
	enemy = main.level.enemies[0]
	combat = main.level.combat
	combat.select_target(enemy)
	combat.enqueue_action("attack")
	main.toggle_tactical_pause()
	await wait_started(combat, 1, 12)
	await frames(8)
	var health_before: float = enemy.health
	enemy.global_position += Vector3(0, 0, -8)
	await frames(30)
	var events = player_events(combat)
	check(events.size() == 1 and events[0].get("reason", "") == "range"
		and events[0].damage == 0 and enemy.health == health_before,
		"Un objetivo que sale de alcance durante la preparación evita el impacto")
	enemy.set_physics_process(true)

func test_collision_enemy_and_defence() -> void:
	await fresh_duel()
	var player = main.level.player
	var enemy = main.level.enemies[0]
	var combat = main.level.combat
	player.global_position = Vector3(0, 0.1, 3)
	enemy.global_position = Vector3(0, 0.1, 0)
	enemy.set_physics_process(false)
	combat.disengage()
	player.automation_mode = true
	player.automation_direction = Vector3(0, 0, -1)
	main.toggle_tactical_pause()
	var touched_enemy = false
	for _index in range(100):
		await get_tree().physics_frame
		for collision_index in range(player.get_slide_collision_count()):
			if player.get_slide_collision(collision_index).get_collider() == enemy:
				touched_enemy = true
	check(touched_enemy and player.global_position.z > 0.6 and player.global_position.z < 1.0,
		"El cuerpo del centinela detiene realmente move_and_slide y no puede atravesarse", str(player.global_position))
	player.automation_direction = Vector3.ZERO
	player.automation_mode = false
	enemy.set_physics_process(true)
	await fresh_duel()
	close_fixture()
	player = main.level.player
	enemy = main.level.enemies[0]
	combat = main.level.combat
	combat.disengage()
	player.set_physics_process(false)
	enemy.set_physics_process(true)
	var health_before: float = player.health
	main.toggle_tactical_pause()
	await frames(220)
	var enemy_damage = 0.0
	var enemy_events = 0
	for event in combat.event_log:
		if event.get("source", "") == "enemy":
			enemy_events += 1
			enemy_damage += float(event.get("damage", 0))
	check(enemy_events >= 2 and enemy.attacks >= 2 and combat.resolved_actions == 0
		and not combat.engaged and combat.queue.is_empty(),
		"El enemigo ejecuta sus propias rondas aunque el héroe no tenga órdenes ni ataque")
	check(enemy_damage > 0 and is_equal_approx(health_before - player.health, enemy_damage),
		"El daño enemigo coincide con sus tiradas registradas", str(combat.event_log))
	main.toggle_tactical_pause()
	player.defending_left = 1
	health_before = player.health
	player.take_damage(40)
	check(is_equal_approx(health_before - player.health, 18.0),
		"Defensa reduce el daño recibido al 45 por ciento mediante take_damage")
	player.set_physics_process(true)

func test_defeat_restart() -> void:
	await fresh_duel()
	var player = main.level.player
	player.take_damage(player.max_health * 2)
	await frames(4)
	check(main.mission.state == KhMission.State.DEFEAT and not main.level.combat.enabled,
		"Morir en el duelo dispara derrota y detiene ambas rondas")
	main.ui.restart_requested.emit()
	await frames(4)
	check(main.mission.state == KhMission.State.DUEL and main.level.duel_mode
		and main.level.player.health == 340 and main.level.enemies[0].health == 360
		and main.level.combat.queue.is_empty() and main.tactical_paused,
		"Reiniciar tras derrota conserva el modo duelo y restablece salud, cola y pausa")

func test_enemy_wall_and_stagger() -> void:
	await fresh_duel()
	close_fixture()
	var player = main.level.player
	var enemy = main.level.enemies[0]
	var combat = main.level.combat
	player.set_physics_process(false)
	var obstacle = Node3D.new()
	main.level.add_child(obstacle)
	KhGeometry.box(obstacle,Vector3(0,1.0,0.8),Vector3(2.0,2.0,0.15),KhGeometry.material(Color(0.1,0.1,0.1)),true)
	var health_before: float = player.health
	main.toggle_tactical_pause()
	# A new fixture needs a server step before ray queries see its collision shape.
	await frames(2)
	enemy.set_physics_process(true)
	await frames(150)
	check(enemy.attacks == 0 and enemy.round_clock.started_count == 0 and player.health == health_before,
		"El centinela no inicia ni resuelve ataques a través de una pared cercana")
	player.set_physics_process(true)
	await fresh_duel()
	close_fixture()
	player = main.level.player
	enemy = main.level.enemies[0]
	combat = main.level.combat
	player.set_physics_process(false)
	enemy.set_physics_process(true)
	main.toggle_tactical_pause()
	for _i in range(20):
		await get_tree().physics_frame
		if enemy.round_clock.started_count > 0: break
	await frames(8)
	health_before = player.health
	enemy.take_damage(1,Vector3.RIGHT*2)
	await frames(100)
	check(enemy.round_clock.impact_count == 0 and player.health == health_before
		and enemy.rig.attack_time == 0 and enemy.round_clock.round_left > 0,
		"Un empuje cancela el golpe preparado, sin impactos invisibles al terminar el aturdimiento")
	player.set_physics_process(true)

func test_normal_playthrough() -> void:
	await fresh_duel()
	var player = main.level.player
	var enemy = main.level.enemies[0]
	var combat = main.level.combat
	combat.select_target(enemy)
	for id in ["lightning", "push", "attack", "defend"]:
		combat.enqueue_action(id)
	main.toggle_tactical_pause()
	var played_frames = 0
	for frame in range(3000):
		await get_tree().physics_frame
		played_frames = frame + 1
		if main.mission.state != KhMission.State.DUEL:
			break
		# These are normal production orders. No damage, energy, cooldown or position cheats.
		if frame % 90 == 0 and combat.queue.size() < 2:
			if player.health < 120 and player.defending_left <= 0.2:
				combat.enqueue_action("defend")
			elif combat.lightning_cooldown <= 0 and player.energy >= 32:
				combat.enqueue_action("lightning")
			elif combat.push_cooldown <= 0 and player.energy >= 24:
				combat.enqueue_action("push")
	bot_report = {"frames": played_frames, "seconds": main.mission.elapsed,
		"state": main.mission.state, "hero_health": player.health, "enemy_health": enemy.health,
		"hero_resolved_actions": combat.resolved_actions, "enemy_attacks": enemy.attacks,
		"events": combat.event_log.duplicate(true)}
	check(main.mission.state == KhMission.State.VICTORY and player.health > 0 and enemy.health == 0
		and combat.resolved_actions >= 4 and player.max_health == 340 and enemy.max_health == 360,
		"Una partida completa gana mediante órdenes y ataques automáticos con estadísticas normales", JSON.stringify(bot_report))
	check(main.mission.state == KhMission.State.VICTORY and not combat.enabled and not enemy.active
		and main.mission.kills == 1,
		"La victoria real detiene el duelo y registra la muerte del centinela")
	if main.mission.state == KhMission.State.VICTORY:
		await screenshot("tactical_04_victory")
	main.ui.restart_requested.emit()
	await frames(4)
	check(main.mission.state == KhMission.State.DUEL and main.level.enemies[0].health == 360
		and main.level.player.health == 340 and main.tactical_paused,
		"Repetir tras una victoria conserva el duelo y restablece sus actores")
	main.ui.menu_requested.emit()
	await frames(4)
	check(main.mission.state == KhMission.State.MENU and not get_tree().paused
		and not main.tactical_ui.root.visible,
		"Volver al menú desde el duelo elimina la pausa y oculta sus controles")

func finish() -> void:
	var report = {"engine": Engine.get_version_info(), "renderer": RenderingServer.get_current_rendering_method(),
		"capture": capture, "failures": failures, "checks": results, "normal_playthrough": bot_report}
	var file = FileAccess.open("res://tests/tactical_report.json", FileAccess.WRITE)
	if file == null:
		check(false, "Guardar informe táctico", "FileAccess error %d" % FileAccess.get_open_error())
	else:
		file.store_string(JSON.stringify(report, "\t"))
		file.close()
		file = FileAccess.open("res://tests/tactical_capture_report.json" if capture else "res://tests/tactical_logic_report.json",FileAccess.WRITE)
		file.store_string(JSON.stringify(report,"\t"))
		file.close()
	print("KHARUUN_TACTICAL_RESULT | checks=%d failures=%d" % [results.size(), failures])
	get_tree().quit(0 if failures == 0 else 1)

func run() -> void:
	await frames(8)
	var available: bool = is_instance_valid(main) and main.has_method("new_duel")
	available = available and main.has_method("toggle_tactical_pause") and is_instance_valid(main.tactical_ui)
	available = available and is_instance_valid(main.ui.menu) and main.ui.menu.has_signal("duel_requested")
	check(available, "API de duelo táctico disponible")
	if not available:
		finish()
		return
	test_clock()
	await test_paused_ui()
	await test_approach_and_impact()
	await test_costs_and_cooldowns()
	await test_targets()
	await test_collision_enemy_and_defence()
	await test_enemy_wall_and_stagger()
	await test_defeat_restart()
	await test_normal_playthrough()
	finish()
