extends Node
var level: KhLevel
var mission: KhMission
var ui: KhUI
var dialogue: KhDialogue
var paused = false
var automated = false
var tactical_paused = false
var dialogue_paused = false
var tactical_ui: KhTacticalUI
var encounters_started: Array = []
var seeking_initial_target = false
var context_cursor: KhContextCursor

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	DisplayServer.window_set_title("Shadows of Kharuun · 0.3.0 RC2")
	setup_input()
	mission = KhMission.new()
	mission.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(mission)
	mission.changed.connect(on_state_changed)
	dialogue = KhDialogue.new()
	dialogue.mission = mission
	dialogue.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(dialogue)
	dialogue.updated.connect(func(): ui.show_dialogue(dialogue))
	dialogue.finished.connect(func(): mission.transition(dialogue.next_state))
	ui = KhUI.new()
	ui.main = self
	add_child(ui)
	ui.restart_requested.connect(restart_current)
	ui.menu_requested.connect(show_menu)
	ui.resume_requested.connect(toggle_pause)
	ui.choice_selected.connect(dialogue.choose)
	ui.dialogue_continue.connect(dialogue.continue_dialogue)
	tactical_ui = KhTacticalUI.new()
	tactical_ui.main = self
	add_child(tactical_ui)
	context_cursor = KhContextCursor.new()
	context_cursor.main = self
	add_child(context_cursor)
	create_level()
	ui.show_menu()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	var args = OS.get_cmdline_user_args()
	automated = "--hud-capture" in args or "--demo-test" in args or "--demo-capture" in args or "--auto-test" in args or "--capture" in args or "--playtest" in args or "--tactical-test" in args or "--tactical-capture" in args
	if automated:
		var runner = load("res://tests/temple_runner.gd").new()
		runner.main = self
		runner.capture = "--hud-capture" in args or "--demo-capture" in args or "--capture" in args or "--tactical-capture" in args
		add_child(runner)
	elif "--duel" in args: new_duel()
	elif "--mission" in args: new_game()

func setup_input() -> void:
	var keys = {"move_forward": KEY_W, "move_back": KEY_S, "move_left": KEY_A, "move_right": KEY_D, "sprint": KEY_SHIFT, "push": KEY_1, "lightning": KEY_2, "interact": KEY_E, "pause": KEY_ESCAPE, "tactical_pause": KEY_SPACE, "queue_attack": KEY_3, "queue_flurry": KEY_4, "queue_heal": KEY_5, "queue_medkit": KEY_6, "cycle_target": KEY_TAB, "disengage": KEY_F}
	for action in keys:
		if not InputMap.has_action(action): InputMap.add_action(action)
		InputMap.action_erase_events(action)
		var event = InputEventKey.new()
		event.physical_keycode = keys[action]
		InputMap.action_add_event(action, event)
	if not InputMap.has_action("attack"): InputMap.add_action("attack")
	InputMap.action_erase_events("attack")
	var mouse = InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("attack", mouse)

func create_level(duel: bool = false) -> void:
	if is_instance_valid(level):
		remove_child(level)
		level.queue_free()
	level = preload("res://scenes/level.tscn").instantiate()
	level.mission = mission
	level.duel_mode = duel
	add_child(level)
	dialogue.audio = level.audio
	level.reached_gate.connect(func(): mission.transition(KhMission.State.DIALOGUE))
	level.player.died.connect(func(): mission.transition(KhMission.State.DEFEAT))
	for e in level.enemies:
		e.died.connect(func(enemy): mission.enemy_died(enemy.guardian))
	level.npc_interacted.connect(on_npc_interacted)

func on_npc_interacted(enemy: KhEnemy) -> void:
	if enemy.guardian:
		if mission.state == KhMission.State.GUARDIAN_WAIT: mission.transition(KhMission.State.GUARDIAN_DIALOGUE)
		elif mission.state == KhMission.State.EXPLORATION: mission.transition(KhMission.State.DIALOGUE)
		else: ui.say(enemy.display_name,"El umbral está abierto. Reclama lo que has venido a buscar.")
	else:
		ui.say(enemy.display_name,enemy.next_phrase())

func new_game() -> void:
	reset_pause()
	encounters_started.clear()
	tactical_ui.reset_help()
	if is_instance_valid(level): level.audio.stop_voice()
	create_level()
	mission.reset()
	level.begin_mission()
	ui.show_game()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func new_duel(start_paused: bool = true) -> void:
	reset_pause()
	encounters_started.clear()
	tactical_ui.reset_help()
	if is_instance_valid(level): level.audio.stop_voice()
	create_level(true)
	mission.reset(true)
	level.begin_mission()
	ui.show_game()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	if start_paused:
		get_tree().physics_frame.connect(func(): call_deferred("begin_encounter", "duel"), CONNECT_ONE_SHOT)
	else:
		level.combat.select_target(level.enemies[0])
		encounters_started.append("duel")

func restart_current() -> void:
	if is_instance_valid(level) and level.duel_mode: new_duel()
	else: new_game()

func reset_pause() -> void:
	paused = false
	tactical_paused = false
	dialogue_paused = false
	seeking_initial_target = false
	get_tree().paused = false

func apply_pause() -> void:
	get_tree().paused = paused or tactical_paused or dialogue_paused
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func begin_encounter(id: String) -> void:
	if id in encounters_started or mission.state not in [KhMission.State.COMBAT, KhMission.State.BOSS, KhMission.State.DUEL]: return
	encounters_started.append(id)
	var target = level.combat.nearest_target(100.0)
	seeking_initial_target = not is_instance_valid(target)
	if is_instance_valid(target): level.combat.select_target(target)
	tactical_paused = true
	apply_pause()
	if id == "acolytes": tactical_ui.show_help()

func toggle_tactical_pause() -> void:
	if paused or dialogue_paused or mission.state not in [KhMission.State.EXPLORATION, KhMission.State.COMBAT, KhMission.State.BOSS, KhMission.State.DUEL, KhMission.State.TEMPLE, KhMission.State.GUARDIAN_WAIT]: return
	tactical_paused = not tactical_paused
	if not tactical_paused: tactical_ui.hide_help()
	apply_pause()

func cancel_combat() -> void:
	seeking_initial_target = false
	level.combat.disengage()

func show_menu() -> void:
	reset_pause()
	level.audio.stop_voice()
	level.stop_combat()
	level.player.visible = false
	level.menu_camera.make_current()
	mission.transition(KhMission.State.MENU)
	ui.show_menu()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func on_state_changed(state: int) -> void:
	if not is_instance_valid(level): return
	match state:
		KhMission.State.DUEL:
			level.combat.enabled = true
			level.enemies[0].activate()
		KhMission.State.DIALOGUE, KhMission.State.GUARDIAN_DIALOGUE:
			level.combat.stop()
			level.player.interaction_target = null
			level.player.control_enabled = false
			level.player.automation_direction = Vector3.ZERO
			dialogue_paused = true
			tactical_paused = false
			apply_pause()
			if state == KhMission.State.GUARDIAN_DIALOGUE: dialogue.begin_guardian()
			else: dialogue.begin()
		KhMission.State.GUARDIAN_WAIT:
			level.combat.stop()
			level.combat.enabled = true
			level.player.control_enabled = true
			level.player.velocity = Vector3.ZERO
			dialogue_paused = false
			tactical_paused = false
			apply_pause()
			ui.announce("EL GUARDIÁN ESPERA · SELECCIÓNALO Y HABLA")
		KhMission.State.COMBAT, KhMission.State.BOSS:
			ui.hide_dialogue()
			dialogue_paused = false
			tactical_paused = false
			apply_pause()
			level.player.control_enabled = true
			if state == KhMission.State.COMBAT: level.start_acolytes()
			else: level.start_boss()
			ui.announce("LOS ACÓLITOS DESPIERTAN" if state == KhMission.State.COMBAT else "EL GUARDIÁN TE DESAFÍA")
			begin_encounter("acolytes" if state == KhMission.State.COMBAT else "guardian")
		KhMission.State.TEMPLE:
			ui.hide_dialogue()
			dialogue_paused = false
			tactical_paused = false
			apply_pause()
			level.combat.disengage()
			level.combat.enabled = true
			level.player.control_enabled = true
			level.open_temple()
			level.combat.last_result = "Umbral abierto · clica el núcleo para reclamarlo"
			ui.announce("EL UMBRAL SE ABRE")
		KhMission.State.VICTORY, KhMission.State.DEFEAT:
			reset_pause()
			level.stop_combat()
			level.audio.stop_voice()
			if state == KhMission.State.VICTORY: level.audio.play_effect("victory")
			ui.show_end(state == KhMission.State.VICTORY, mission.elapsed)
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func toggle_pause() -> void:
	if mission.state in [KhMission.State.MENU, KhMission.State.VICTORY, KhMission.State.DEFEAT]: return
	paused = not paused
	apply_pause()
	if paused: ui.show_pause()
	else:
		ui.clear_overlay()
		if dialogue_paused: ui.show_dialogue(dialogue)

func _process(delta: float) -> void:
	if tactical_paused and not paused and is_instance_valid(level):
		level.player.update_camera(delta)
	if seeking_initial_target and not get_tree().paused and level.combat.enabled:
		if level.combat.engaged: seeking_initial_target = false
		else:
			var target = level.combat.nearest_target(100.0)
			if is_instance_valid(target):
				level.combat.select_target(target)
				seeking_initial_target = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo: return
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()
		return
	if paused: return
	if dialogue_paused:
		if event is InputEventKey and event.pressed:
			if dialogue.awaiting_choice and event.physical_keycode in [KEY_1, KEY_2, KEY_3]: dialogue.choose(event.physical_keycode - KEY_1)
			elif not dialogue.awaiting_choice and event.physical_keycode in [KEY_E, KEY_ENTER, KEY_SPACE]: dialogue.continue_dialogue()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("tactical_pause"):
		toggle_tactical_pause()
		get_viewport().set_input_as_handled()
		return
	if mission.state in [KhMission.State.MENU, KhMission.State.VICTORY, KhMission.State.DEFEAT]: return
	if event is InputEventMouseMotion and tactical_paused:
		level.player.camera_input(event)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if level.relic_at_screen(event.position): level.request_relic()
		else: level.combat.select_screen(event.position)
	var commands = {"queue_attack": "attack", "queue_flurry": "flurry", "push": "push", "lightning": "lightning", "queue_heal": "heal", "queue_medkit": "medkit"}
	for action in commands:
		if event.is_action_pressed(action):
			level.combat.enqueue_action(commands[action])
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("cycle_target"): level.combat.cycle_target()
	if event.is_action_pressed("disengage"):
		cancel_combat()
