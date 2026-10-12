class_name KhMenu
extends Control
signal start_requested
signal duel_requested
signal quit_requested

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade = ColorRect.new()
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.025,0.015,0.025,0.32)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var left = PanelContainer.new()
	add_child(left)
	left.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	left.offset_right = 645
	left.add_theme_stylebox_override("panel",KhUI.style(Color(0.024,0.022,0.032,0.83),Color(0.32,0.20,0.12),0))
	var content = VBoxContainer.new()
	left.add_child(content)
	content.add_theme_constant_override("separation",12)
	var margin = MarginContainer.new()
	left.remove_child(content)
	left.add_child(margin)
	margin.add_theme_constant_override("margin_left",65)
	margin.add_theme_constant_override("margin_right",40)
	margin.add_theme_constant_override("margin_top",65)
	margin.add_theme_constant_override("margin_bottom",45)
	margin.add_child(content)
	content.add_child(KhUI.label("UNA SOMBRA BAJO EL IMPERIO",14,KhUI.GOLD))
	var title = KhUI.label("SHADOWS\nOF KHARUUN",53,KhUI.IVORY)
	var serif = SystemFont.new()
	serif.font_names = PackedStringArray(["Georgia","Times New Roman"])
	title.add_theme_font_override("font",serif)
	content.add_child(title)
	var line = HSeparator.new()
	content.add_child(line)
	var description = KhUI.label("Un templo olvidado.\nUn poder que nunca debió despertar.",19,Color(0.68,0.65,0.67))
	content.add_child(description)
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 28
	content.add_child(spacer)
	var duel = KhUI.button("Duelo táctico · nueva iteración",true)
	duel.custom_minimum_size = Vector2(360,52)
	content.add_child(duel)
	duel.pressed.connect(func(): duel_requested.emit())
	var start = KhUI.button("Nueva partida · misión original")
	start.custom_minimum_size = Vector2(360,56)
	content.add_child(start)
	start.pressed.connect(func(): start_requested.emit())
	var quit = KhUI.button("Salir")
	quit.custom_minimum_size.y = 48
	content.add_child(quit)
	quit.pressed.connect(func(): quit_requested.emit())
	content.add_child(KhUI.label("DEMO RPG 3D  ·  UNA MISIÓN",12,KhUI.GOLD))
	duel.grab_focus()
	var credit = KhUI.label("KHARUUN  /  EL UMBRAL DE CENIZA",12,Color(0.80,0.63,0.43))
	add_child(credit)
	credit.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	credit.offset_left = -400
	credit.offset_top = -40
	credit.offset_right = -30
	credit.offset_bottom = -14
	credit.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
