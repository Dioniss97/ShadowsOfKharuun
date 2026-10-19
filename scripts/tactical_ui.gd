class_name KhTacticalUI
extends CanvasLayer

# The three selectors describe action categories; pending orders are separate.
const CATEGORIES = [["attack", "flurry"], ["push", "lightning"], []]
const PERSONAL_CATEGORIES = [["heal"], ["medkit"]]
const CATEGORY_NAMES = ["ARMA", "ENERGÍA", "ARROJADIZOS"]
const SHORTCUTS = {"attack":"3", "flurry":"4", "push":"1", "lightning":"2", "heal":"5", "medkit":"6"}
const SELECTOR_SIZE = Vector2(150, 72)
const TARGET_HEAD_HEIGHT = 2.15

class ActionGlyph extends Control:
	var action = "attack"
	var tint = KhUI.GOLD
	func _draw() -> void:
		# The same glyphs fit both the compact target card and the personal menu.
		draw_set_transform(size * 0.5, 0.0, Vector2.ONE * minf(minf(size.x, size.y) / 48.0, 1.0))
		var c = Vector2.ZERO
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
			"talk":
				draw_arc(c+Vector2(-6,-7),8,0,TAU,24,color,2,true)
				draw_line(c+Vector2(-6,1),c+Vector2(-6,16),color,3,true)
				for radius in [7.0,14.0]: draw_arc(c+Vector2(7,-7),radius,-0.7,0.7,12,color,2,true)
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
var current_button: Button
var current_glyph: ActionGlyph
var queue_glyphs: Array[ActionGlyph] = []
var orders_panel: PanelContainer
var personal_panel: PanelContainer
var target_info: PanelContainer
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
var heal_button: Button
var heal_glyph: ActionGlyph
var personal_indices = [0,0]
var selection_reticle: Control
var talk_button: Button
var relic_button: Button
var target_selectors: PanelContainer
var target_name_label: Label
var target_health_bar: ProgressBar
var target_head_screen = Vector2.ZERO
var help_overlay: Control
var help_seen = false
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
	selection_reticle = SelectionReticle.new()
	root.add_child(selection_reticle)
	selection_reticle.size = Vector2(56,56)
	selection_reticle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	talk_button = _button("",40,true)
	root.add_child(talk_button)
	talk_button.size = Vector2(48,40)
	talk_button.tooltip_text = "Hablar con el personaje seleccionado"
	talk_button.pressed.connect(func():
		var combat = _combat()
		if combat != null: combat.level.request_talk(combat.selected))
	var voice = ActionGlyph.new()
	talk_button.add_child(voice)
	voice.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	voice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	voice.set_action("talk",true)
	talk_button.hide()
	selection_reticle.hide()
	relic_button = _button("",40,true)
	root.add_child(relic_button)
	relic_button.size = Vector2(40,40)
	relic_button.tooltip_text = "Núcleo de Kharuun · Reclamar\nClic: acercarse y recoger"
	relic_button.pressed.connect(func(): main.level.request_relic())
	var hand = KhContextCursor.Pointer.new()
	relic_button.add_child(hand)
	hand.context = "hand"
	hand.position = Vector2(3,3)
	hand.size = Vector2(34,34)
	hand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	relic_button.hide()

class SelectionReticle extends Control:
	func _draw() -> void:
		for index in range(4):
			var angle = float(index)*PI/2
			draw_arc(size*0.5,25,angle+0.16,angle+PI/2-0.16,12,KhUI.GOLD,3,true)

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
	var panel_style = KhUI.style(Color(0.018, 0.035, 0.038, 0.87), Color(0.12, 0.52, 0.47))
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
	pause_banner = _panel(Vector2(-258, 126), Vector2(240, 40), Control.PRESET_TOP_RIGHT)
	pause_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var banner_style = pause_banner.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	banner_style.content_margin_top = 4
	banner_style.content_margin_bottom = 4
	pause_banner.add_theme_stylebox_override("panel", banner_style)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_banner.add_child(column)
	var title = KhUI.label("PAUSA TÁCTICA", 14, KhUI.GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var explanation = KhUI.label("Prepara órdenes · ESPACIO para reanudar", 10)
	explanation.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(explanation)
	pause_banner.hide()

func _selector_button(title: String, height: float, accent: bool = false) -> Button:
	var button = _button(title, height, accent)
	button.add_theme_font_size_override("font_size", 10)
	for state in ["normal", "hover", "focus", "pressed", "disabled"]:
		var compact_style = button.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		compact_style.content_margin_left = 0
		compact_style.content_margin_right = 0
		compact_style.content_margin_top = 0
		compact_style.content_margin_bottom = 0
		button.add_theme_stylebox_override(state, compact_style)
	return button

func _build_selectors() -> void:
	target_selectors = _panel(Vector2.ZERO, SELECTOR_SIZE, Control.PRESET_TOP_LEFT)
	target_selectors.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var compact_style = target_selectors.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	compact_style.content_margin_left = 6
	compact_style.content_margin_right = 6
	compact_style.content_margin_top = 5
	compact_style.content_margin_bottom = 5
	target_selectors.add_theme_stylebox_override("panel", compact_style)
	var contents = VBoxContainer.new()
	contents.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contents.add_theme_constant_override("separation", 3)
	target_selectors.add_child(contents)
	target_info = _panel(Vector2.ZERO,Vector2(180,30),Control.PRESET_TOP_LEFT)
	target_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var info_style = target_info.get_theme_stylebox("panel").duplicate()
	info_style.content_margin_top = 2
	info_style.content_margin_bottom = 2
	target_info.add_theme_stylebox_override("panel",info_style)
	var info = VBoxContainer.new()
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_theme_constant_override("separation",1)
	target_info.add_child(info)
	target_name_label = KhUI.label("",10,Color(0.35,0.85,0.75))
	target_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	info.add_child(target_name_label)
	target_health_bar = main.ui.bar(Color(0.71,0.09,0.12),4)
	target_health_bar.custom_minimum_size.x = 0
	target_health_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(target_health_bar)
	target_info.hide()
	var row = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 6)
	contents.add_child(row)
	for category in range(3):
		var column = VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.custom_minimum_size.x = 40
		column.add_theme_constant_override("separation", 1)
		column.mouse_filter = Control.MOUSE_FILTER_STOP
		column.gui_input.connect(_selector_input.bind(category, column))
		row.add_child(column)
		column.tooltip_text = CATEGORY_NAMES[category]
		var up = _selector_button("▲", 12)
		column.add_child(up)
		up.pressed.connect(_cycle_category.bind(category, -1))
		up.gui_input.connect(_selector_input.bind(category, up))
		var select = _selector_button("", 34, category < 2)
		select.gui_input.connect(_selector_input.bind(category, select))
		select.pressed.connect(_enqueue_selected.bind(category))
		column.add_child(select)
		var glyph = ActionGlyph.new()
		select.add_child(glyph)
		glyph.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
		selector_glyphs.append(glyph)
		action_buttons.append(select)
		var name_label = KhUI.label("", 10)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		selector_labels.append(name_label)
		var down = _selector_button("▼", 12)
		column.add_child(down)
		down.pressed.connect(_cycle_category.bind(category, 1))
		down.gui_input.connect(_selector_input.bind(category, down))
		selector_arrows.append([up, down])
		column.add_child(name_label)
		name_label.hide()
	target_selectors.hide()

func _build_personal_menu() -> void:
	personal_panel = _panel(Vector2(16,-100),Vector2(232,84),Control.PRESET_BOTTOM_LEFT)
	var panel_style = personal_panel.get_theme_stylebox("panel").duplicate()
	panel_style.content_margin_top = 4
	panel_style.content_margin_bottom = 4
	personal_panel.add_theme_stylebox_override("panel",panel_style)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation",5)
	personal_panel.add_child(row)
	for category in range(PERSONAL_CATEGORIES.size()):
		var item = VBoxContainer.new()
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item.add_theme_constant_override("separation",1)
		row.add_child(item)
		var up = _selector_button("▲",10)
		item.add_child(up)
		up.disabled = PERSONAL_CATEGORIES[category].size() < 2
		up.pressed.connect(_cycle_personal.bind(category,-1))
		var action_button = _selector_button("",32,true)
		item.add_child(action_button)
		action_button.pressed.connect(_enqueue_personal.bind(category))
		action_button.gui_input.connect(_personal_input.bind(category,action_button))
		var glyph = ActionGlyph.new()
		action_button.add_child(glyph)
		glyph.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var down = _selector_button("▼",10)
		item.add_child(down)
		down.disabled = PERSONAL_CATEGORIES[category].size() < 2
		down.pressed.connect(_cycle_personal.bind(category,1))
		var name_label = KhUI.label("Curación" if category == 0 else "×3",9)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item.add_child(name_label)
		if category == 1:
			medkit_button = action_button
			medkit_glyph = glyph
			medkit_label = name_label
		else:
			heal_button = action_button
			heal_glyph = glyph
	for future in ["Escudo","Forma"]:
		var empty = VBoxContainer.new()
		empty.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		empty.add_theme_constant_override("separation",1)
		row.add_child(empty)
		for caption in ["▲","—","▼"]:
			var unavailable = _selector_button(caption,32 if caption == "—" else 10)
			unavailable.disabled = true
			unavailable.tooltip_text = "%s · hueco para otra iteración" % future
			empty.add_child(unavailable)
		var caption = KhUI.label(future,9,KhUI.DIM)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.add_child(caption)

func _build_orders() -> void:
	orders_panel = _panel(Vector2(-122,-106),Vector2(244,90),Control.PRESET_CENTER_BOTTOM)
	var panel_style = orders_panel.get_theme_stylebox("panel").duplicate()
	panel_style.content_margin_left = 5
	panel_style.content_margin_right = 5
	panel_style.content_margin_top = 4
	panel_style.content_margin_bottom = 4
	panel_style.border_color = Color(0.8,0.3,0.12)
	orders_panel.add_theme_stylebox_override("panel",panel_style)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation",3)
	orders_panel.add_child(column)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation",3)
	column.add_child(row)
	for index in range(4):
		var slot = _selector_button("",30)
		slot.custom_minimum_size.x = 29
		row.add_child(slot)
		slot.pressed.connect(_cancel_order.bind(index))
		queue_buttons.append(slot)
		var glyph = ActionGlyph.new()
		slot.add_child(glyph)
		glyph.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
		queue_glyphs.append(glyph)
	row.add_child(KhUI.label("›",21,KhUI.GOLD))
	current_button = _selector_button("",44,true)
	current_button.custom_minimum_size.x = 46
	row.add_child(current_button)
	current_glyph = ActionGlyph.new()
	current_button.add_child(current_glyph)
	current_glyph.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	current_glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	round_label = KhUI.label("",9,KhUI.IVORY)
	current_button.add_child(round_label)
	_place(round_label,Vector2(0,-11),Vector2(46,11),Control.PRESET_BOTTOM_LEFT)
	round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	current_label = KhUI.label("",11)
	column.add_child(current_label)
	current_label.hide()
	round_bar = main.ui.bar(Color(0.72,0.30,0.13),3)
	round_bar.custom_minimum_size.x = 0
	column.add_child(round_bar)
	var controls = HBoxContainer.new()
	controls.add_theme_constant_override("separation",3)
	column.add_child(controls)
	pause_button = _selector_button("Ⅱ",24)
	pause_button.custom_minimum_size.x = 24
	pause_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pause_button.tooltip_text = "Pausar / reanudar [Espacio]"
	pause_button.pressed.connect(_toggle_pause)
	controls.add_child(pause_button)
	retreat_button = _selector_button("Cancelar combate",24)
	retreat_button.tooltip_text = "[F] Cancela órdenes y libera movimiento; los enemigos siguen atacando."
	retreat_button.pressed.connect(_retreat)
	controls.add_child(retreat_button)
	clear_button = _selector_button("×",24)
	clear_button.custom_minimum_size.x = 24
	clear_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	clear_button.tooltip_text = "Limpiar cola · la acción actual continúa"
	clear_button.pressed.connect(_clear_orders)
	controls.add_child(clear_button)
	result_label = KhUI.label("",12,KhUI.GOLD)
	root.add_child(result_label)
	_place(result_label,Vector2(-280,16),Vector2(560,24),Control.PRESET_CENTER_TOP)
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	context_hint = KhUI.label("",11)
	root.add_child(context_hint)
	_place(context_hint,Vector2(-360,-135),Vector2(720,23),Control.PRESET_CENTER_BOTTOM)
	context_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

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
	column.add_child(KhUI.label("ESPACIO reanuda. Sin órdenes, esperas al alcance cuerpo a cuerpo.\nF cancela el combate y libera movimiento; los enemigos siguen atacando.", 15))
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
	personal_indices = [0,0]

func _cycle_personal(category: int, direction: int) -> void:
	personal_indices[category] = posmod(personal_indices[category]+direction,PERSONAL_CATEGORIES[category].size())

func _enqueue_personal(category: int) -> void:
	_add_order(PERSONAL_CATEGORIES[category][personal_indices[category]])

func _personal_input(event: InputEvent, category: int, control: Control) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
		_cycle_personal(category,-1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1)
		control.accept_event()

func _position_context(combat: Node) -> void:
	if not combat.enabled or not combat.selection_valid(combat.selected):
		selection_reticle.hide()
		talk_button.hide()
		return
	var enemy: KhEnemy = combat.selected
	var camera = get_viewport().get_camera_3d()
	var center: Vector3 = enemy.rig.to_global(Vector3(0,1.0,0))
	if camera.is_position_behind(center):
		selection_reticle.hide()
		talk_button.hide()
		return
	var query = PhysicsRayQueryParameters3D.create(camera.global_position,center,1)
	if not enemy.get_world_3d().direct_space_state.intersect_ray(query).is_empty():
		selection_reticle.hide()
		talk_button.hide()
		return
	var screen = root.get_global_transform_with_canvas().affine_inverse()*camera.unproject_position(center)
	if not Rect2(Vector2.ZERO,root.size).has_point(screen):
		selection_reticle.hide()
		talk_button.hide()
		return
	selection_reticle.position = screen-Vector2(28,28)
	selection_reticle.show()
	if enemy.active or not combat.level.can_talk(enemy):
		talk_button.hide()
		return
	var head: Vector3 = enemy.rig.to_global(Vector3(0,TARGET_HEAD_HEIGHT,0))
	var action_position = root.get_global_transform_with_canvas().affine_inverse()*camera.unproject_position(head)-Vector2(24,54)
	if action_position.y < 8 or action_position.x < 8 or action_position.x+48 > root.size.x-8:
		talk_button.hide()
		return
	talk_button.position = action_position
	talk_button.show()

func _combat() -> Node:
	if not is_instance_valid(main) or not is_instance_valid(main.level): return null
	return main.level.combat

func _position_relic() -> void:
	var level = main.level
	if not level.temple_open or main.mission.state != KhMission.State.TEMPLE:
		relic_button.hide()
		return
	var camera = level.player.camera
	var world: Vector3 = level.relic_position+Vector3(0,1.5,0)
	var ray = PhysicsRayQueryParameters3D.create(camera.global_position,level.relic_position,1)
	if camera.is_position_behind(world) or not level.get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
		relic_button.hide()
		return
	var screen = root.get_global_transform_with_canvas().affine_inverse()*camera.unproject_position(world)
	var pos = screen-Vector2(20,40)
	if pos.x < 8 or pos.y < 8 or pos.x+40 > root.size.x-8 or pos.y+40 > root.size.y-8:
		relic_button.hide()
		return
	relic_button.position = pos
	relic_button.show()

func _position_target_selectors(combat: Node) -> void:
	if not combat.enabled or not combat.selection_valid(combat.selected):
		target_selectors.hide()
		target_info.hide()
		return
	var enemy: KhEnemy = combat.selected
	var camera = get_viewport().get_camera_3d()
	var head_world: Vector3 = enemy.rig.to_global(Vector3(0,TARGET_HEAD_HEIGHT,0))
	var projected = camera.unproject_position(head_world)
	var query = PhysicsRayQueryParameters3D.create(camera.global_position,head_world,1)
	if camera.is_position_behind(head_world) or not get_viewport().get_visible_rect().has_point(projected) or not enemy.get_world_3d().direct_space_state.intersect_ray(query).is_empty():
		target_selectors.hide()
		target_info.hide()
		return
	target_head_screen = root.get_global_transform_with_canvas().affine_inverse()*projected
	target_name_label.text = enemy.display_name
	target_health_bar.value = enemy.health/enemy.max_health*100.0
	target_info.tooltip_text = "%s · salud %d/%d" % [enemy.display_name,ceili(enemy.health),int(enemy.max_health)]
	var offensive: bool = combat.engaged and combat.target_valid(enemy) and main.mission.state in [KhMission.State.COMBAT,KhMission.State.BOSS,KhMission.State.DUEL]
	var dimensions = target_selectors.size.max(SELECTOR_SIZE)
	var action_height = dimensions.y+4 if offensive else (44.0 if combat.level.can_talk(enemy) else 0.0)
	var panel_position = target_head_screen-Vector2(dimensions.x*0.5,dimensions.y+12)
	panel_position.x = clampf(panel_position.x,8,root.size.x-dimensions.x-8)
	var info_position = target_head_screen-Vector2(target_info.size.x*0.5,action_height+target_info.size.y+12)
	info_position.x = clampf(info_position.x,8,root.size.x-target_info.size.x-8)
	if info_position.y < 8:
		target_selectors.hide()
		target_info.hide()
		return
	target_info.position = info_position
	target_info.show()
	if offensive:
		target_selectors.position = panel_position
		target_selectors.show()
	else: target_selectors.hide()
	if pause_banner.visible and (target_info.get_global_rect().intersects(pause_banner.get_global_rect()) or (offensive and target_selectors.get_global_rect().intersects(pause_banner.get_global_rect()))): pause_banner.hide()

func _process(delta: float) -> void:
	var combat = _combat()
	root.visible = combat != null and main.ui.hud.visible and not main.paused and not main.inventory_open
	if not root.visible:
		target_selectors.hide()
		selection_reticle.hide()
		talk_button.hide()
		target_info.hide()
		relic_button.hide()
		return
	pause_banner.visible = main.tactical_paused
	pause_button.text = "▶" if main.tactical_paused else "Ⅱ"
	var selected_valid: bool = combat.target_valid(combat.selected)
	_position_target_selectors(combat)
	_position_context(combat)
	_position_relic()
	for category in range(3):
		var actions: Array = CATEGORIES[category]
		var unavailable: bool = actions.is_empty()
		for arrow in selector_arrows[category]: arrow.disabled = unavailable
		if unavailable:
			action_buttons[category].disabled = true
			action_buttons[category].tooltip_text = "Arrojadizos · disponibles en una futura iteración"
			selector_labels[category].text = "Vacío"
			selector_labels[category].add_theme_color_override("font_color", KhUI.DIM)
			selector_glyphs[category].set_action("empty", false)
			continue
		var id: String = actions[category_indices[category]]
		var self_target = id == "heal"
		action_buttons[category].disabled = not combat.enabled or combat.queue.size() >= 4 or (not self_target and not selected_valid) or combat.player.energy < combat.ACTIONS[id].cost
		var cost: int = int(combat.ACTIONS[id].get("cost", 0))
		selector_labels[category].text = "Sobre ti" if self_target else combat.action_name(id)
		selector_labels[category].add_theme_color_override("font_color", KhUI.IVORY)
		var destination = "Sobre ti" if self_target else ("→ " + combat.selected.display_name if selected_valid else "Selecciona un enemigo")
		var effect = " · dos intentos de impacto" if id == "flurry" else (" · un impacto" if id == "attack" else "")
		action_buttons[category].tooltip_text = "%s [%s] · %s%s%s\nClic: encolar · flechas/rueda: cambiar sin dar una orden" % [combat.action_name(id), SHORTCUTS[id], destination, " · %d de energía" % cost if cost > 0 else "", effect]
		selector_glyphs[category].set_action(id, not action_buttons[category].disabled)
	medkit_label.text = "×%d" % combat.medkits if combat.medkits > 0 else "Agotado"
	medkit_button.disabled = not combat.enabled or combat.medkits <= 0 or combat.queue.size() >= 4
	medkit_button.tooltip_text = "Botiquines agotados" if combat.medkits <= 0 else "Sobre ti · encola una curación. Consume una unidad al ejecutar, aunque tengas toda la salud."
	medkit_glyph.set_action("medkit" if combat.medkits > 0 else "empty", not medkit_button.disabled)
	heal_button.disabled = not combat.enabled or combat.queue.size() >= 4 or combat.player.energy < combat.ACTIONS.heal.cost
	heal_button.tooltip_text = "Curación propia [5] · Sobre ti · 28 de energía · una acción"
	heal_glyph.set_action("heal",not heal_button.disabled)
	var current: Dictionary = combat.current_action
	if not current.is_empty():
		current_label.text = "En curso: %s → %s" % [combat.action_name(str(current.get("id", "attack"))), str(current.get("target_name", "Tú"))]
	elif not combat.queue.is_empty():
		var next_order: Dictionary = combat.queue[0]
		current_label.text = "Próxima: %s → %s" % [combat.action_name(str(next_order.get("id", "attack"))), str(next_order.get("target_name", "Tú"))]
	elif combat.engaged and combat.target_valid(combat.last_offensive_target):
		current_label.text = "Básico automático al entrar en alcance → %s" % combat.last_offensive_target.display_name
	elif combat.engaged and selected_valid:
		current_label.text = "Esperando alcance cuerpo a cuerpo → %s" % combat.selected.display_name
	else:
		current_label.text = "Movimiento libre · clic en enemigo para combatir"
	var round_active: bool = combat.engaged or not current.is_empty() or combat.round_left > 0
	round_label.text = "%.1f s" % maxf(combat.round_left,0.0) if combat.round_left > 0 else ""
	round_bar.value = clampf((1.0 - combat.round_left / maxf(combat.round_seconds, 0.01)) * 100.0, 0.0, 100.0) if round_active else 0.0
	for index in range(queue_buttons.size()):
		var slot = queue_buttons[index]
		var occupied: bool = index < combat.queue.size()
		slot.disabled = not occupied
		queue_glyphs[index].visible = occupied
		if occupied:
			var order: Dictionary = combat.queue[index]
			var order_name: String = combat.action_name(str(order.get("id", "attack")))
			var target_name = str(order.get("target_name", "Tú"))
			slot.text = ""
			queue_glyphs[index].set_action(str(order.id),true)
			slot.tooltip_text = "%s → %s\nClic: cancelar esta orden pendiente" % [order_name, target_name]
		else:
			slot.text = ""
			queue_glyphs[index].set_action("empty",false)
			slot.tooltip_text = "Orden pendiente vacía"
	orders_panel.visible = combat.engaged or not current.is_empty() or not combat.queue.is_empty()
	var shown: Dictionary = current
	current_glyph.set_action(str(shown.get("id","empty")),not shown.is_empty())
	current_glyph.visible = not shown.is_empty()
	current_button.tooltip_text = current_label.text+"\n"+combat.last_result
	clear_button.disabled = combat.queue.is_empty()
	retreat_button.disabled = not combat.engaged and combat.queue.is_empty() and current.is_empty()
	pause_button.disabled = not combat.enabled
	result_label.text = combat.ability_error
	result_label.visible = combat.error_time > 0
	if was_engaged and not combat.engaged and combat.enabled:
		_context_once("retreat", "Movimiento libre: W/S avanzar y retroceder; A/D girar el personaje.")
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
