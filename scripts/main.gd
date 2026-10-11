extends Node
var level: KhLevel
var mission: KhMission
var ui: KhUI
var dialogue: KhDialogue
var paused = false
var automated = false

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
	ui.restart_requested.connect(new_game)
	ui.menu_requested.connect(show_menu)
	ui.resume_requested.connect(toggle_pause)
	ui.choice_selected.connect(dialogue.choose)
	ui.dialogue_continue.connect(dialogue.continue_dialogue)
	create_level()
	ui.show_menu()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	automated = "--auto-test" in OS.get_cmdline_user_args() or "--capture" in OS.get_cmdline_user_args() or "--playtest" in OS.get_cmdline_user_args()
	if automated:
		var runner = load("res://tests/playthrough.gd" if "--playtest" in OS.get_cmdline_user_args() else "res://tests/runner.gd").new()
		runner.main = self
		runner.capture = "--capture" in OS.get_cmdline_user_args()
		add_child(runner)

func setup_input() -> void:
	var keys = {"move_forward":KEY_W,"move_back":KEY_S,"move_left":KEY_A,"move_right":KEY_D,"sprint":KEY_SHIFT,"push":KEY_1,"lightning":KEY_2,"interact":KEY_E,"pause":KEY_ESCAPE}
	for action in keys:
		if not InputMap.has_action(action): InputMap.add_action(action)
		var event = InputEventKey.new()
		event.physical_keycode = keys[action]
		InputMap.action_add_event(action,event)
	if not InputMap.has_action("attack"): InputMap.add_action("attack")
	var mouse = InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("attack",mouse)

func create_level() -> void:
	if is_instance_valid(level):
		remove_child(level)
		level.queue_free()
	level = preload("res://scenes/level.tscn").instantiate()
	level.mission = mission
	add_child(level)
	dialogue.audio = level.audio
	level.reached_gate.connect(func(): mission.transition(KhMission.State.DIALOGUE))
	level.player.died.connect(func(): mission.transition(KhMission.State.DEFEAT))
	for e in level.enemies:
		e.died.connect(func(enemy): mission.enemy_died(enemy.guardian))

func new_game() -> void:
	get_tree().paused = false
	paused = false
	if is_instance_valid(level): level.audio.stop_voice()
	create_level()
	mission.reset()
	level.begin_mission()
	ui.show_game()
	if not automated: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func show_menu() -> void:
	get_tree().paused = false
	paused = false
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
			level.stop_combat()
			level.audio.stop_voice()
			level.audio.play_effect("victory")
			level.fx.wave(level.guardian.global_position,8,Color(1,0.43,0.11))
			ui.show_end(true,mission.elapsed)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		KhMission.State.DEFEAT:
			level.stop_combat()
			level.audio.stop_voice()
			ui.show_end(false,mission.elapsed)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func toggle_pause() -> void:
	if mission.state in [KhMission.State.MENU,KhMission.State.VICTORY,KhMission.State.DEFEAT]: return
	paused = not paused
	get_tree().paused = paused
	if paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		ui.show_pause()
	else:
		ui.clear_overlay()
		if mission.state == KhMission.State.DIALOGUE:
			ui.show_dialogue(dialogue)
		else:
			if not automated: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()
	if paused: return
	if mission.state == KhMission.State.DIALOGUE and event is InputEventKey and event.pressed and not event.echo:
		if dialogue.awaiting_choice:
			if event.physical_keycode in [KEY_1,KEY_2,KEY_3]:
				dialogue.choose(event.physical_keycode-KEY_1)
		else:
			if event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
				dialogue.continue_dialogue()
