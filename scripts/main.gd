extends Node
var level: KhLevel
var mission: KhMission
var ui: KhUI
var dialogue: KhDialogue
var paused = false
var automated = false
var tactical_paused = false
var tactical_ui: KhTacticalUI

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup_input()
	mission = KhMission.new()
	mission.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(mission)
	mission.changed.connect(on_state_changed)
	dialogue = KhDialogue.new()
	dialogue.mission = mission
	dialogue.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(dialogue)
	dialogue.updated.connect(func(): ui.show_dialogue(dialogue))
	dialogue.finished.connect(func(): mission.transition(KhMission.State.COMBAT))
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
	create_level()
	ui.show_menu()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var args = OS.get_cmdline_user_args()
	automated = "--auto-test" in args or "--capture" in args or "--playtest" in args or "--tactical-test" in args or "--tactical-capture" in args
	if automated:
		var script_path = "res://tests/runner.gd"
		if "--playtest" in args: script_path = "res://tests/playthrough.gd"
		if "--tactical-test" in args or "--tactical-capture" in args: script_path = "res://tests/tactical_runner.gd"
		var runner = load(script_path).new()
		runner.main = self
		runner.capture = "--capture" in args or "--tactical-capture" in args
		add_child(runner)
	elif "--duel" in args:
		new_duel()

func setup_input() -> void:
	var keys = {"move_forward":KEY_W,"move_back":KEY_S,"move_left":KEY_A,"move_right":KEY_D,"sprint":KEY_SHIFT,"push":KEY_1,"lightning":KEY_2,"interact":KEY_E,"pause":KEY_ESCAPE,"tactical_pause":KEY_SPACE,"queue_attack":KEY_3,"defend":KEY_4,"cycle_target":KEY_TAB,"disengage":KEY_F}
	for action in keys:
		if not InputMap.has_action(action): InputMap.add_action(action)
		var event = InputEventKey.new()
		event.physical_keycode = keys[action]
		InputMap.action_add_event(action,event)
	if not InputMap.has_action("attack"): InputMap.add_action("attack")
	var mouse = InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("attack",mouse)

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

func new_game() -> void:
	get_tree().paused = false
	paused = false
	tactical_paused = false
	if is_instance_valid(level): level.audio.stop_voice()
	create_level()
	mission.reset()
	level.begin_mission()
	ui.show_game()
	if not automated: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func new_duel(start_paused: bool = true) -> void:
	get_tree().paused = false
	paused = false
	tactical_paused = false
	if is_instance_valid(level): level.audio.stop_voice()
	create_level(true)
	level.player.position = Vector3(0,0.1,6)
	level.begin_mission()
	mission.reset(true)
	if not level.combat.enabled: on_state_changed(KhMission.State.DUEL)
	ui.show_game()
	if not start_paused: ui.announce("DUELO TÁCTICO  ·  PREPARA TUS ÓRDENES")
	else: ui.toast_time = 0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if start_paused:
		# Give the physics server one completed step to register fresh colliders.
		var instance_id = level.get_instance_id()
		get_tree().physics_frame.connect(func(): call_deferred("finish_duel_start",instance_id),CONNECT_ONE_SHOT)

func finish_duel_start(instance_id: int) -> void:
	if is_instance_valid(level) and level.get_instance_id() == instance_id and mission.state == KhMission.State.DUEL and not paused:
		level.player.snap_camera()
		if not tactical_paused: toggle_tactical_pause()

func restart_current() -> void:
	if is_instance_valid(level) and level.duel_mode: new_duel()
	else: new_game()

func toggle_tactical_pause() -> void:
	if mission.state != KhMission.State.DUEL or paused: return
	tactical_paused = not tactical_paused
	get_tree().paused = tactical_paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func show_menu() -> void:
	get_tree().paused = false
	paused = false
	tactical_paused = false
	level.audio.stop_voice()
	level.stop_combat()
	level.player.visible = false
	level.menu_camera.make_current()
	mission.transition(KhMission.State.MENU)
	ui.show_menu()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func on_state_changed(state: int) -> void:
	if not is_instance_valid(level): return
	match state:
		KhMission.State.DUEL:
			level.combat.enabled = true
			level.enemies[0].activate()
		KhMission.State.DIALOGUE:
			level.player.control_enabled = false
			level.player.automation_direction = Vector3.ZERO
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			dialogue.begin()
		KhMission.State.COMBAT:
			ui.hide_dialogue()
			level.player.control_enabled = true
			level.start_acolytes()
			ui.announce("LOS ACÓLITOS DESPIERTAN")
			if not automated: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		KhMission.State.BOSS:
			level.start_boss()
			ui.announce("EL GUARDIÁN DESCIENDE  ·  +75 VITALIDAD")
		KhMission.State.VICTORY:
			get_tree().paused = false
			tactical_paused = false
			level.stop_combat()
			level.audio.stop_voice()
			level.audio.play_effect("victory")
			level.fx.wave(level.guardian.global_position,8,Color(1,0.43,0.11))
			ui.show_end(true,mission.elapsed)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		KhMission.State.DEFEAT:
			get_tree().paused = false
			tactical_paused = false
			level.stop_combat()
			level.audio.stop_voice()
			ui.show_end(false,mission.elapsed)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func toggle_pause() -> void:
	if mission.state in [KhMission.State.MENU,KhMission.State.VICTORY,KhMission.State.DEFEAT]: return
	paused = not paused
	get_tree().paused = paused or tactical_paused
	if paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		ui.show_pause()
	else:
		ui.clear_overlay()
		if mission.state == KhMission.State.DIALOGUE:
			ui.show_dialogue(dialogue)
		else:
			if not automated and not level.duel_mode: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo: return
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("tactical_pause") and mission.state == KhMission.State.DUEL:
		toggle_tactical_pause()
		get_viewport().set_input_as_handled()
		return
	if paused: return
	# Tactical commands remain available while the world is paused.
	if tactical_paused and mission.state == KhMission.State.DUEL:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			level.combat.select_screen(event.position)
		if event.is_action_pressed("cycle_target"): level.combat.cycle_target()
		if event.is_action_pressed("queue_attack"): level.combat.enqueue_action("attack")
		if event.is_action_pressed("push"): level.combat.enqueue_action("push")
		if event.is_action_pressed("lightning"): level.combat.enqueue_action("lightning")
		if event.is_action_pressed("defend"): level.combat.enqueue_action("defend")
		if event.is_action_pressed("disengage"): level.combat.disengage()
		return
	if mission.state == KhMission.State.DIALOGUE and event is InputEventKey and event.pressed and not event.echo:
		if dialogue.awaiting_choice:
			if event.physical_keycode in [KEY_1,KEY_2,KEY_3]:
				dialogue.choose(event.physical_keycode-KEY_1)
		else:
			if event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
				dialogue.continue_dialogue()
