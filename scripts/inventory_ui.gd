class_name KhInventoryUI
extends CanvasLayer

var main: Node
var panel: Control
var item_button: Button
var equip_button: Button
var remove_button: Button
var close_button: Button
var state_label: Label
var preview_rig: KhCharacterRig
var viewport: SubViewport
var preview_angle := -0.2
var observed: KhWardrobe

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	panel = Control.new()
	add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var background := ColorRect.new()
	panel.add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.014,0.018,0.025,0.985)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var margin := MarginContainer.new()
	panel.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side,42)
	for side in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,26)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation",18)
	margin.add_child(layout)
	var header := HBoxContainer.new()
	layout.add_child(header)
	var title := KhUI.label("INVENTARIO",28,KhUI.GOLD)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	close_button = KhUI.button("VOLVER  ·  I / ESC")
	close_button.pressed.connect(func(): main.close_inventory())
	header.add_child(close_button)
	layout.add_child(KhUI.label("EQUIPAMIENTO  /  UNIFORME COMPLETO",12,KhUI.DIM))
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",24)
	layout.add_child(body)
	var card := PanelContainer.new()
	card.custom_minimum_size.x = 420
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel",KhUI.style(Color(0.028,0.032,0.04),Color(0.29,0.24,0.17)))
	body.add_child(card)
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation",18)
	card.add_child(left)
	left.add_child(KhUI.label("DISPONIBLE",12,KhUI.GOLD))
	item_button = KhUI.button("Túnica del Umbral",true)
	item_button.pressed.connect(func():
		if equip_button.disabled: remove_button.grab_focus()
		else: equip_button.grab_focus())
	left.add_child(item_button)
	var description := KhUI.label("Túnica de grafito y capa posterior de tela,\nprendas inferiores, cinturón y botas.\n\nEl conjunto cambia como una sola pieza.\nLos objetos de cabeza se equipan aparte.",17)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(description)
	state_label = KhUI.label("",16,KhUI.GOLD)
	state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(state_label)
	equip_button = KhUI.button("EQUIPAR UNIFORME",true)
	remove_button = KhUI.button("RETIRAR UNIFORME")
	equip_button.pressed.connect(func(): main.level.player.wardrobe.equip_uniform(KhWardrobe.TUNIC))
	remove_button.pressed.connect(func(): main.level.player.wardrobe.remove_uniform())
	left.add_child(equip_button)
	left.add_child(remove_button)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.2
	body.add_child(right)
	right.add_child(KhUI.label("APARIENCIA ACTUAL",12,KhUI.GOLD))
	var view := SubViewportContainer.new()
	view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	view.stretch = true
	right.add_child(view)
	viewport = SubViewport.new()
	viewport.size = Vector2i(480,520)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	viewport.msaa_3d = Viewport.MSAA_2X
	view.add_child(viewport)
	_build_studio()
	var rotations := HBoxContainer.new()
	rotations.alignment = BoxContainer.ALIGNMENT_CENTER
	right.add_child(rotations)
	for direction in [-1,1]:
		var turn := KhUI.button("↶  GIRAR" if direction == -1 else "GIRAR  ↷")
		turn.pressed.connect(func(): preview_angle += direction*PI/4)
		rotations.add_child(turn)
	var footer := KhUI.label("Sin uniforme: ropa base y calzado.  ·  Cabeza: sin objeto equipado.",12,KhUI.DIM)
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(footer)
	panel.hide()

func _build_studio() -> void:
	var stage := Node3D.new()
	viewport.add_child(stage)
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.028,0.035,0.045)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.75,0.78,0.85)
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_AGX
	world.environment = env
	stage.add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-30,150,0)
	light.light_color = Color(1,0.92,0.82)
	light.light_energy = 1.7
	stage.add_child(light)
	preview_rig = KhCharacterRig.new()
	stage.add_child(preview_rig)
	preview_rig.build(Color.WHITE,Color(0.25,0.8,1))
	preview_rig.sword.hide()
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.45
	camera.position = Vector3(0,1.15,-5)
	stage.add_child(camera)
	camera.look_at(Vector3(0,1.02,0))
	camera.current = true

func show_inventory() -> void:
	if is_instance_valid(observed) and observed.changed.is_connected(refresh): observed.changed.disconnect(refresh)
	observed = main.level.player.wardrobe
	observed.changed.connect(refresh)
	refresh()
	viewport.process_mode = Node.PROCESS_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	panel.show()
	close_button.grab_focus()

func hide_inventory() -> void:
	panel.hide()
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	viewport.process_mode = Node.PROCESS_MODE_DISABLED
	if is_instance_valid(observed) and observed.changed.is_connected(refresh): observed.changed.disconnect(refresh)
	observed = null

func refresh() -> void:
	var equipped := observed.uniform_id != ""
	state_label.text = "Equipado: Túnica del Umbral" if equipped else "Sin uniforme equipado"
	item_button.text = "Túnica del Umbral  ·  EQUIPADA" if equipped else "Túnica del Umbral"
	equip_button.disabled = equipped
	remove_button.disabled = not equipped
	preview_rig.set_uniform(observed.uniform_id)

func _process(delta: float) -> void:
	if not panel.visible: return
	preview_rig.rotation.y = lerp_angle(preview_rig.rotation.y,preview_angle,1-exp(-delta*10))
	preview_rig.animate(delta,0)
