class_name KhTacticalUI
extends CanvasLayer

var main: Node
var root: Control
var pause_banner: PanelContainer
var pause_button: Button
var current_label: Label
var round_label: Label
var round_bar: ProgressBar
var result_label: Label
var queue_buttons: Array[Button] = []
var action_buttons: Array[Button] = []
var clear_button: Button
var retreat_button: Button

const ACTION_IDS = ["attack", "push", "lightning", "defend"]
const ACTION_TITLES = ["Ataque [3]", "Empuje [1]", "Descarga [2]", "Defensa [4]"]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 5
	root = Control.new()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.hide()
	_build_pause_banner()
	_build_orders()

func _place(control: Control, position: Vector2, dimensions: Vector2, preset: int) -> void:
	control.set_anchors_and_offsets_preset(preset)
	control.offset_left = position.x
	control.offset_top = position.y
	control.offset_right = position.x + dimensions.x
	control.offset_bottom = position.y + dimensions.y

func _button(title: String, height: float = 34.0, accent: bool = false) -> Button:
	var button = KhUI.button(title, accent)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_disabled_color", KhUI.DIM)
	for state in ["normal", "hover", "focus", "pressed"]:
		var button_style = button.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		button_style.content_margin_left = 10
		button_style.content_margin_right = 10
		button_style.content_margin_top = 5
		button_style.content_margin_bottom = 5
		button.add_theme_stylebox_override(state, button_style)
	button.custom_minimum_size.y = height
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return button

func _build_pause_banner() -> void:
	pause_banner = PanelContainer.new()
	root.add_child(pause_banner)
	_place(pause_banner, Vector2(-228, 111), Vector2(456, 58), Control.PRESET_CENTER_TOP)
	var banner_style = KhUI.style(Color(0.033, 0.028, 0.042, 0.96), KhUI.GOLD)
	banner_style.content_margin_top = 7
	banner_style.content_margin_bottom = 7
	pause_banner.add_theme_stylebox_override("panel", banner_style)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	pause_banner.add_child(column)
	var title = KhUI.label("PAUSA TÁCTICA", 18, KhUI.GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var explanation = KhUI.label("Prepara la cola · ESPACIO para reanudar", 12)
	explanation.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(explanation)
	pause_banner.hide()

func _build_orders() -> void:
	var panel = PanelContainer.new()
	root.add_child(panel)
	_place(panel, Vector2(-319, -222), Vector2(638, 196), Control.PRESET_CENTER_BOTTOM)
	var panel_style = KhUI.style(Color(0.027, 0.029, 0.042, 0.94), Color(0.35, 0.25, 0.17))
	panel_style.content_margin_left = 12
	panel_style.content_margin_right = 12
	panel_style.content_margin_top = 10
	panel_style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", panel_style)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	panel.add_child(column)
	var header = HBoxContainer.new()
	column.add_child(header)
	var selection_hint = KhUI.label("CLIC en enemigo · TAB cambia objetivo", 12, KhUI.DIM)
	selection_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(selection_hint)
	round_label = KhUI.label("Ronda: en espera", 12, KhUI.GOLD)
	header.add_child(round_label)
	round_bar = ProgressBar.new()
	round_bar.custom_minimum_size.y = 5
	round_bar.show_percentage = false
	var background = KhUI.style(Color(0.075, 0.055, 0.065), Color(0.2, 0.16, 0.13))
	var fill = KhUI.style(Color(0.53, 0.31, 0.16), KhUI.GOLD, 0)
	for style_box in [background, fill]:
		style_box.content_margin_left = 0
		style_box.content_margin_right = 0
		style_box.content_margin_top = 0
		style_box.content_margin_bottom = 0
	round_bar.add_theme_stylebox_override("background", background)
	round_bar.add_theme_stylebox_override("fill", fill)
	column.add_child(round_bar)
	current_label = KhUI.label("En curso: esperando órdenes", 13)
	current_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	column.add_child(current_label)
	var queue_row = HBoxContainer.new()
	queue_row.add_theme_constant_override("separation", 6)
	column.add_child(queue_row)
	for index in range(4):
		var slot = _button("%d · —" % (index + 1), 32)
		slot.add_theme_font_size_override("font_size", 12)
		slot.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		slot.tooltip_text = "Orden pendiente %d · clic para cancelar" % (index + 1)
		queue_row.add_child(slot)
		slot.pressed.connect(_cancel_order.bind(index))
		queue_buttons.append(slot)
	var actions_row = HBoxContainer.new()
	actions_row.add_theme_constant_override("separation", 6)
	column.add_child(actions_row)
	for index in range(ACTION_IDS.size()):
		var action_button = _button(ACTION_TITLES[index], 39)
		actions_row.add_child(action_button)
		action_button.pressed.connect(_add_order.bind(ACTION_IDS[index]))
		action_buttons.append(action_button)
	var controls_row = HBoxContainer.new()
	controls_row.add_theme_constant_override("separation", 6)
	column.add_child(controls_row)
	pause_button = _button("Pausa [ESPACIO]", 31, true)
	pause_button.add_theme_font_size_override("font_size", 13)
	controls_row.add_child(pause_button)
	pause_button.pressed.connect(_toggle_pause)
	clear_button = _button("Limpiar cola", 31)
	clear_button.add_theme_font_size_override("font_size", 13)
	clear_button.tooltip_text = "Cancela todas las órdenes pendientes. La acción actual continúa."
	controls_row.add_child(clear_button)
	clear_button.pressed.connect(_clear_orders)
	retreat_button = _button("Retirarse [F]", 31)
	retreat_button.add_theme_font_size_override("font_size", 13)
	retreat_button.tooltip_text = "Abandona el ataque automático y cancela las órdenes pendientes."
	controls_row.add_child(retreat_button)
	retreat_button.pressed.connect(_retreat)
	result_label = KhUI.label("", 14, KhUI.GOLD)
	root.add_child(result_label)
	_place(result_label, Vector2(-319, -251), Vector2(638, 24), Control.PRESET_CENTER_BOTTOM)
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

func _combat() -> Node:
	if not is_instance_valid(main) or not is_instance_valid(main.level):
		return null
	return main.level.combat

func _process(_delta: float) -> void:
	var combat = _combat()
	root.visible = combat != null and main.level.duel_mode and main.mission.state == KhMission.State.DUEL and main.ui.hud.visible and not main.paused
	if not root.visible:
		return
	pause_banner.visible = main.tactical_paused
	pause_button.text = "Reanudar [ESPACIO]" if main.tactical_paused else "Pausa [ESPACIO]"
	var selected_valid = is_instance_valid(combat.selected) and combat.selected.health > 0
	var current: Dictionary = combat.current_action
	if not current.is_empty():
		var target_name = str(current.get("target_name", ""))
		current_label.text = "En curso: %s%s" % [combat.action_name(str(current.get("id", "attack"))), " → " + target_name if not target_name.is_empty() else ""]
	elif combat.engaged and selected_valid:
		current_label.text = "En curso: preparando ataque automático → %s" % combat.selected.display_name
	else:
		current_label.text = "En curso: esperando órdenes · selecciona un enemigo"
	var round_active: bool = combat.engaged or not current.is_empty()
	round_label.text = "Ronda: %.1f s" % maxf(combat.round_left, 0.0) if round_active else "Ronda: en espera"
	round_bar.value = clampf((1.0 - combat.round_left / maxf(combat.round_seconds, 0.01)) * 100.0, 0.0, 100.0) if round_active else 0.0
	for index in range(queue_buttons.size()):
		var slot = queue_buttons[index]
		var occupied: bool = index < combat.queue.size()
		slot.disabled = not occupied
		if occupied:
			var order: Dictionary = combat.queue[index]
			var order_name: String = combat.action_name(str(order.get("id", "attack")))
			var target_name = str(order.get("target_name", ""))
			slot.text = "%d · %s ×" % [index + 1, order_name]
			slot.tooltip_text = "%s%s\nClic para cancelar esta orden pendiente" % [order_name, " → " + target_name if not target_name.is_empty() else ""]
		else:
			slot.text = "%d · —" % (index + 1)
			slot.tooltip_text = "Ranura de orden pendiente vacía"
	for index in range(action_buttons.size()):
		action_buttons[index].disabled = not combat.enabled or combat.queue.size() >= 4 or (index != 3 and not selected_valid)
		action_buttons[index].text = ACTION_TITLES[index]
	var push_wait: float = combat.push_cooldown
	var lightning_wait: float = combat.lightning_cooldown
	action_buttons[0].tooltip_text = "Añade un ataque al objetivo. La cola vacía vuelve al ataque básico automático."
	action_buttons[1].tooltip_text = "Empuje · 24 de energía%s" % (" · disponible en %.1f s" % push_wait if push_wait > 0 else "")
	action_buttons[2].tooltip_text = "Descarga · 32 de energía%s" % (" · disponible en %.1f s" % lightning_wait if lightning_wait > 0 else "")
	action_buttons[3].tooltip_text = "Añade una ronda defensiva a la cola."
	clear_button.disabled = combat.queue.is_empty()
	retreat_button.disabled = not combat.engaged and combat.queue.is_empty() and current.is_empty()
	result_label.text = combat.ability_error if combat.error_time > 0 else combat.last_result

func _add_order(id: String) -> void:
	var combat = _combat()
	if combat != null and root.visible:
		combat.enqueue_action(id)

func _cancel_order(index: int) -> void:
	var combat = _combat()
	if combat != null and root.visible:
		combat.cancel_queued(index)

func _clear_orders() -> void:
	var combat = _combat()
	if combat != null and root.visible:
		combat.clear_queue()

func _retreat() -> void:
	var combat = _combat()
	if combat != null and root.visible:
		combat.disengage()

func _toggle_pause() -> void:
	if is_instance_valid(main) and root.visible:
		main.toggle_tactical_pause()
