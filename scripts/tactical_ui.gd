class_name KhTacticalUI
extends CanvasLayer

# The three selectors describe action categories; pending orders are separate.
const CATEGORIES = [["attack", "flurry"], ["push", "lightning", "heal"], []]
const CATEGORY_NAMES = ["ARMA", "ENERGÍA", "ARROJADIZOS"]
const SHORTCUTS = {"attack":"3", "flurry":"4", "push":"1", "lightning":"2", "heal":"5", "medkit":"6"}

class ActionGlyph extends Control:
	var action = "attack"
	var tint = KhUI.GOLD
	func _draw() -> void:
		var c = size * 0.5
		var color = tint
		match action:
			"attack", "flurry":
				var blades = [-7.0, 7.0] if action == "flurry" else [0.0]
				for offset in blades:
					var start = c + Vector2(-12 + offset, 14)
					var end = c + Vector2(12 + offset, -14)
					draw_line(start, end, color, 3.0, true)
					draw_line(start + Vector2(-4, -9), start + Vector2(10, 3), color, 3.0, true)
					draw_line(end, end + Vector2(-6, 2), color, 2.0, true)
			"push":
				for radius in [7.0, 13.0, 19.0]:
					draw_arc(c, radius, -1.0, 1.0, 16, color, 2.0, true)
				draw_line(c + Vector2(-17, 0), c + Vector2(8, 0), color, 3.0, true)
			"lightning":
				draw_polyline(PackedVector2Array([c + Vector2(5, -20), c + Vector2(-9, 2), c + Vector2(7, -1), c + Vector2(-5, 20)]), color, 4.0, true)
			"heal", "medkit":
				if action == "medkit":
					draw_rect(Rect2(c - Vector2(19, 14), Vector2(38, 28)), color, false, 2.0)
					draw_rect(Rect2(c - Vector2(8, 20), Vector2(16, 6)), color, false, 2.0)
				else:
					draw_arc(c, 19, 0, TAU, 32, color, 2.0, true)
				draw_line(c + Vector2(-10, 0), c + Vector2(10, 0), color, 5.0, true)
				draw_line(c + Vector2(0, -10), c + Vector2(0, 10), color, 5.0, true)
			_:
				draw_rect(Rect2(c - Vector2(15, 15), Vector2(30, 30)), color, false, 1.0)
				draw_line(c - Vector2(12, 12), c + Vector2(12, 12), color, 1.0, true)
	func set_action(next: String, active: bool) -> void:
		action = next
		tint = Color(0.43, 0.85, 0.58) if next == "heal" or next == "medkit" else KhUI.GOLD
		if not active: tint = KhUI.DIM * Color(1, 1, 1, 0.55)
		queue_redraw()

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
var selector_labels: Array[Label] = []
var selector_glyphs: Array[ActionGlyph] = []
var selector_arrows: Array = []
var category_indices = [0, 0, 0]
var clear_button: Button
var retreat_button: Button
var medkit_button: Button
var medkit_label: Label
var medkit_glyph: ActionGlyph
var target_selectors: PanelContainer
var help_overlay: Control
var help_seen = false
var energy_notice: Label
var context_hint: Label
var context_time = 0.0
var was_engaged = false
var context_seen: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 5
	root = Control.new()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.hide()
	_build_pause_banner()
	_build_selectors()
	_build_personal_menu()
	_build_orders()
	_build_help()

func _place(control: Control, position: Vector2, dimensions: Vector2, preset: int) -> void:
	control.set_anchors_and_offsets_preset(preset)
	control.offset_left = position.x
	control.offset_top = position.y
	control.offset_right = position.x + dimensions.x
	control.offset_bottom = position.y + dimensions.y

func _panel(position: Vector2, dimensions: Vector2, preset: int) -> PanelContainer:
	var panel = PanelContainer.new()
	root.add_child(panel)
	_place(panel, position, dimensions, preset)
	var panel_style = KhUI.style(Color(0.027, 0.029, 0.042, 0.95), Color(0.35, 0.25, 0.17))
	panel_style.content_margin_left = 10
	panel_style.content_margin_right = 10
	panel_style.content_margin_top = 8
	panel_style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", panel_style)
	return panel

func _button(title: String, height: float = 32.0, accent: bool = false) -> Button:
	var button = KhUI.button(title, accent)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_disabled_color", KhUI.DIM)
	for state in ["normal", "hover", "focus", "pressed"]:
		var button_style = button.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		button_style.content_margin_left = 7
		button_style.content_margin_right = 7
		button_style.content_margin_top = 4
		button_style.content_margin_bottom = 4
		button.add_theme_stylebox_override(state, button_style)
	button.custom_minimum_size.y = height
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return button

func _build_pause_banner() -> void:
	pause_banner = _panel(Vector2(-225, 255), Vector2(450, 54), Control.PRESET_CENTER_TOP)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	pause_banner.add_child(column)
	var title = KhUI.label("PAUSA TÁCTICA", 17, KhUI.GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var explanation = KhUI.label("Prepara órdenes · ESPACIO para reanudar", 12)
	explanation.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(explanation)
	pause_banner.hide()

func _build_selectors() -> void:
	target_selectors = _panel(Vector2(-180, 85), Vector2(360, 160), Control.PRESET_CENTER_TOP)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	target_selectors.add_child(row)
	for category in range(3):
		var column = VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.custom_minimum_size.x = 104
		column.add_theme_constant_override("separation", 2)
		column.mouse_filter = Control.MOUSE_FILTER_STOP
		column.gui_input.connect(_selector_input.bind(category, column))
		row.add_child(column)
		var caption = KhUI.label(CATEGORY_NAMES[category], 10, KhUI.GOLD)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column.add_child(caption)
		var up = _button("▲", 17)
		up.add_theme_font_size_override("font_size", 10)
		column.add_child(up)
		up.pressed.connect(_cycle_category.bind(category, -1))
		up.gui_input.connect(_selector_input.bind(category, up))
		var select = _button("", 47, category < 2)
		select.gui_input.connect(_selector_input.bind(category, select))
		select.pressed.connect(_enqueue_selected.bind(category))
		column.add_child(select)
		var glyph = ActionGlyph.new()
		select.add_child(glyph)
		glyph.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
		selector_glyphs.append(glyph)
		action_buttons.append(select)
		var name_label = KhUI.label("", 11)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column.add_child(name_label)
		selector_labels.append(name_label)
		var down = _button("▼", 17)
		down.add_theme_font_size_override("font_size", 10)
		column.add_child(down)
		down.pressed.connect(_cycle_category.bind(category, 1))
		down.gui_input.connect(_selector_input.bind(category, down))
		selector_arrows.append([up, down])

func _build_personal_menu() -> void:
	var personal = _panel(Vector2(25, -154), Vector2(260, 130), Control.PRESET_BOTTOM_LEFT)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	personal.add_child(column)
	column.add_child(KhUI.label("EQUIPO PERSONAL", 11, KhUI.GOLD))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 7)
	column.add_child(row)
	var medkit_column = VBoxContainer.new()
	medkit_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(medkit_column)
	medkit_button = _button("", 54, true)
	medkit_button.pressed.connect(_add_order.bind("medkit"))
	medkit_column.add_child(medkit_button)
	medkit_glyph = ActionGlyph.new()
	medkit_glyph.action = "medkit"
	medkit_button.add_child(medkit_glyph)
	medkit_glyph.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	medkit_glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	medkit_label = KhUI.label("Botiquín ×3 [6]", 11)
	medkit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	medkit_column.add_child(medkit_label)
	for future in ["Escudo", "Forma"]:
		var empty = VBoxContainer.new()
		empty.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(empty)
		var unavailable = _button("—", 54)
		unavailable.disabled = true
		unavailable.tooltip_text = "%s · reservado para otra iteración" % future
		empty.add_child(unavailable)
		var caption = KhUI.label(future, 11, KhUI.DIM)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.add_child(caption)
	column.add_child(KhUI.label("Huecos vacíos: aún no disponibles", 10, KhUI.DIM))

func _build_orders() -> void:
	var panel = _panel(Vector2(-304, -196), Vector2(608, 172), Control.PRESET_CENTER_BOTTOM)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	panel.add_child(column)
	var header = HBoxContainer.new()
	column.add_child(header)
	var caption = KhUI.label("ÓRDENES · cada acción conserva su destinatario", 11, KhUI.DIM)
	caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(caption)
	round_label = KhUI.label("Ronda: en espera", 12, KhUI.GOLD)
	header.add_child(round_label)
	round_bar = ProgressBar.new()
	round_bar.custom_minimum_size.y = 5
	round_bar.show_percentage = false
	for state in ["background", "fill"]:
		var progress_style = KhUI.style(Color(0.53, 0.31, 0.16) if state == "fill" else Color(0.075, 0.055, 0.065), KhUI.GOLD, 0)
		progress_style.content_margin_left = 0
		progress_style.content_margin_right = 0
		progress_style.content_margin_top = 0
		progress_style.content_margin_bottom = 0
		round_bar.add_theme_stylebox_override(state, progress_style)
	column.add_child(round_bar)
	current_label = KhUI.label("En curso: esperando órdenes", 13)
	current_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	column.add_child(current_label)
	var queue_row = HBoxContainer.new()
	queue_row.add_theme_constant_override("separation", 6)
	column.add_child(queue_row)
	for index in range(4):
		var slot = _button("%d · —" % (index + 1), 44)
		slot.add_theme_font_size_override("font_size", 11)
		slot.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		queue_row.add_child(slot)
		slot.pressed.connect(_cancel_order.bind(index))
		queue_buttons.append(slot)
	var controls = HBoxContainer.new()
	controls.add_theme_constant_override("separation", 6)
	column.add_child(controls)
	pause_button = _button("Pausa [ESPACIO]", 32, true)
	pause_button.pressed.connect(_toggle_pause)
	controls.add_child(pause_button)
	clear_button = _button("Limpiar cola", 32)
	clear_button.tooltip_text = "Retira las órdenes pendientes; la acción actual continúa."
	clear_button.pressed.connect(_clear_orders)
	controls.add_child(clear_button)
	retreat_button = _button("Cancelar combate [F]", 32)
	retreat_button.tooltip_text = "Cancela órdenes y autoataque. Recuperas WASD; los enemigos siguen atacando."
	retreat_button.pressed.connect(_retreat)
	controls.add_child(retreat_button)
	result_label = KhUI.label("", 13, KhUI.GOLD)
	root.add_child(result_label)
	_place(result_label, Vector2(-365, -225), Vector2(730, 23), Control.PRESET_CENTER_BOTTOM)
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	context_hint = KhUI.label("", 12)
	root.add_child(context_hint)
	_place(context_hint, Vector2(-400, -254), Vector2(800, 25), Control.PRESET_CENTER_BOTTOM)
	context_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	energy_notice = KhUI.label("Orden sin energía · retírala de la cola o pulsa F para continuar", 14, Color(1, 0.68, 0.38))
	root.add_child(energy_notice)
	_place(energy_notice, Vector2(-470, 320), Vector2(940, 34), Control.PRESET_CENTER_TOP)
	energy_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	energy_notice.hide()

func _build_help() -> void:
	help_overlay = Control.new()
	root.add_child(help_overlay)
	help_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade = ColorRect.new()
	help_overlay.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.012, 0.015, 0.025, 0.87)
	var center = CenterContainer.new()
	help_overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel = PanelContainer.new()
	center.add_child(panel)
	panel.custom_minimum_size.x = 640
	panel.add_theme_stylebox_override("panel", KhUI.style(Color(0.035, 0.025, 0.035, 0.99)))
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 13)
	panel.add_child(column)
	column.add_child(KhUI.label("PREPARA TU PRIMER ENCUENTRO", 23, KhUI.GOLD))
	column.add_child(KhUI.label("1  Selecciona un enemigo con clic o TAB.", 17))
	column.add_child(KhUI.label("2  Flechas o rueda recorren ataques y poderes; clic los encola.", 17))
	column.add_child(KhUI.label("3  Puedes dar cada orden a un enemigo diferente.", 17))
	column.add_child(KhUI.label("4  Botiquines y curación propia también ocupan una acción.", 17))
	column.add_child(KhUI.label("ESPACIO reanuda. La cola vacía mantiene el ataque básico.\nF cancela el combate y libera WASD; los enemigos siguen atacando.", 15))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	column.add_child(row)
	var understood = _button("Entendido · preparar órdenes", 39, true)
	understood.pressed.connect(hide_help)
	row.add_child(understood)
	var skip = _button("Omitir ayuda", 39)
	skip.pressed.connect(hide_help)
	row.add_child(skip)
	help_overlay.hide()

func show_help() -> void:
	if help_seen: return
	help_seen = true
	help_overlay.show()

func hide_help() -> void:
	help_overlay.hide()

func reset_help() -> void:
	help_seen = false
	help_overlay.hide()
	context_seen.clear()
	context_time = 0
	was_engaged = false
	category_indices = [0, 0, 0]

func _combat() -> Node:
	if not is_instance_valid(main) or not is_instance_valid(main.level): return null
	return main.level.combat

func _process(delta: float) -> void:
	var combat = _combat()
	root.visible = combat != null and main.ui.hud.visible and not main.paused
	if not root.visible: return
	pause_banner.visible = main.tactical_paused
	pause_button.text = "Reanudar [ESPACIO]" if main.tactical_paused else "Pausa [ESPACIO]"
	var selected_valid: bool = combat.target_valid(combat.selected)
	target_selectors.visible = true
	for category in range(3):
		var actions: Array = CATEGORIES[category]
		var unavailable: bool = actions.is_empty()
		for arrow in selector_arrows[category]: arrow.disabled = unavailable
		if unavailable:
			action_buttons[category].disabled = true
			action_buttons[category].tooltip_text = "Arrojadizos · disponibles en una futura iteración"
			selector_labels[category].text = "Vacío\nNo disponible"
			selector_labels[category].add_theme_color_override("font_color", KhUI.DIM)
			selector_glyphs[category].set_action("empty", false)
			continue
		var id: String = actions[category_indices[category]]
		var self_target = id == "heal"
		action_buttons[category].disabled = not combat.enabled or combat.queue.size() >= 4 or (not self_target and not selected_valid)
		var cost: int = int(combat.ACTIONS[id].get("cost", 0))
		var subtitle = "Un impacto" if id == "attack" else "Dos impactos"
		if cost > 0: subtitle = "%d energía%s" % [cost, " · Tú" if self_target else ""]
		selector_labels[category].text = "%s [%s]\n%s" % [combat.action_name(id), SHORTCUTS[id], "Sobre ti · %d E" % cost if self_target else subtitle]
		selector_labels[category].add_theme_color_override("font_color", KhUI.IVORY)
		var destination = "Sobre ti" if self_target else ("→ " + combat.selected.display_name if selected_valid else "Selecciona un enemigo")
		action_buttons[category].tooltip_text = "%s · %s%s\nClic: encolar · flechas/rueda: cambiar sin dar una orden" % [combat.action_name(id), destination, " · %d de energía" % cost if cost > 0 else ""]
		selector_glyphs[category].set_action(id, not action_buttons[category].disabled)
	medkit_label.text = "Botiquín ×%d [6]" % combat.medkits
	medkit_button.disabled = not combat.enabled or combat.medkits <= 0 or combat.queue.size() >= 4
	medkit_button.tooltip_text = "Botiquines agotados" if combat.medkits <= 0 else "Sobre ti · encola una curación. Consume una unidad al ejecutar, aunque tengas toda la salud."
	medkit_glyph.set_action("medkit", not medkit_button.disabled)
	var current: Dictionary = combat.current_action
	if not current.is_empty():
		current_label.text = "En curso: %s → %s" % [combat.action_name(str(current.get("id", "attack"))), str(current.get("target_name", "Tú"))]
	elif not combat.queue.is_empty():
		var next_order: Dictionary = combat.queue[0]
		current_label.text = "Próxima: %s → %s" % [combat.action_name(str(next_order.get("id", "attack"))), str(next_order.get("target_name", "Tú"))]
	elif combat.engaged and combat.target_valid(combat.last_offensive_target):
		current_label.text = "En curso: básico automático → %s" % combat.last_offensive_target.display_name
	elif combat.engaged and selected_valid:
		current_label.text = "En curso: aproximación → %s" % combat.selected.display_name
	else:
		current_label.text = "Movimiento libre · clic en enemigo para combatir"
	var round_active: bool = combat.engaged or not current.is_empty() or combat.round_left > 0
	round_label.text = "Ronda: %.1f s" % maxf(combat.round_left, 0.0) if round_active else "Ronda: en espera"
	round_bar.value = clampf((1.0 - combat.round_left / maxf(combat.round_seconds, 0.01)) * 100.0, 0.0, 100.0) if round_active else 0.0
	for index in range(queue_buttons.size()):
		var slot = queue_buttons[index]
		var occupied: bool = index < combat.queue.size()
		slot.disabled = not occupied
		if occupied:
			var order: Dictionary = combat.queue[index]
			var order_name: String = combat.action_name(str(order.get("id", "attack")))
			var target_name = str(order.get("target_name", "Tú"))
			slot.text = "%d · %s\n→ %s ×" % [index + 1, order_name, _short_target_name(target_name)]
			slot.tooltip_text = "%s → %s\nClic: cancelar esta orden pendiente" % [order_name, target_name]
		else:
			slot.text = "%d · —" % (index + 1)
			slot.tooltip_text = "Orden pendiente vacía"
	clear_button.disabled = combat.queue.is_empty()
	retreat_button.disabled = not combat.engaged and combat.queue.is_empty() and current.is_empty()
	pause_button.disabled = not combat.enabled
	result_label.text = combat.ability_error if combat.error_time > 0 else combat.last_result
	energy_notice.visible = combat.energy_pending
	if was_engaged and not combat.engaged and combat.enabled:
		_context_once("retreat", "Movimiento libre: usa WASD. Los enemigos continúan persiguiéndote.")
	was_engaged = combat.engaged
	if not main.get_tree().paused: context_time = maxf(0, context_time - delta)
	context_hint.visible = context_time > 0

func _context_once(id: String, text: String) -> void:
	if context_seen.has(id): return
	context_seen[id] = true
	context_hint.text = text
	context_time = 5

func _short_target_name(full_name: String) -> String:
	for prefix in ["Acólito del ", "Acólito de la ", "Acólito de "]:
		if full_name.begins_with(prefix): return full_name.trim_prefix(prefix)
	return full_name

func _selector_input(event: InputEvent, category: int, control: Control) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		_cycle_category(category, -1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1)
		control.accept_event()

func _cycle_category(category: int, direction: int) -> void:
	var actions: Array = CATEGORIES[category]
	if actions.is_empty(): return
	category_indices[category] = posmod(category_indices[category] + direction, actions.size())
	_context_once("selector", "Recorrer cambia la acción mostrada. Pulsa su icono para añadirla a la cola.")

func _enqueue_selected(category: int) -> void:
	var actions: Array = CATEGORIES[category]
	if not actions.is_empty(): _add_order(actions[category_indices[category]])

func _add_order(id: String) -> void:
	var combat = _combat()
	if combat != null and root.visible:
		if combat.enqueue_action(id) and id in ["heal", "medkit"]:
			_context_once("healing", "La curación ocupa una acción. Su recurso se consume cuando se ejecuta.")

func _cancel_order(index: int) -> void:
	var combat = _combat()
	if combat != null and root.visible: combat.cancel_queued(index)

func _clear_orders() -> void:
	var combat = _combat()
	if combat != null and root.visible: combat.clear_queue()

func _retreat() -> void:
	var combat = _combat()
	if combat != null and root.visible: main.cancel_combat()

func _toggle_pause() -> void:
	if is_instance_valid(main) and root.visible:
		hide_help()
		main.toggle_tactical_pause()
