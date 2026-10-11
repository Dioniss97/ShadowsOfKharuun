class_name KhUI
extends CanvasLayer
signal restart_requested
signal menu_requested
signal resume_requested
signal choice_selected(index: int)
signal dialogue_continue
const IVORY = Color(0.90,0.86,0.78)
const GOLD = Color(0.75,0.51,0.28)
const DIM = Color(0.56,0.55,0.57)
var root: Control
var hud: Control
var dialog_panel: PanelContainer
var dialog_content: VBoxContainer
var overlay: Control
var menu: KhMenu
var objective_label: Label
var health_bar: ProgressBar
var energy_bar: ProgressBar
var health_label: Label
var energy_label: Label
var target_panel: VBoxContainer
var target_label: Label
var target_bar: ProgressBar
var ability_labels: Array = []
var ability_bars: Array = []
var message: Label
var hint: Label
var timer_label: Label
var flash: ColorRect
var toast: Label
var toast_time = 0.0
var main: Node
var last_health = 340.0

static func style(bg: Color, border: Color = GOLD, width: int = 1) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(width)
	s.set_corner_radius_all(3)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	return s

static func label(text: String, font_size: int = 18, color: Color = IVORY) -> Label:
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size",font_size)
	l.add_theme_color_override("font_color",color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

static func button(text: String, accent: bool = false) -> Button:
	var b = Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size",18)
	b.add_theme_color_override("font_color",IVORY)
	b.add_theme_stylebox_override("normal",style(Color(0.16,0.063,0.055,0.97) if accent else Color(0.055,0.045,0.055,0.95),GOLD))
	b.add_theme_stylebox_override("hover",style(Color(0.28,0.11,0.07),Color(1,0.72,0.40),2))
	b.add_theme_stylebox_override("focus",style(Color(0.13,0.08,0.06),Color(1,0.72,0.40),2))
	b.add_theme_stylebox_override("pressed",style(Color(0.36,0.14,0.075),GOLD,2))
	return b

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root = Control.new()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vignette = ColorRect.new()
	root.add_child(vignette)
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vm = ShaderMaterial.new()
	vm.shader = preload("res://assets/vignette.gdshader")
	vignette.material = vm
	build_hud()
	dialog_panel = PanelContainer.new()
	root.add_child(dialog_panel)
	dialog_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	dialog_panel.offset_left = 70
	dialog_panel.offset_right = -70
	dialog_panel.offset_top = -335
	dialog_panel.offset_bottom = -24
	dialog_panel.add_theme_stylebox_override("panel",style(Color(0.033,0.028,0.042,0.96)))
	dialog_content = VBoxContainer.new()
	dialog_content.add_theme_constant_override("separation",10)
	dialog_panel.add_child(dialog_content)
	dialog_panel.hide()
	flash = ColorRect.new()
	root.add_child(flash)
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(0.85,0.03,0.0,0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE

func panel_at(parent: Control, pos: Vector2, dimensions: Vector2, preset: int) -> PanelContainer:
	var p = PanelContainer.new()
	parent.add_child(p)
	place(p,pos,dimensions,preset)
	p.add_theme_stylebox_override("panel",style(Color(0.027,0.029,0.042,0.88),Color(0.35,0.25,0.17)))
	return p

func place(control: Control, pos: Vector2, dimensions: Vector2, preset: int) -> void:
	control.set_anchors_and_offsets_preset(preset)
	control.offset_left = pos.x
	control.offset_top = pos.y
	control.offset_right = pos.x+dimensions.x
	control.offset_bottom = pos.y+dimensions.y

func bar(color: Color, height: float = 8) -> ProgressBar:
	var p = ProgressBar.new()
	p.custom_minimum_size = Vector2(240,height)
	p.show_percentage = false
	var background = style(Color(0.075,0.055,0.065),Color(0.2,0.16,0.13))
	var fill = style(color,color,0)
	for s in [background,fill]:
		s.content_margin_left = 0
		s.content_margin_right = 0
		s.content_margin_top = 0
		s.content_margin_bottom = 0
	p.add_theme_stylebox_override("background",background)
	p.add_theme_stylebox_override("fill",fill)
	return p

func build_hud() -> void:
	hud = Control.new()
	root.add_child(hud)
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var objective = panel_at(hud,Vector2(28,25),Vector2(390,84),Control.PRESET_TOP_LEFT)
	var objective_box = VBoxContainer.new()
	objective.add_child(objective_box)
	objective_box.add_child(label("KHARUUN  /  OBJETIVO",11,GOLD))
	objective_label = label("Alcanza la entrada del templo",18)
	objective_box.add_child(objective_label)
	var status = panel_at(hud,Vector2(28,-160),Vector2(278,132),Control.PRESET_BOTTOM_LEFT)
	var status_box = VBoxContainer.new()
	status.add_child(status_box)
	health_label = label("VITALIDAD   340 / 340",12)
	status_box.add_child(health_label)
	health_bar = bar(Color(0.70,0.15,0.12),11)
	status_box.add_child(health_bar)
	energy_label = label("ENERGÍA   100 / 100",12,Color(0.57,0.72,0.85))
	status_box.add_child(energy_label)
	energy_bar = bar(Color(0.23,0.49,0.70),7)
	status_box.add_child(energy_bar)
	var actions = HBoxContainer.new()
	hud.add_child(actions)
	place(actions,Vector2(-242,-111),Vector2(484,78),Control.PRESET_CENTER_BOTTOM)
	actions.add_theme_constant_override("separation",10)
	var names = ["CLIC  /  ARMA","1  /  EMPUJE","2  /  DESCARGA"]
	var icons = ["╱","◎","ϟ"]
	for i in range(3):
		var card = PanelContainer.new()
		actions.add_child(card)
		card.custom_minimum_size = Vector2(151,80)
		card.add_theme_stylebox_override("panel",style(Color(0.025,0.027,0.039,0.89),GOLD))
		var v = VBoxContainer.new()
		card.add_child(v)
		var l = label(icons[i]+"  "+names[i],12,IVORY)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(l)
		var cooldown_label = label("LISTO",11,GOLD)
		cooldown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(cooldown_label)
		ability_labels.append(cooldown_label)
		var p = bar(Color(0.53,0.31,0.16),4)
		p.custom_minimum_size.x = 110
		v.add_child(p)
		ability_bars.append(p)
	var controls = label("WASD  Mover   ·   SHIFT  Correr\nE  Interactuar   ·   ESC  Pausa",12,DIM)
	hud.add_child(controls)
	place(controls,Vector2(-315,-77),Vector2(295,56),Control.PRESET_BOTTOM_RIGHT)
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	timer_label = label("00:00",15,GOLD)
	hud.add_child(timer_label)
	place(timer_label,Vector2(-108,30),Vector2(80,26),Control.PRESET_TOP_RIGHT)
	target_panel = VBoxContainer.new()
	hud.add_child(target_panel)
	place(target_panel,Vector2(-190,30),Vector2(380,50),Control.PRESET_CENTER_TOP)
	target_panel.custom_minimum_size = Vector2(380,50)
	target_label = label("",16)
	target_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_panel.add_child(target_label)
	target_bar = bar(Color(0.71,0.09,0.12),8)
	target_panel.add_child(target_bar)
	target_panel.hide()
	message = label("",16,Color(1,0.7,0.4))
	hud.add_child(message)
	place(message,Vector2(-300,-154),Vector2(600,28),Control.PRESET_CENTER_BOTTOM)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint = label("",14,IVORY)
	hud.add_child(hint)
	place(hint,Vector2(-280,115),Vector2(560,28),Control.PRESET_CENTER)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast = label("",24,IVORY)
	hud.add_child(toast)
	place(toast,Vector2(-400,132),Vector2(800,42),Control.PRESET_CENTER_TOP)
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func clear_overlay() -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()
		overlay = null
	if is_instance_valid(menu):
		menu.queue_free()
		menu = null

func show_menu() -> void:
	clear_overlay()
	hud.hide()
	dialog_panel.hide()
	menu = KhMenu.new()
	root.add_child(menu)
	menu.start_requested.connect(func(): main.new_game())
	menu.quit_requested.connect(func(): main.get_tree().quit())

func show_game() -> void:
	clear_overlay()
	hud.show()
	dialog_panel.hide()
	last_health = main.level.player.health
	announce("EL UMBRAL DE CENIZA")

func show_dialogue(dialogue: KhDialogue) -> void:
	hud.hide()
	dialog_panel.show()
	for child in dialog_content.get_children():
		dialog_content.remove_child(child)
		child.queue_free()
	dialog_content.add_child(label("GUARDIÁN DE KHARUUN",13,GOLD))
	var body_text = label("«%s»" % dialogue.text,20,IVORY)
	body_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_text.custom_minimum_size.y = 65
	dialog_content.add_child(body_text)
	if dialogue.awaiting_choice:
		for i in range(3):
			var b = button("%d.  %s" % [i+1,KhDialogue.OPTIONS[i]])
			b.custom_minimum_size.y = 39
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			dialog_content.add_child(b)
			b.pressed.connect(func(): choice_selected.emit(i))
	else:
		var b = button("Continuar  [E / INTRO]",true)
		b.custom_minimum_size.y = 45
		dialog_content.add_child(b)
		b.pressed.connect(func(): dialogue_continue.emit())
		b.grab_focus()

func hide_dialogue() -> void:
	dialog_panel.hide()
	hud.show()

func make_overlay() -> VBoxContainer:
	clear_overlay()
	overlay = Control.new()
	root.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade = ColorRect.new()
	overlay.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.014,0.015,0.025,0.82)
	var center = CenterContainer.new()
	overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel = PanelContainer.new()
	center.add_child(panel)
	panel.custom_minimum_size = Vector2(660,310)
	panel.add_theme_stylebox_override("panel",style(Color(0.035,0.025,0.035,0.97),GOLD))
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation",18)
	panel.add_child(v)
	return v

func show_end(victory: bool, elapsed: float) -> void:
	hud.hide()
	dialog_panel.hide()
	var v = make_overlay()
	var sub = label("EL UMBRAL HA SIDO QUEBRADO" if victory else "EL TEMPLO RECLAMA OTRA ALMA",12,GOLD)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(sub)
	var title = label("DEMO COMPLETADA" if victory else "HAS CAÍDO",39)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	var text = label("«El templo ha caído. Pero algo antiguo\ncomienza a despertar»." if victory else "La sombra aún espera. Regresa al umbral.",21)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(text)
	if victory:
		var stats = label("4 enemigos derrotados  ·  Tiempo %02d:%02d" % [int(elapsed)/60,int(elapsed)%60],13,DIM)
		stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(stats)
	var restart = button("Repetir misión" if victory else "Reiniciar misión",true)
	v.add_child(restart)
	restart.pressed.connect(func(): restart_requested.emit())
	var return_button = button("Volver al menú")
	v.add_child(return_button)
	return_button.pressed.connect(func(): menu_requested.emit())
	restart.grab_focus()

func show_pause() -> void:
	var v = make_overlay()
	var title = label("PAUSA",36)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	v.add_child(label("WASD: movimiento · Ratón: cámara · Shift: correr",16))
	v.add_child(label("Clic: arma · 1: empuje · 2: descarga · E: interactuar",16))
	v.add_child(label("Los círculos rojos anuncian ataques. Aléjate para esquivarlos.",14,GOLD))
	var resume = button("Continuar  [ESC]",true)
	v.add_child(resume)
	resume.pressed.connect(func(): resume_requested.emit())
	var return_button = button("Volver al menú")
	v.add_child(return_button)
	return_button.pressed.connect(func(): menu_requested.emit())
	resume.grab_focus()

func announce(text: String) -> void:
	toast.text = text
	toast_time = 4.3

func _process(delta: float) -> void:
	flash.color.a = move_toward(flash.color.a,0,delta*0.6)
	if main == null or not is_instance_valid(main.level): return
	var p = main.level.player
	var combat = main.level.combat
	var mission = main.mission
	if p.health < last_health: flash.color.a = 0.17
	last_health = p.health
	health_bar.value = p.health/p.max_health*100
	energy_bar.value = p.energy
	health_label.text = "VITALIDAD   %d / %d" % [ceili(p.health),int(p.max_health)]
	energy_label.text = "ENERGÍA   %d / 100" % int(p.energy)
	objective_label.text = mission.objective()
	timer_label.text = "%02d:%02d" % [int(mission.elapsed)/60,int(mission.elapsed)%60]
	var cooldowns = [combat.attack_cooldown,combat.push_cooldown,combat.lightning_cooldown]
	var maxima = [0.80,7.0,10.0]
	for i in range(3):
		ability_labels[i].text = "%.1f s" % cooldowns[i] if cooldowns[i] > 0 else ("24 ENERGÍA" if i == 1 else ("32 ENERGÍA" if i == 2 else "LISTO"))
		ability_bars[i].value = (1.0-cooldowns[i]/maxima[i])*100
	message.text = combat.ability_error if combat.error_time > 0 else ""
	if is_instance_valid(combat.selected) and combat.enabled:
		target_panel.show()
		target_label.text = combat.selected.display_name
		target_bar.value = combat.selected.health/combat.selected.max_health*100
	else: target_panel.hide()
	hint.text = "E  Hablar con el guardián" if mission.state == KhMission.State.EXPLORATION and p.position.z < -6.5 else ("Acércate al enemigo · ataca · retrocede ante los círculos rojos" if mission.state == KhMission.State.COMBAT else "")
	if not main.get_tree().paused:
		toast_time = maxf(0,toast_time-delta)
	toast.modulate.a = minf(1,toast_time)
