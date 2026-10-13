extends Node

# Isolated fixtures below may move/freeze actors to test one rule. The separate
# normal-playthrough report uses production stats, real movement and orders only.
var main: Node
var capture = false
var results: Array = []
var failures = 0
var bot_report: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run")

func check(condition: bool, label: String, details: String = "") -> void:
	results.append({"name":label,"passed":condition,"details":details})
	if condition: print("PASS | ",label," | ",details)
	else:
		failures += 1
		push_error("FAIL | %s | %s" % [label,details])

func frames(count: int) -> void:
	for _i in range(count): await get_tree().physics_frame

func tap_key(code: Key) -> void:
	await key_state(code,true)
	await key_state(code,false)

func key_state(code: Key, pressed: bool) -> void:
	var event = InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	await frames(2)

func right_mouse_state(pressed: bool) -> void:
	var point = get_viewport().get_final_transform()*Vector2(1080,180)
	var event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_RIGHT
	event.pressed = pressed
	event.position = point
	event.global_position = point
	Input.parse_input_event(event)
	await frames(2)

func drag_camera(relative: Vector2) -> void:
	await right_mouse_state(true)
	var point = get_viewport().get_final_transform()*Vector2(1080,180)
	var motion = InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	motion.button_mask = MOUSE_BUTTON_MASK_RIGHT
	motion.relative = get_viewport().get_final_transform().basis_xform(relative)
	Input.parse_input_event(motion)
	await frames(3)

func hover_actor(actor: Node3D) -> Vector2:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var point = get_viewport().get_final_transform()*camera.unproject_position(actor.global_position+Vector3.UP)
	var motion = InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	Input.parse_input_event(motion)
	await frames(2)
	return point

func click_actor(actor: Node3D) -> void:
	var point: Vector2 = await hover_actor(actor)
	for pressed in [true,false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = point
		event.global_position = point
		Input.parse_input_event(event)
		await frames(2)

func click_control(control: Control) -> void:
	var pos = get_viewport().get_final_transform()*control.get_global_rect().get_center()
	var motion = InputEventMouseMotion.new()
	motion.position = pos
	motion.global_position = pos
	Input.parse_input_event(motion)
	await frames(2)
	for pressed in [true,false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = pos
		event.global_position = pos
		Input.parse_input_event(event)
		await frames(2)

func wheel_control(control: Control, direction: MouseButton) -> void:
	var pos = get_viewport().get_final_transform()*control.get_global_rect().get_center()
	var event = InputEventMouseButton.new()
	event.button_index = direction
	event.pressed = true
	event.position = pos
	event.global_position = pos
	Input.parse_input_event(event)
	await frames(3)
	var released = InputEventMouseButton.new()
	released.button_index = direction
	released.pressed = false
	released.position = pos
	released.global_position = pos
	Input.parse_input_event(released)
	await frames(2)

func screenshot(name: String) -> void:
	if not capture: return
	await RenderingServer.frame_post_draw
	var rendered = get_viewport().get_texture().get_image()
	var error = rendered.save_png(ProjectSettings.globalize_path("res://screenshots/%s.png" % name))
	check(error == OK and rendered.get_width() >= 1280,"Captura real: "+name,"%dx%d" % [rendered.get_width(),rendered.get_height()])

func wait_started(combat: Node, count: int, budget: int = 240) -> bool:
	for _i in range(budget):
		if combat.clock.started_count >= count: return true
		if not combat.enabled or main.tactical_paused: return false
		await get_tree().physics_frame
	return combat.clock.started_count >= count

func wait_impacts(combat: Node, count: int, budget: int = 100) -> bool:
	for _i in range(budget):
		if combat.clock.impact_count >= count: return true
		if not combat.enabled or main.tactical_paused: return false
		await get_tree().physics_frame
	return combat.clock.impact_count >= count

func player_events(combat: Node) -> Array:
	var found = []
	for event in combat.event_log:
		if event.get("source","") == "player": found.append(event)
	return found

func fresh_encounter(fixture: bool = true) -> void:
	main.show_menu()
	main.new_game()
	await frames(4)
	# This fixture skips exploration; test_normal_playthrough walks the full route.
	main.level.player.global_position = Vector3(0,0.1,-8)
	main.level.player.velocity = Vector3.ZERO
	main.mission.transition(KhMission.State.DIALOGUE)
	main.dialogue.choose(0)
	main.dialogue.continue_dialogue()
	await frames(4)
	main.tactical_ui.hide_help()
	if fixture:
		main.level.player.global_position = Vector3(0,0.1,1.6)
		main.level.player.velocity = Vector3.ZERO
		for i in range(3):
			var enemy = main.level.enemies[i]
			enemy.global_position = Vector3(-0.5 if i == 0 else (0.5 if i == 1 else 7.0),0.1,0)
			enemy.velocity = Vector3.ZERO
			enemy.set_physics_process(false)
		main.level.player.snap_camera()
		await frames(3)

func unpause() -> void:
	if main.tactical_paused: await tap_key(KEY_SPACE)

func test_clock_and_rig() -> void:
	var clock = KhRoundQueue.new()
	var contacts: Array = []
	clock.action_impact.connect(func(order): contacts.append(order.duplicate()))
	for id in ["attack","flurry","heal","medkit"]: clock.enqueue({"id":id})
	check(clock.pending.size() == 4 and not clock.enqueue({"id":"attack"}),"Cola: cuatro pendientes, quinta rechazada")
	check(clock.cancel(1) and not clock.cancel(-1) and clock.pending[1].id == "heal","Cola: retirar una orden preserva las demás")
	clock.start({"id":"flurry","target_name":"A","impact_times":[0.42,0.90]})
	clock.advance(0.4)
	check(contacts.is_empty(),"Ráfaga: ningún impacto antes de preparar el arma")
	clock.advance(0.03)
	check(contacts.size() == 1 and contacts[0].impact_index == 0,"Ráfaga: primer contacto a 0,42 segundos")
	clock.advance(0.47)
	check(contacts.size() == 2 and contacts[1].impact_index == 1 and clock.started_count == 1,"Ráfaga: segundo contacto a 0,90 dentro de la misma acción")
	clock.advance(10.0)
	clock.advance(10.0)
	check(clock.finished_count == 1 and clock.impact_count == 2 and clock.current.is_empty(),"Ráfaga: dos impactos y una ronda, sin duplicados")
	var interrupted = KhRoundQueue.new()
	interrupted.start({"id":"flurry","impact_times":[0.42,0.90]})
	interrupted.advance(0.43)
	interrupted.interrupt()
	interrupted.advance(0.7)
	check(interrupted.impact_count == 1 and interrupted.current.is_empty() and interrupted.round_left > 0,"Ráfaga: interrupción cancela segundo contacto y conserva recuperación")
	var outcomes: Array = []
	for fps in [30,60,144]:
		var timed = KhRoundQueue.new()
		timed.start({"id":"flurry","impact_times":[0.42,0.90]})
		for _i in range(fps*3): timed.advance(1.0/fps)
		outcomes.append([timed.impact_count,timed.finished_count,timed.round_left])
	check(outcomes[0] == outcomes[1] and outcomes[1] == outcomes[2],"Rondas: resultados iguales a 30, 60 y 144 Hz",str(outcomes))
	check(not KhCombatRules.hit_result(1,999,1).hit and KhCombatRules.hit_result(20,-99,999).critical,"Tiradas: fallo natural y crítico conservados")
	var rig = KhRig.new()
	add_child(rig)
	rig.build(Color(0.1,0.2,0.3),Color.CYAN)
	rig.combat_stance = true
	rig.animate(0,0)
	var rest_palm: Vector3 = rig.palm_world_position()
	check(rig.left_palm.get_parent() == rig.left_arm and rig.sword.get_parent() == rig.right_arm,"Rig: mano izquierda libre, sable en mano derecha")
	for kind in ["push","lightning","heal","medkit"]:
		rig.cast(kind)
		rig.animate(0.42,0)
		check(rig.left_arm.rotation.x > 1.4 and (rig.palm_world_position()-rest_palm).dot(Vector3.FORWARD)>0.4,"Gesto izquierdo y palma real: "+kind)
		rig.cancel_action()
		rig.animate(0,0)
	rig.swing_flurry()
	rig.animate(0.42,0)
	var first: bool = rig.right_arm.rotation.distance_to(Vector3(0.18,0.22,0.14))<0.001
	rig.animate(0.26,0)
	var prepared_again: bool = rig.right_arm.rotation.x > 1.3
	rig.animate(0.22,0)
	check(first and prepared_again and rig.right_arm.rotation.distance_to(Vector3(0.23,-0.18,0.10))<0.001,"Rig: ráfaga prepara y conecta dos golpes visibles")
	check((rig.sword.global_basis*Vector3.UP).dot(Vector3.FORWARD)>0.7,"Rig: espada apunta delante en el contacto")
	rig.cancel_action()
	check(rig.attack_time == 0,"Rig: cancelar corta la animación actual")
	rig.queue_free()

func test_encounter_and_pause() -> void:
	await fresh_encounter()
	var level = main.level
	var combat = level.combat
	var player = level.player
	check(main.mission.state == KhMission.State.COMBAT and not level.duel_mode and combat is KhTacticalCombat,"Misión principal utiliza combate táctico")
	check(level.enemies.size() == 4 and level.enemies[0].tactical_mode and not level.guardian.active,"Tres acólitos tácticos y guardián neutral")
	check(main.tactical_paused and get_tree().paused and combat.selected != null,"Encuentro: selecciona agresor y pausa inicial una vez")
	check(combat.medkits == 3 and not KhTacticalCombat.ACTIONS.has("defend"),"Tres botiquines y Defensa retirada del catálogo")
	var state = [player.global_position,player.health,player.energy,main.mission.elapsed,combat.round_left,level.enemies[0].global_position]
	await frames(30)
	check(state == [player.global_position,player.health,player.energy,main.mission.elapsed,combat.round_left,level.enemies[0].global_position],"Pausa congela física, salud, energía, cronómetro y rondas",str(state)+" -> "+str([player.global_position,player.health,player.energy,main.mission.elapsed,combat.round_left,level.enemies[0].global_position]))
	await unpause()
	await frames(8)
	combat.select_target(level.enemies[1])
	await frames(5)
	check(not main.tactical_paused and not get_tree().paused,"Cambiar de objetivo no repite la pausa del encuentro")
	await tap_key(KEY_SPACE)
	check(main.tactical_paused,"Espacio pausa manualmente")
	await tap_key(KEY_ESCAPE)
	var held = main.paused and main.tactical_paused and get_tree().paused
	await tap_key(KEY_ESCAPE)
	check(held and not main.paused and main.tactical_paused and get_tree().paused,"Escape conserva la pausa táctica previa")

func test_targets_and_fallback() -> void:
	await fresh_encounter()
	var combat = main.level.combat
	var a = main.level.enemies[0]
	var b = main.level.enemies[1]
	combat.clear_queue()
	combat.select_target(a)
	combat.enqueue_action("attack")
	combat.select_target(b)
	combat.enqueue_action("flurry")
	combat.select_target(a)
	combat.enqueue_action("attack")
	combat.enqueue_action("heal")
	combat.select_target(b)
	check(combat.queue[0].target == a and combat.queue[1].target == b and combat.queue[2].target == a and combat.queue[3].target == main.level.player,"Cada orden conserva destinatario y curación es propia")
	await unpause()
	var started = await wait_started(combat,1)
	combat.select_target(b)
	check(started and combat.current_action.target == a,"Cambiar selección no redirige la acción en ejecución")
	var fallback = await wait_started(combat,5,1000)
	check(fallback and combat.current_action.id == "attack" and combat.current_action.automatic and combat.current_action.target == a and combat.last_offensive_target == a,"1A, 2B, 2A y curación continúan con básico A")
	var events = player_events(combat)
	check(events.size() >= 5 and events[0].target_instance_id == a.get_instance_id() and events[1].target_instance_id == b.get_instance_id() and events[2].target_instance_id == b.get_instance_id() and events[3].target_instance_id == a.get_instance_id() and events[4].id == "heal","Registro prueba dos tiradas de ráfaga y destinatarios A/B",str(events))
	main.toggle_tactical_pause()
	combat.clear_queue()
	combat.clock.reset()
	main.level.player.rig.cancel_action()
	a.take_damage(a.health)
	await unpause()
	await wait_started(combat,6,220)
	check(combat.last_offensive_target == b and combat.current_action.target == b and combat.current_action.get("automatic",false) and not main.tactical_paused,"Caída de último destinatario continúa automáticamente con otro agresor sin nueva pausa")
	check(not combat.target_valid(main.level.guardian) and not combat.select_target(main.level.guardian),"Guardián neutral excluido de selección y órdenes")

func test_flurry_invalid_second_contact() -> void:
	for cause in ["dead","range","wall"]:
		await fresh_encounter()
		var combat = main.level.combat
		var a = main.level.enemies[0]
		var b = main.level.enemies[1]
		combat.select_target(a)
		combat.enqueue_action("flurry")
		await unpause()
		await wait_impacts(combat,1)
		var b_health = b.health
		var a_health = a.health
		if cause == "dead": a.take_damage(a.health)
		elif cause == "range": a.global_position += Vector3(0,0,-8)
		else:
			var obstacle = Node3D.new()
			main.level.add_child(obstacle)
			KhGeometry.box(obstacle,Vector3(-0.25,1.0,0.8),Vector3(1.2,2.0,0.12),KhGeometry.material(Color.GRAY),true)
		await wait_impacts(combat,2)
		var events = player_events(combat)
		var correct: bool = events.size() == 2 and events[1].impact_index == 1 and events[1].damage == 0 and events[1].target_instance_id == a.get_instance_id()
		if correct: correct = events[1].get("reason","") == ("invalid_target" if cause == "dead" else "range")
		check(correct and b.health == b_health and (cause == "dead" or a.health == a_health),"Ráfaga segundo contacto sin transferencia: "+cause,str(events))
		check(combat.resolved_actions == 1 and combat.clock.started_count == 1,"Ráfaga conserva una acción: "+cause)

func test_resources() -> void:
	await fresh_encounter()
	var combat = main.level.combat
	var player = main.level.player
	combat.disengage()
	combat.enqueue_action("medkit")
	combat.enqueue_action("heal")
	check(combat.medkits == 3 and player.energy == player.max_energy and combat.queue[0].target == player and combat.queue[1].target == player,"Encolar botiquín y curación no consume recursos")
	combat.clear_queue()
	check(combat.medkits == 3 and player.energy == player.max_energy,"Cancelar órdenes pendientes conserva recursos")
	combat.enqueue_action("medkit")
	await unpause()
	await wait_started(combat,1)
	check(combat.medkits == 2 and player.health == player.max_health and combat.round_left > 2.4,"Botiquín con salud llena consume unidad y ronda al ejecutar")
	await wait_impacts(combat,1)
	var events = player_events(combat)
	check(events.size() == 1 and events[0].healing == 0 and combat.medkits == 2,"Botiquín con salud llena no duplica consumo")
	combat.enqueue_action("heal")
	await wait_started(combat,2,200)
	check(player.energy < 73.0 and combat.current_action.target == player and combat.round_left > 2.4,"Poder curativo con salud llena consume energía y ronda")
	await wait_impacts(combat,2)
	check(player_events(combat)[1].healing == 0,"Poder curativo muestra cero curación con salud llena")
	main.toggle_tactical_pause()
	combat.disengage()
	combat.clock.reset()
	player.health = player.max_health-50
	combat.enqueue_action("medkit")
	await unpause()
	await wait_impacts(combat,3)
	check(player.health == player.max_health and combat.medkits == 1,"Botiquín cura parcialmente hasta el máximo")
	main.toggle_tactical_pause()
	combat.disengage()
	combat.clock.reset()
	combat.medkits = 1
	for _i in range(3): combat.enqueue_action("medkit")
	var baseline = combat.clock.started_count
	await unpause()
	await frames(210)
	check(combat.medkits == 0 and combat.queue.is_empty() and combat.clock.started_count == baseline+1 and not combat.enqueue_action("medkit"),"Agotamiento descarta excedentes y nunca deja contador negativo")
	await fresh_encounter()
	combat = main.level.combat
	player = main.level.player
	combat.select_target(main.level.enemies[0])
	combat.enqueue_action("lightning")
	combat.enqueue_action("lightning")
	await unpause()
	await wait_started(combat,2,220)
	check(combat.clock.started_count == 2 and combat.current_action.id == "lightning" and player.energy > 35 and player.energy < 48,"Dos descargas consecutivas separadas solo por ronda, sin recarga extra")
	await fresh_encounter()
	combat = main.level.combat
	player = main.level.player
	combat.enqueue_action("heal")
	combat.enqueue_action("lightning")
	player.energy = 0
	await unpause()
	await frames(5)
	check(not main.tactical_paused and not get_tree().paused and combat.queue.is_empty() and combat.clock.started_count == 0 and combat.round_left > 2.4,"D31: falta de energía limpia poderes y pierde una ronda si no quedan órdenes")
	check(not combat.enqueue_action("heal") and combat.queue.is_empty(),"D31: energía insuficiente impide encolar poderes nuevos")
	await frames(60)
	check(combat.clock.started_count == 0,"D31: no ejecuta básico en la ronda perdida")
	await wait_started(combat,1,150)
	check(combat.current_action.id == "attack" and combat.current_action.get("automatic",false),"D31: siguiente ronda recupera básico automático")
	await fresh_encounter()
	combat = main.level.combat
	player = main.level.player
	player.energy = 40
	combat.enqueue_action("lightning")
	combat.enqueue_action("lightning")
	combat.enqueue_action("heal")
	combat.enqueue_action("flurry")
	await unpause()
	await wait_started(combat,2,200)
	check(combat.clock.started_count == 2 and combat.current_action.id == "flurry" and combat.queue.is_empty() and combat.clock.round_left > 2.4 and not main.tactical_paused,"D31: descarga, descarga sin energía, curación, ráfaga ejecuta ráfaga sin perder ronda")
	await fresh_encounter()
	combat = main.level.combat
	combat.enqueue_action("medkit")
	combat.enqueue_action("medkit")
	combat.enqueue_action("attack")
	combat.medkits = 0
	await unpause()
	await wait_started(combat,1)
	check(combat.current_action.id == "attack" and combat.queue.is_empty() and combat.medkits == 0,"D31: botiquín agotado limpia sus órdenes y usa siguiente ataque sin perder ronda")
	await frames(3)
	check(main.tactical_ui.medkit_glyph.action == "empty" and main.tactical_ui.medkit_label.text == "Agotado","B6: al agotarse botiquines desaparece su icono, distinto de hueco futuro")

func test_input_camera_and_retreat() -> void:
	await fresh_encounter()
	var combat = main.level.combat
	var player = main.level.player
	var a = main.level.enemies[0]
	combat.select_target(a)
	combat.enqueue_action("attack")
	combat.enqueue_action("flurry")
	await unpause()
	await wait_started(combat,1)
	var before: Vector3 = player.global_position
	await key_state(KEY_W,true)
	await frames(8)
	await key_state(KEY_W,false)
	check(combat.engaged and combat.current_action.id == "attack" and combat.queue.size() == 1 and Vector2(player.global_position.x-before.x,player.global_position.z-before.z).length()<0.02,"WASD mantiene combate, acción y cola hasta cancelar",str([combat.engaged,combat.current_action,combat.queue.size(),before,player.global_position]))
	var combat_facing: Vector3 = player.forward()
	await key_state(KEY_A,true)
	await frames(8)
	await key_state(KEY_A,false)
	check(combat.engaged and combat.queue.size() == 1 and player.forward().dot(combat_facing)>0.999,"B1: A tampoco gira al actor ni interrumpe órdenes mientras combate automáticamente")
	await drag_camera(Vector2(120,0))
	var displaced: float = absf(angle_difference(player.yaw,player.rig.rotation.y))
	var released_yaw: float = player.yaw
	await right_mouse_state(false)
	await frames(45)
	check(displaced>0.08 and absf(angle_difference(released_yaw,player.yaw))<0.002,"B1: soltar botón derecho conserva la órbita durante combate sin desplazamiento",str([displaced,released_yaw,player.yaw]))
	check(player.forward().dot((a.global_position-player.global_position).normalized())>0.9,"Girar cámara no aparta al combatiente de su destinatario")
	await tap_key(KEY_F)
	check(not combat.engaged and combat.queue.is_empty() and combat.current_action.is_empty() and not combat.actor_locked,"F libera movimiento y elimina órdenes y autoataque")
	before = player.global_position
	await key_state(KEY_S,true)
	await frames(25)
	await key_state(KEY_S,false)
	check(player.global_position.distance_to(before)>0.7 and not combat.engaged,"Tras F, WASD mueve libremente sin reenganche")
	player.global_position = Vector3(0,0.1,20)
	player.velocity = Vector3.ZERO
	a.set_physics_process(true)
	var enemy_before: Vector3 = a.global_position
	await frames(35)
	check(a.active and a.global_position.z > enemy_before.z+0.7 and not combat.engaged,"Agresor sigue persiguiendo lejos por la zona accesible tras cancelar")
	await fresh_encounter()
	combat = main.level.combat
	player = main.level.player
	a = main.level.enemies[0]
	main.level.enemies[1].global_position = Vector3(8,0.1,0)
	combat.disengage()
	player.automation_mode = true
	player.automation_direction = Vector3(0,0,-1)
	await unpause()
	var touched = false
	for _i in range(100):
		await get_tree().physics_frame
		for c in range(player.get_slide_collision_count()):
			if player.get_slide_collision(c).get_collider() == a: touched = true
	check(touched and player.global_position.distance_to(a.global_position)>0.55,"Colisiones sólidas impiden atravesar a un acólito")
	player.automation_direction = Vector3.ZERO
	player.automation_mode = false

func free_movement_fixture() -> void:
	main.show_menu()
	main.new_game()
	await frames(5)
	var player = main.level.player
	player.global_position = Vector3(0,0.1,14)
	player.velocity = Vector3.ZERO
	player.rig.rotation.y = 0
	player.yaw = 0
	player.snap_camera()
	await frames(4)

func test_free_movement_camera() -> void:
	await free_movement_fixture()
	var player = main.level.player
	var before: Vector3 = player.global_position
	var original_forward: Vector3 = player.forward()
	await drag_camera(Vector2(220,0))
	var orbit_yaw: float = player.yaw
	await right_mouse_state(false)
	await frames(40)
	check(absf(orbit_yaw)>0.4 and absf(angle_difference(orbit_yaw,player.yaw))<0.002 and player.forward().dot(original_forward)>0.999,"B1: RMB mantiene órbita en reposo sin mover o girar actor")
	await tap_key(KEY_SPACE)
	before = player.global_position
	var paused_heading: float = player.rig.rotation.y
	await key_state(KEY_A,true)
	await key_state(KEY_W,true)
	await frames(20)
	await key_state(KEY_A,false)
	await key_state(KEY_W,false)
	check(absf(angle_difference(orbit_yaw,player.yaw))>0.6 and player.global_position.distance_to(before)<0.01 and is_equal_approx(player.rig.rotation.y,paused_heading),"B1: A orbita durante pausa sin que W mueva o gire actor")
	orbit_yaw = player.yaw
	await frames(35)
	check(absf(angle_difference(orbit_yaw,player.yaw))<0.002,"B1: soltar A en pausa conserva órbita")
	await screenshot("demo_b1_paused_orbit")
	await unpause()
	before = player.global_position
	var intended = Vector3(-sin(player.yaw),0,-cos(player.yaw))
	await key_state(KEY_W,true)
	await frames(20)
	await key_state(KEY_W,false)
	var travelled: Vector3 = player.global_position-before
	travelled.y = 0
	check(travelled.length()>0.8 and travelled.normalized().dot(intended)>0.99 and player.forward().dot(intended)>0.99,"B1: W avanza y orienta actor según rumbo de cámara")
	await frames(15)
	check(absf(angle_difference(player.camera_pivot.rotation.y,player.rig.rotation.y))<0.04,"B1: cámara centra suave y rápido detrás del nuevo avance")
	await free_movement_fixture()
	player = main.level.player
	before = player.global_position
	original_forward = player.forward()
	await drag_camera(Vector2(-190,0))
	await right_mouse_state(false)
	await key_state(KEY_S,true)
	await frames(35)
	await key_state(KEY_S,false)
	var backward: Vector3 = player.global_position-before
	backward.y = 0
	check(backward.dot(original_forward)<-1.0 and player.forward().dot(original_forward)>0.999,"B1: S retrocede conservando frente sin invertir cámara")
	check(absf(angle_difference(player.yaw,player.rig.rotation.y))<0.025,"B1: retorno al retroceder conserva frente")
	for key in [KEY_A,KEY_D]:
		await free_movement_fixture()
		player = main.level.player
		before = player.global_position
		original_forward = player.forward()
		await key_state(key,true)
		await frames(20)
		var first_turn: float = angle_difference(0,player.yaw)
		await frames(20)
		var second_turn: float = angle_difference(0,player.yaw)
		await key_state(key,false)
		var turn_sign = 1 if key == KEY_A else -1
		check(first_turn*turn_sign>0.5 and second_turn*turn_sign>first_turn*turn_sign+0.5 and Vector2(player.global_position.x-before.x,player.global_position.z-before.z).length()<0.01 and player.forward().dot(original_forward)>0.999,"B1: A/D gira cámara continuamente con actor inmóvil",str([first_turn,second_turn]))
		await key_state(KEY_W,true)
		await key_state(key,true)
		await frames(20)
		var first_heading: float = player.rig.rotation.y
		await frames(20)
		check(absf(angle_difference(first_heading,player.rig.rotation.y))>0.6,"B1: W+A/D sigue el giro continuo de cámara")
		await key_state(key,false)
		await key_state(KEY_W,false)

func test_hud_events() -> void:
	await hud_fixture()
	var hud = main.tactical_ui
	var combat = main.level.combat
	var player = main.level.player
	var a = main.level.enemies[0]
	var b = main.level.enemies[1]
	combat.clear_queue()
	combat.select_target(a)
	await frames(4)
	check(hud.root.visible and hud.action_buttons.size() == 3 and hud.queue_buttons.size() == 4 and hud.action_buttons[2].disabled,"HUD: tres categorías separadas de cuatro órdenes, arrojadizo desactivado")
	var energy_before = player.energy
	var yaw_before = player.yaw
	await wheel_control(hud.action_buttons[0],MOUSE_BUTTON_WHEEL_DOWN)
	check(hud.category_indices[0] == 1 and combat.queue.is_empty() and is_equal_approx(yaw_before,player.yaw),"Rueda sobre físico recorre a Ráfaga sin encolar ni girar cámara")
	await click_control(hud.action_buttons[0])
	check(combat.queue.size() == 1 and combat.queue[0].id == "flurry" and combat.queue[0].target == a,"Clic en físico encola acción mostrada contra A")
	combat.select_target(b)
	await frames(3)
	await click_control(hud.selector_arrows[1][1])
	check(hud.category_indices[1] == 1 and combat.queue.size() == 1,"Flecha de poder recorre a Descarga sin encolar",str([hud.category_indices,combat.queue,hud.selector_arrows[1][1].get_global_rect()]))
	await click_control(hud.action_buttons[1])
	check(combat.queue.size() == 2 and combat.queue[1].id == "lightning" and combat.queue[1].target == b and combat.queue[0].target == a,"Clic en poder encola descarga B y conserva ráfaga A")
	await click_control(hud.medkit_button)
	check(combat.queue.size() == 3 and combat.queue[2].id == "medkit" and combat.queue[2].target == player and combat.medkits == 3 and player.energy == energy_before,"Botiquín personal añade orden propia y no gasta al encolar")
	await screenshot("demo_hud_mixed_targets")
	await click_control(hud.queue_buttons[1])
	check(combat.queue.size() == 2 and combat.queue[0].id == "flurry" and combat.queue[1].id == "medkit","Clic en pendiente cancela solo esa orden")
	await click_control(hud.clear_button)
	check(combat.queue.is_empty(),"Limpiar cola funciona con evento real en pausa")
	await click_control(hud.selector_arrows[1][1])
	check(hud.category_indices[1] == 0 and not "heal" in hud.CATEGORIES[1],"B6: poderes ofensivos recorren empuje/descarga sin curación")
	await wheel_control(hud.heal_button,MOUSE_BUTTON_WHEEL_DOWN)
	check(combat.queue.is_empty(),"B6: rueda personal no añade órdenes")
	await click_control(hud.heal_button)
	check(combat.queue.size() == 1 and combat.queue[0].id == "heal" and combat.queue[0].target == player and combat.selected == b,"B6: selector curativo propio conserva enemigo B seleccionado")
	player.energy = 0
	await frames(3)
	check(hud.heal_button.disabled and hud.action_buttons[1].disabled and not hud.action_buttons[0].disabled,"D31: poder personal y ofensivo aparecen desactivados; físico sigue utilizable")
	await click_control(hud.retreat_button)
	check(not combat.engaged and combat.queue.is_empty(),"Cancelar combate responde a clic real")
	check(not hud.target_selectors.visible,"B2: Cancelar combate oculta selectores aunque el encuentro hostil siga activo")

func hud_fixture() -> void:
	await fresh_encounter()
	# Keep enough projected space above the actors for the floating selector card.
	main.level.player.global_position = Vector3(0,0.1,3)
	main.level.player.velocity = Vector3.ZERO
	main.level.player.yaw = 0
	main.level.player.rig.rotation.y = 0
	main.level.enemies[0].global_position = Vector3(-1.2,0.1,-3)
	main.level.enemies[1].global_position = Vector3(1.2,0.1,-3)
	main.level.player.snap_camera()
	# Paused CharacterBody colliders retain the pre-fixture server pose. Briefly
	# resume with actor/combat updates disabled to sync placement before real clicks.
	var actors: Array = [main.level.player] + main.level.enemies
	var actor_processing: Array = []
	for actor in actors:
		actor_processing.append(actor.is_physics_processing())
		actor.set_physics_process(false)
	main.level.combat.set_physics_process(false)
	get_tree().paused = false
	await frames(3)
	get_tree().paused = true
	main.level.combat.set_physics_process(true)
	for i in range(actors.size()): actors[i].set_physics_process(actor_processing[i])
	await frames(5)

func test_hud_target_attachment() -> void:
	await hud_fixture()
	var hud = main.tactical_ui
	var combat = main.level.combat
	var a = main.level.enemies[0]
	var b = main.level.enemies[1]
	var camera: Camera3D = get_viewport().get_camera_3d()
	await click_actor(a)
	var head: Vector2 = camera.unproject_position(a.rig.to_global(Vector3(0,2.15,0)))
	var card: Rect2 = hud.target_selectors.get_global_rect()
	check(combat.selected == a and hud.target_selectors.visible and main.tactical_paused,"B2: clic real sobre A muestra el menú flotante durante pausa del encuentro")
	check(card.size.x<=260 and card.size.y<=160 and absf(card.get_center().x-head.x)<4 and card.end.y<=head.y-4,"B2: menú compacto centrado sobre la cabeza sin tapar la cara",str([card,head]))
	check(not main.ui.target_panel.visible and hud.target_name_label.text.contains(a.display_name) and is_equal_approx(hud.target_health_bar.value,100.0),"B2: nombre y salud acompañan al enemigo seleccionado en la tarjeta flotante")
	var previous_card: Rect2 = card
	a.global_position.x -= 0.8
	await frames(4)
	head = camera.unproject_position(a.rig.to_global(Vector3(0,2.15,0)))
	card = hud.target_selectors.get_global_rect()
	check(hud.target_selectors.visible and card.position.distance_to(previous_card.position)>15 and absf(card.get_center().x-head.x)<4 and card.end.y<=head.y-4,"B2: mover el destinatario actualiza el anclaje de la tarjeta",str([previous_card,card,head]))
	previous_card = card
	await drag_camera(Vector2(80,0))
	await right_mouse_state(false)
	await frames(15)
	head = camera.unproject_position(a.rig.to_global(Vector3(0,2.15,0)))
	card = hud.target_selectors.get_global_rect()
	check(hud.target_selectors.visible and card.position.distance_to(previous_card.position)>15 and absf(card.get_center().x-head.x)<4 and card.end.y<=head.y-4,"B2: arrastrar cámara reproyecta el menú sobre el mismo enemigo",str([previous_card,card,head]))
	await screenshot("demo_b2_target_camera_attachment")
	await click_actor(b)
	head = camera.unproject_position(b.rig.to_global(Vector3(0,2.15,0)))
	card = hud.target_selectors.get_global_rect()
	check(combat.selected == b and hud.target_selectors.visible and absf(card.get_center().x-head.x)<4 and hud.target_name_label.text.contains(b.display_name),"B2: cambiar objetivo con clic mueve el menú a B")
	await screenshot("demo_b2_selected_b")
	var obstacle = StaticBody3D.new()
	main.level.add_child(obstacle)
	obstacle.global_position = camera.global_position.lerp(b.rig.to_global(Vector3(0,2.15,0)),0.5)
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(1.0,0.8,0.3)
	collision.shape = shape
	obstacle.add_child(collision)
	await frames(4)
	check(not hud.target_selectors.visible,"B2: un obstáculo entre cámara y enemigo oculta la tarjeta")
	obstacle.queue_free()
	await frames(4)
	check(hud.target_selectors.visible,"B2: quitar el obstáculo restaura la tarjeta del objetivo visible")
	await tap_key(KEY_F)
	check(not combat.engaged and not hud.target_selectors.visible and hud.root.visible,"B2: F oculta menú del enemigo y conserva equipo personal y órdenes")
	await click_actor(b)
	check(combat.engaged and combat.selected == b and hud.target_selectors.visible and main.encounters_started.size() == 1,"B2: clic en agresor reengancha y recupera tarjeta sin nueva pausa inicial")
	b.active = false
	await frames(3)
	check(not hud.target_selectors.visible,"B2: un destinatario neutral no muestra selectores")
	b.active = true
	var old_position: Vector3 = b.global_position
	b.global_position = main.level.player.global_position+Vector3(0,0,20)
	await frames(3)
	check(camera.is_position_behind(b.rig.to_global(Vector3(0,2.15,0))) and not hud.target_selectors.visible,"B2: objetivo detrás de cámara oculta su menú")
	b.global_position = Vector3(80,0.1,-3)
	await frames(3)
	check(not camera.is_position_behind(b.rig.to_global(Vector3(0,2.15,0))) and not hud.target_selectors.visible,"B2: objetivo fuera del encuadre no deja tarjeta flotando en pantalla")
	b.global_position = old_position
	combat.selected = null
	await frames(3)
	check(not hud.target_selectors.visible,"B2: selección inválida oculta los tres selectores")
	await free_movement_fixture()
	hud = main.tactical_ui
	check(hud.root.visible and not hud.target_selectors.visible and main.mission.state == KhMission.State.EXPLORATION,"B2: exploración muestra equipo personal sin menú ofensivo")
	main.mission.transition(KhMission.State.DIALOGUE)
	await frames(3)
	check(not hud.target_selectors.visible,"B2: diálogo inicial mantiene oculto el menú ofensivo")
	await guardian_fixture()
	main.dialogue.choose(0)
	main.dialogue.continue_dialogue()
	await frames(3)
	main.level.player.global_position = Vector3(0,0.1,3)
	main.level.player.yaw = 0
	main.level.player.snap_camera()
	main.level.guardian.global_position = Vector3(0,0.1,-3)
	main.level.combat.select_target(main.level.guardian)
	await frames(4)
	check(main.mission.state == KhMission.State.BOSS and main.tactical_ui.target_selectors.visible and main.tactical_ui.target_name_label.text.contains(main.level.guardian.display_name),"B2: combate del guardián también usa tarjeta de objetivo durante pausa")
	main.show_menu()
	main.new_duel()
	await frames(6)
	main.level.player.global_position = Vector3(0,0.1,3)
	main.level.player.yaw = 0
	main.level.player.snap_camera()
	main.level.enemies[0].global_position = Vector3(0,0.1,-3)
	await frames(4)
	check(main.mission.state == KhMission.State.DUEL and main.tactical_ui.target_selectors.visible and main.level.combat.engaged,"B2: duelo interno conserva el menú sobre su enemigo seleccionado")

func test_enemy_independent_rounds_and_stagger() -> void:
	await fresh_encounter()
	var combat = main.level.combat
	var hero = main.level.player
	var enemy = main.level.enemies[0]
	combat.disengage()
	hero.set_physics_process(false)
	enemy.set_physics_process(true)
	var health_before: float = hero.health
	await unpause()
	await frames(int(ceil((enemy.round_clock.round_seconds+0.7)*60)))
	var enemy_damage = 0.0
	var enemy_events = 0
	for event in combat.event_log:
		if event.get("source","") == "enemy":
			enemy_events += 1
			enemy_damage += event.get("damage",0)
	check(enemy_events >= 2 and enemy.attacks >= 2 and combat.resolved_actions == 0 and not combat.engaged,"Tras cancelar, agresor sigue atacando por sus propias rondas")
	check(enemy_damage>0 and is_equal_approx(health_before-hero.health,enemy_damage),"Daño enemigo coincide con tiradas registradas mientras jugador no da órdenes")
	await fresh_encounter()
	combat = main.level.combat
	hero = main.level.player
	enemy = main.level.enemies[0]
	combat.disengage()
	hero.set_physics_process(false)
	enemy.set_physics_process(true)
	await unpause()
	for _i in range(20):
		if enemy.round_clock.started_count>0: break
		await get_tree().physics_frame
	health_before = hero.health
	enemy.take_damage(1,Vector3.RIGHT*2)
	await frames(80)
	check(enemy.round_clock.impact_count == 0 and hero.health == health_before and enemy.rig.attack_time == 0 and enemy.round_clock.round_left>0,"Interrumpir preparación enemiga cancela daño y animación sin golpe invisible")

func guardian_fixture() -> void:
	await fresh_encounter()
	var p = main.level.player
	p.health = 180
	p.energy = 41
	main.level.combat.medkits = 2
	for i in range(3): main.level.enemies[i].take_damage(main.level.enemies[i].health)
	await frames(4)
	check(main.mission.state == KhMission.State.GUARDIAN_WAIT and not get_tree().paused and not main.level.temple_open,"B4: fin de acólitos espera segundo diálogo y mantiene puerta cerrada")
	check(p.health == 180 and p.energy >= 41 and p.energy < 42 and main.level.combat.medkits == 2,"B4: transición a espera conserva recursos sin regalos")
	p.global_position = Vector3(0,2.5,-18)
	p.velocity = Vector3.ZERO
	p.yaw = 0
	p.snap_camera()
	await frames(3)
	await click_actor(main.level.guardian)
	check(main.level.combat.selected == main.level.guardian and main.mission.state == KhMission.State.GUARDIAN_WAIT and main.tactical_ui.talk_button.visible,"B4: primer clic selecciona guardián y muestra voz sin conversar")
	await click_control(main.tactical_ui.talk_button)
	await frames(3)
	# Freeze exact resources at dialogue entry for the subsequent time test.
	p.health = 180
	p.energy = 41

func side_capture(name: String) -> void:
	if not capture: return
	var hero = main.level.player
	var midpoint: Vector3 = hero.global_position+hero.forward()*0.5
	# View the bare left hand and place contacts below the selector cards.
	main.level.menu_camera.global_position = midpoint+Vector3(-4.2,2.8,0.8)
	main.level.menu_camera.look_at(midpoint+Vector3.UP*1.8)
	main.level.menu_camera.fov = 48
	main.level.menu_camera.make_current()
	await screenshot(name)
	hero.camera.make_current()

func test_visual_actions() -> void:
	await fresh_encounter()
	var combat = main.level.combat
	var hero = main.level.player
	combat.select_target(main.level.enemies[0])
	combat.enqueue_action("flurry")
	await unpause()
	await wait_impacts(combat,1)
	main.toggle_tactical_pause()
	await side_capture("demo_flurry_contact_1")
	await unpause()
	await wait_impacts(combat,2)
	main.toggle_tactical_pause()
	await side_capture("demo_flurry_contact_2")
	var events = player_events(combat)
	check(events.size() == 2 and events[0].roll != events[1].roll and combat.resolved_actions == 1,"Ráfaga real: dos tiradas independientes y dos contactos visuales")
	for kind in ["push","lightning","heal"]:
		await fresh_encounter()
		combat = main.level.combat
		hero = main.level.player
		hero.health = 240
		combat.select_target(main.level.enemies[0])
		combat.enqueue_action(kind)
		await unpause()
		await wait_impacts(combat,1)
		main.toggle_tactical_pause()
		check(hero.rig.left_arm.rotation.x>1.3 and hero.rig.sword.get_parent() == hero.rig.right_arm,"Poder real extiende brazo izquierdo sin intercambiar sable: "+kind)
		var effect = main.level.fx.get_node_or_null("Lightning" if kind == "lightning" else ("PushWave" if kind == "push" else "Healing"))
		var present: bool = is_instance_valid(effect)
		if present and kind == "lightning":
			present = effect.get_child(0).global_position.distance_to(hero.rig.palm_world_position())<0.05
		elif present and kind == "heal":
			present = effect.get_child(0).material_override.albedo_color.g>0.9 and effect.global_position.distance_to(hero.global_position)<0.05
		check(present,"Efecto visible: onda, descarga desde palma real o curación verde: "+kind)
		if present:
			var effect_position: Vector3 = effect.global_position
			await frames(12)
			check(is_instance_valid(effect) and effect.global_position == effect_position,"Pausa también congela el efecto del poder: "+kind)
		await side_capture("demo_cast_"+kind)

func test_story_and_final() -> void:
	await fresh_encounter()
	var level = main.level
	var player = level.player
	player.global_position = level.relic_position
	check(not level.claim_relic() and main.mission.state == KhMission.State.COMBAT,"No se puede reclamar objetivo antes de resolver guardián")
	for route in ["reject","lesson_attack","peaceful"]:
		await guardian_fixture()
		level = main.level
		player = level.player
		var combat = level.combat
		check(main.mission.state == KhMission.State.GUARDIAN_DIALOGUE and get_tree().paused and not combat.enabled and not level.guardian.active,"Acólitos llevan a conversación segura: "+route)
		check(not main.tactical_ui.target_selectors.is_visible_in_tree(),"B2: conversación con guardián oculta los selectores ofensivos: "+route)
		var values = [player.health,player.energy,combat.medkits,main.mission.elapsed,player.global_position,level.guardian.global_position]
		await frames(60)
		check(values == [player.health,player.energy,combat.medkits,main.mission.elapsed,player.global_position,level.guardian.global_position],"Diálogo congela tiempo y recursos sin regalos: "+route)
		if route == "reject":
			await tap_key(KEY_ESCAPE)
			check(main.paused and main.dialogue_paused and get_tree().paused,"Escape abre menú durante diálogo sin reanudar mundo")
			await tap_key(KEY_ESCAPE)
			check(not main.paused and main.dialogue_paused and get_tree().paused and main.ui.dialog_panel.visible and player.energy == 41,"Cerrar menú restaura diálogo y conserva congelación de recursos")
		if route == "reject":
			main.dialogue.choose(0)
		else:
			main.dialogue.choose(1)
			check(main.mission.heard_doctrine and main.dialogue.stage == "lesson","Escuchar permite decidir después: "+route)
			main.dialogue.choose(0 if route == "peaceful" else 1)
		await screenshot("demo_dialogue_"+route)
		main.dialogue.continue_dialogue()
		await frames(4)
		check(player.health == 180 and player.energy >= 41 and player.energy < 42 and combat.medkits == 2,"Transición conserva salud, energía y botiquines: "+route)
		if route != "peaceful":
			check(main.mission.state == KhMission.State.BOSS and level.guardian.active and main.tactical_paused,"Decisión inicia guardián con pausa propia: "+route)
			level.guardian.take_damage(level.guardian.health)
			await frames(3)
			check(main.mission.guardian_resolution == "combat" and main.mission.kills == 4,"Combate registra resolución y cuatro muertes: "+route)
		else:
			check(level.guardian.health > 0 and not level.guardian.active and not combat.target_valid(level.guardian) and main.mission.kills == 3 and main.mission.guardian_resolution == "peaceful","Acuerdo mantiene guardián vivo, neutral y tres muertes")
		check(main.mission.state == KhMission.State.TEMPLE,"Resolver guardián habilita entrada sin terminar demo: "+route)
		check(not main.tactical_ui.target_selectors.is_visible_in_tree(),"B2: entrada al templo oculta selectores tras resolver el encuentro: "+route)
		player.global_position = Vector3(0,0.1,12)
		check(not level.claim_relic() and main.mission.state == KhMission.State.TEMPLE,"Objetivo requiere entrar y aproximarse: "+route)
		player.global_position = level.relic_position+Vector3(0,0,1)
		player.velocity = Vector3.ZERO
		player.snap_camera()
		await screenshot("demo_temple_"+route)
		await tap_key(KEY_E)
		check(main.mission.state == KhMission.State.VICTORY,"Reclamar con E produce final común: "+route)
		await screenshot("demo_final_"+route)
		main.ui.menu_requested.emit()
		await frames(3)
		check(main.mission.state == KhMission.State.MENU and not get_tree().paused and not main.tactical_ui.root.visible,"Final permite volver al menú sin pausa: "+route)

func test_defeat_restart() -> void:
	await fresh_encounter()
	main.level.combat.medkits = 1
	main.level.player.energy = 13
	main.mission.heard_doctrine = true
	main.level.combat.enqueue_action("flurry",main.level.enemies[0])
	main.level.player.take_damage(main.level.player.max_health*2)
	await frames(3)
	check(main.mission.state == KhMission.State.DEFEAT and not main.level.combat.enabled and main.level.combat.queue.is_empty(),"Muerte detiene misión y órdenes")
	main.ui.restart_requested.emit()
	await frames(4)
	var player = main.level.player
	var initial_enemies = true
	for enemy in main.level.enemies: initial_enemies = initial_enemies and enemy.health == enemy.max_health and not enemy.active
	check(main.mission.state == KhMission.State.EXPLORATION and player.health == player.max_health and player.energy == player.max_energy and main.level.combat.medkits == 3 and initial_enemies and main.mission.kills == 0 and not main.mission.heard_doctrine and main.mission.guardian_resolution.is_empty() and main.level.combat.queue.is_empty(),"Reiniciar vuelve al inicio con enemigos, recursos, cola y elecciones restablecidos")

func test_passive_engagement() -> void:
	await fresh_encounter()
	var combat = main.level.combat
	var hero = main.level.player
	var enemy = main.level.enemies[0]
	enemy.global_position = Vector3(0,0.1,-5)
	combat.select_target(enemy)
	var before: Vector3 = hero.global_position
	await unpause()
	await frames(90)
	check(combat.engaged and combat.clock.started_count == 0 and Vector2(hero.global_position.x-before.x,hero.global_position.z-before.z).length()<0.01 and combat.movement_direction == Vector3.ZERO,"B3: cola vacía espera quieto fuera de alcance, sin acercarse")
	enemy.global_position = hero.global_position+Vector3(0,0,-1.7)
	await wait_started(combat,1)
	check(combat.current_action.get("automatic",false) and combat.current_action.target == enemy,"B3: enemigo entra en alcance y comienza básico automático")
	await tap_key(KEY_SPACE)
	combat.disengage()
	combat.clock.reset()
	enemy.global_position = Vector3(0,0.1,-6)
	combat.select_target(enemy)
	combat.enqueue_action("attack",enemy)
	before = hero.global_position
	await unpause()
	await frames(25)
	check(hero.global_position.distance_to(before)>0.7 and combat.queue.size() == 1,"B3: orden explícita sí permite aproximarse a destinatario lejano")

func test_contextual_clicks() -> void:
	await hud_fixture()
	var combat = main.level.combat
	var a = main.level.enemies[0]
	var b = main.level.enemies[1]
	combat.clear_queue()
	combat.select_target(a)
	combat.enqueue_action("flurry",a)
	await hover_actor(b)
	check(main.context_cursor.context == "pointer","B5: hover sobre enemigo no seleccionado conserva cursor normal",main.context_cursor.context)
	await click_actor(b)
	check(combat.selected == b and combat.queue.size() == 1 and main.tactical_ui.selection_reticle.visible,"B5: primer clic cambia selección y retícula sin añadir ataque")
	check(main.context_cursor.context == "attack","B5: hover sobre enemigo seleccionado muestra cursor espada",main.context_cursor.context)
	await click_actor(b)
	check(combat.queue.size() == 2 and combat.queue[0].id == "flurry" and combat.queue[0].target == a and combat.queue[1].id == "attack" and combat.queue[1].target == b,"B5: segundo clic encola básico B detrás de ráfaga A con destinatarios intactos")
	await screenshot("demo_b5_contextual_basic")
	check(not main.level.can_talk(main.level.guardian),"B4: guardián neutral no ofrece conversación durante encuentro de acólitos")
	main.show_menu()
	main.new_game()
	await frames(4)
	var hero = main.level.player
	a = main.level.enemies[0]
	hero.global_position = Vector3(-5,0.1,-2.5)
	hero.velocity = Vector3.ZERO
	hero.yaw = 0
	hero.snap_camera()
	await frames(4)
	await click_actor(a)
	check(main.level.combat.selected == a and a.phrase_index == 0 and main.tactical_ui.talk_button.visible and main.mission.state == KhMission.State.EXPLORATION,"B4: primer clic neutral ofrece voz sin iniciar diálogo ni combate")
	check(main.context_cursor.context == "talk","B4: neutral seleccionado muestra cursor de voz",main.context_cursor.context)
	for index in range(4):
		await click_control(main.tactical_ui.talk_button)
		await frames(3)
		check(a.phrase_index == (index+1)%3 and main.ui.speech.text.contains(a.NEUTRAL_LINES[index%3]) and main.mission.state == KhMission.State.EXPLORATION,"B4: frases neutrales rotan en orden sin opciones ni combate: %d" % index)
	await screenshot("demo_b4_neutral_voice")
	await tap_key(KEY_E)
	check(main.mission.state == KhMission.State.EXPLORATION,"B4: E no inicia conversaciones manuales")
	check((DisplayServer.get_name() == "headless" or Input.mouse_mode == Input.MOUSE_MODE_HIDDEN) and main.context_cursor.pointer.visible,"Cursor propio visible; ocultación nativa comprobable con GPU")

func test_normal_playthrough() -> void:
	main.show_menu()
	main.new_game()
	await frames(5)
	var player = main.level.player
	var combat = main.level.combat
	player.automation_mode = true
	player.automation_direction = Vector3.FORWARD
	var exploration_frames = 0
	for i in range(900):
		await get_tree().physics_frame
		exploration_frames = i+1
		if main.mission.state == KhMission.State.DIALOGUE: break
	player.automation_direction = Vector3.ZERO
	player.automation_mode = false
	var walked_to_gate: bool = main.mission.state == KhMission.State.DIALOGUE and player.distance_walked > 25
	check(walked_to_gate,"Bot normal recorre exploración hasta diálogo mediante movimiento real")
	if not walked_to_gate:
		bot_report = {"passed":false,"reason":"gate_not_reached","position":str(player.global_position)}
		return
	main.dialogue.choose(0)
	main.dialogue.continue_dialogue()
	await frames(4)
	await screenshot("demo_normal_first_pause")
	await unpause()
	var previous_health: float = player.health
	var damage_taken = 0.0
	var healing_received = 0.0
	var played_frames = 0
	var interrupted_by_energy = false
	for i in range(13000):
		await get_tree().physics_frame
		played_frames = i+1
		if player.health < previous_health: damage_taken += previous_health-player.health
		elif player.health > previous_health: healing_received += player.health-previous_health
		previous_health = player.health
		if main.mission.state in [KhMission.State.DEFEAT,KhMission.State.VICTORY]: break
		if main.mission.state == KhMission.State.GUARDIAN_WAIT:
			player.automation_mode = true
			var direction: Vector3 = main.level.guardian.global_position-player.global_position
			direction.y = 0
			player.automation_direction = direction.normalized()
			if player.global_position.distance_to(main.level.guardian.global_position) < 3.8:
				player.automation_direction = Vector3.ZERO
				player.automation_mode = false
				await click_actor(main.level.guardian)
				await click_actor(main.level.guardian)
			continue
		if main.mission.state == KhMission.State.GUARDIAN_DIALOGUE:
			await screenshot("demo_normal_guardian_offer")
			main.dialogue.choose(0)
			main.dialogue.continue_dialogue()
			await frames(4)
			await unpause()
			continue
		if main.mission.state == KhMission.State.TEMPLE:
			player.automation_mode = true
			var destination: Vector3 = main.level.relic_position
			if player.global_position.z > -9 and absf(player.global_position.x)>0.5:
				destination = Vector3(0,player.global_position.y,-8)
			var direction: Vector3 = destination-player.global_position
			direction.y = 0
			player.automation_direction = direction.normalized()
			if player.global_position.distance_to(main.level.relic_position)<=2.0:
				player.automation_direction = Vector3.ZERO
				await screenshot("demo_normal_temple")
				await tap_key(KEY_E)
			continue
		if main.mission.state not in [KhMission.State.COMBAT,KhMission.State.BOSS]: continue
		if main.tactical_paused: await unpause()
		if not combat.queue.is_empty(): continue
		if player.health < 215 and combat.medkits>0:
			combat.enqueue_action("medkit")
		elif player.health<215 and player.energy>=KhTacticalCombat.ACTIONS.heal.cost+6:
			combat.enqueue_action("heal")
		else:
			var enemy = combat.nearest_target()
			if enemy == null: continue
			combat.select_target(enemy)
			if player.energy>=KhTacticalCombat.ACTIONS.lightning.cost+30:
				combat.enqueue_action("lightning",enemy)
			else: combat.enqueue_action("flurry",enemy)
	var won: bool = main.mission.state == KhMission.State.VICTORY
	var enemy_initial: Array = []
	for enemy in main.level.enemies: enemy_initial.append({"name":enemy.display_name,"max_health":enemy.max_health,"health":enemy.health,"attacks":enemy.attacks})
	bot_report = {"passed":won,"isolated_fixture":false,"production_stats":true,"teleports":0,"direct_damage_calls":0,"exploration_frames":exploration_frames,"combat_frames":played_frames,"seconds":main.mission.elapsed,"state":main.mission.state,"hero_max_health":player.max_health,"hero_health":player.health,"hero_energy":player.energy,"medkits_remaining":combat.medkits,"damage_taken":damage_taken,"healing_received":healing_received,"kills":main.mission.kills,"route":main.mission.guardian_resolution,"resolved_actions":combat.resolved_actions,"energy_guard_triggered":interrupted_by_energy,"distance_walked":player.distance_walked,"position":str(player.global_position),"enemies":enemy_initial,"events":combat.event_log.duplicate(true)}
	check(won and player.health>0 and main.mission.kills == 4 and not interrupted_by_energy,"Bot normal completa acólitos, guardián, entrada y E final sin alterar estadísticas",JSON.stringify({"seconds":bot_report.seconds,"hero_health":player.health,"energy":player.energy,"medkits":combat.medkits,"kills":main.mission.kills,"damage_taken":damage_taken,"healing_received":healing_received,"actions":combat.resolved_actions,"position":str(player.global_position)}))
	var report_file = FileAccess.open("res://tests/demo_playthrough_report.json",FileAccess.WRITE)
	if report_file:
		report_file.store_string(JSON.stringify(bot_report,"\t"))
		report_file.close()
	if won: await screenshot("demo_normal_victory")

func finish() -> void:
	var report = {"engine":Engine.get_version_info(),"renderer":RenderingServer.get_current_rendering_method(),"capture":capture,"failures":failures,"checks":results,"normal_playthrough":bot_report,"q01":"D31 implemented: prune resource category; next valid order uses same opportunity, otherwise lose round."}
	for path in ["res://tests/demo_report.json","res://tests/demo_capture_report.json" if capture else "res://tests/demo_logic_report.json"]:
		var file = FileAccess.open(path,FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(report,"\t"))
			file.close()
		else: check(false,"Guardar informe de demo",path)
	print("KHARUUN_DEMO_RESULT | checks=%d failures=%d" % [results.size(),failures])
	get_tree().quit(0 if failures == 0 else 1)

func run() -> void:
	await frames(8)
	check(is_instance_valid(main) and main.has_method("new_game") and main.level.has_method("claim_relic"),"API de demo unificada disponible")
	if not main.level.has_method("claim_relic"):
		finish()
		return
	test_clock_and_rig()
	await test_encounter_and_pause()
	await test_hud_events()
	await test_hud_target_attachment()
	await test_visual_actions()
	await test_targets_and_fallback()
	await test_flurry_invalid_second_contact()
	await test_resources()
	await test_input_camera_and_retreat()
	await test_free_movement_camera()
	await test_enemy_independent_rounds_and_stagger()
	await test_story_and_final()
	await test_defeat_restart()
	await test_passive_engagement()
	await test_contextual_clicks()
	await test_normal_playthrough()
	finish()
