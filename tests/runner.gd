extends Node
var main: Node
var capture = false
var results: Array = []
var transitions: Array = []
var failures = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	main.mission.changed.connect(func(state): transitions.append(state))
	call_deferred("run")

func check(condition: bool, name: String, details: String = "") -> void:
	results.append({"name":name,"passed":condition,"details":details})
	if condition:
		print("PASS | ",name," | ",details)
	else:
		failures += 1
		push_error("FAIL | %s | %s" % [name,details])

func frames(count: int) -> void:
	for i in range(count):
		await get_tree().physics_frame

func screenshot(name: String) -> void:
	if not capture: return
	await frames(16)
	await RenderingServer.frame_post_draw
	var image = get_viewport().get_texture().get_image()
	var path = "res://screenshots/%s.png" % name
	var err = image.save_png(ProjectSettings.globalize_path(path))
	check(err == OK,"Captura real: "+name,"%dx%d" % [image.get_width(),image.get_height()])

func run() -> void:
	await frames(10)
	check(main.mission.state == KhMission.State.MENU and is_instance_valid(main.ui.menu),"Menú principal instanciado")
	await screenshot("01_menu")
	main.ui.menu.start_requested.emit()
	await frames(12)
	check(main.mission.state == KhMission.State.EXPLORATION,"Nueva partida inicia el escenario")
	var p = main.level.player
	check(p.health > 0 and p.visible,"Jugador con salud positiva")
	check(main.level.enemies.size() == 4 and main.level.guardian.guardian,"Tres acólitos y un guardián")
	await screenshot("02_entrada")
	var key = InputEventKey.new()
	key.physical_keycode = KEY_W
	key.pressed = true
	var start_pos = p.position
	Input.parse_input_event(key)
	await frames(10)
	key = InputEventKey.new()
	key.physical_keycode = KEY_W
	key.pressed = false
	Input.parse_input_event(key)
	check(p.position.z < start_pos.z-0.20,"El teclado WASD mueve al jugador")
	if capture:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		var motion = InputEventMouseMotion.new()
		motion.relative = Vector2(40,-8)
		var before_yaw = p.yaw
		Input.parse_input_event(motion)
		await frames(2)
		check(p.yaw < before_yaw,"El ratón rota la cámara")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		p.yaw = 0
	if capture:
		main.level.menu_camera.position = Vector3(18,13,19)
		main.level.menu_camera.look_at(Vector3(0,4,-9))
		main.level.menu_camera.make_current()
		main.ui.hud.hide()
		await screenshot("03_panorama")
		main.ui.hud.show()
		p.camera.make_current()
	p.automation_mode = true
	p.automation_direction = Vector3(0,0,-1)
	for i in range(700):
		await get_tree().physics_frame
		if main.mission.state == KhMission.State.DIALOGUE: break
	check(main.mission.state == KhMission.State.DIALOGUE,"Caminar hasta el umbral activa diálogo",str(p.position))
	check(p.distance_walked > 30,"Ruta principal recorrida con move_and_slide",str(p.distance_walked))
	check(not main.level.enemies[0].active and p.health == p.max_health,"El diálogo bloquea la agresión")
	await screenshot("04_conversacion")
	var dialog_rect = main.ui.dialog_panel.get_global_rect()
	check(dialog_rect.position.y >= 0 and dialog_rect.end.y <= get_viewport().get_visible_rect().size.y,"Panel de diálogo dentro de la ventana",str(dialog_rect))
	# Check the actual simplified staircase collision in both directions.
	p.automation_direction = Vector3(0,0,-1)
	await frames(175)
	check(p.position.y >= 2.30 and p.position.z < -18,"Escalera accesible mediante rampa",str(p.position))
	p.automation_direction = Vector3(0,0,1)
	await frames(200)
	check(p.position.y < 0.20,"Descenso de la escalera",str(p.position))
	p.automation_direction = Vector3.ZERO
	key = InputEventKey.new()
	key.physical_keycode = KEY_1
	key.pressed = true
	Input.parse_input_event(key)
	await frames(2)
	key = InputEventKey.new()
	key.physical_keycode = KEY_1
	key.pressed = false
	Input.parse_input_event(key)
	check(not main.dialogue.awaiting_choice,"Elegir respuesta con teclado")
	check(main.mission.dialogue_choice == 0 and main.dialogue.text == KhDialogue.REPLIES[0],"Elección narrativa registrada")
	main.dialogue.continue_dialogue()
	await frames(10)
	check(main.mission.state == KhMission.State.COMBAT and main.level.enemies[0].active,"El diálogo inicia el combate")
	var combat = main.level.combat
	var enemy = main.level.enemies[0]
	# Position next to a real active enemy; use the production attack entry point.
	p.position = enemy.position+Vector3(0,0,2.15)
	await frames(3)
	var before = enemy.health
	check(combat.basic_attack() and enemy.health < before,"Ataque básico aplica daño",str(enemy.health))
	check(not combat.basic_attack() and combat.attack_cooldown > 0,"Ataque básico respeta cooldown")
	var energy_before = p.energy
	check(combat.use_ability(1) and combat.push_cooldown > 0 and p.energy < energy_before,"Empuje: daño, energía y cooldown")
	check(not combat.use_ability(1),"Empuje no se puede repetir durante cooldown")
	check(combat.use_ability(2) and combat.lightning_cooldown > 0,"Descarga: ataque energético con cooldown")
	check(not combat.use_ability(2),"Descarga no se puede repetir durante cooldown")
	await screenshot("05_combate")
	# Observe an actual telegraphed enemy attack and damage to the hero.
	p.position = main.level.enemies[1].position+Vector3(0,0,1.1)
	var health_before = p.health
	await frames(230)
	check(p.health < health_before and p.health > 0,"La IA persigue y daña al jugador",str(p.health))
	main.toggle_pause()
	var position_before = main.level.enemies[1].position
	await frames(12)
	check(main.get_tree().paused and position_before == main.level.enemies[1].position,"La pausa detiene la IA")
	main.toggle_pause()
	# Death uses real damage, real signals, and real mission transitions.
	for e in main.level.enemies:
		if not e.guardian: e.take_damage(e.health)
	check(main.mission.state == KhMission.State.BOSS and main.level.guardian.active,"Tres muertes activan el jefe")
	await frames(30)
	await screenshot("06_jefe")
	var boss = main.level.guardian
	check(boss.max_health > enemy.max_health,"El guardián tiene más salud")
	boss.take_damage(boss.health)
	await frames(20)
	check(main.mission.state == KhMission.State.VICTORY and not combat.enabled,"Muerte del guardián dispara victoria y detiene combate")
	check(transitions.slice(0,6) == [1,2,3,4,5],"Secuencia real MENÚ → EXPLORACIÓN → DIÁLOGO → COMBATE → JEFE → VICTORIA",str(transitions))
	await screenshot("07_victoria")
	main.ui.restart_requested.emit()
	await frames(8)
	check(main.mission.state == KhMission.State.EXPLORATION and main.mission.slain_acolytes == 0,"Repetir misión restablece el estado")
	# Verify alternate dialogue responses without adding narrative branches.
	for index in [1,2]:
		main.level.player.position = Vector3(0,0.2,-10.4)
		await frames(5)
		check(main.dialogue.choose(index) and main.mission.dialogue_choice == index and main.dialogue.text == KhDialogue.REPLIES[index],"Respuesta alternativa %d registrada" % (index+1))
		main.dialogue.continue_dialogue()
		if index == 1:
			main.show_menu()
			await frames(4)
			main.new_game()
			await frames(8)
	p = main.level.player
	p.invulnerable = 0
	p.take_damage(p.max_health*2)
	await frames(8)
	check(main.mission.state == KhMission.State.DEFEAT,"Salud cero activa derrota")
	await screenshot("08_derrota")
	main.ui.restart_requested.emit()
	await frames(8)
	check(main.mission.state == KhMission.State.EXPLORATION and main.level.player.health == main.level.player.max_health,"Derrota permite reiniciar")
	# Boundary collider: the hero cannot walk off the courtyard.
	p = main.level.player
	p.position = Vector3(18,0.2,10)
	p.automation_mode = true
	p.automation_direction = Vector3.RIGHT
	await frames(100)
	check(p.position.x < 19.5 and p.position.y > -0.2,"Muros de borde impiden caer del mapa",str(p.position))
	p.automation_direction = Vector3.ZERO
	main.show_menu()
	await frames(10)
	check(main.mission.state == KhMission.State.MENU,"Volver al menú funciona")
	var report = {"engine":Engine.get_version_info(),"renderer":RenderingServer.get_current_rendering_method(),"capture":capture,"failures":failures,"checks":results,"transitions":transitions}
	var file = FileAccess.open("res://tests/last_report.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	file.close()
	file = FileAccess.open("res://tests/capture_report.json" if capture else "res://tests/logic_report.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	file.close()
	print("KHARUUN_TEST_RESULT | checks=%d failures=%d" % [results.size(),failures])
	get_tree().quit(0 if failures == 0 else 1)
