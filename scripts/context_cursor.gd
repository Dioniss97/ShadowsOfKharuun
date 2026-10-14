class_name KhContextCursor
extends CanvasLayer

class Pointer extends Control:
	var context = "pointer"
	func _draw() -> void:
		var gold = Color(1,0.78,0.46)
		if context == "attack":
			draw_line(Vector2(8,27),Vector2(27,3),Color(0.02,0.02,0.03),7,true)
			draw_line(Vector2(8,27),Vector2(27,3),gold,3,true)
			draw_line(Vector2(3,16),Vector2(19,29),gold,3,true)
		elif context == "talk":
			draw_arc(Vector2(10,11),7,0,TAU,20,gold,2,true)
			draw_line(Vector2(10,18),Vector2(10,28),gold,3,true)
			for radius in [6.0,11.0]: draw_arc(Vector2(20,12),radius,-0.7,0.7,10,gold,2,true)
		elif context == "hand":
			var outline = PackedVector2Array([Vector2(8,27),Vector2(3,16),Vector2(5,14),Vector2(10,18),Vector2(10,4),Vector2(13,3),Vector2(15,15),Vector2(17,9),Vector2(20,9),Vector2(21,16),Vector2(24,12),Vector2(27,13),Vector2(27,23),Vector2(23,30),Vector2(8,27)])
			draw_colored_polygon(outline,Color(0.015,0.025,0.025))
			draw_polyline(outline,gold,2,true)
		else:
			var shape = PackedVector2Array([Vector2(2,2),Vector2(3,26),Vector2(9,20),Vector2(14,30),Vector2(19,27),Vector2(14,17),Vector2(23,16)])
			draw_colored_polygon(shape,Color(0.02,0.02,0.03))
			draw_polyline(shape,gold,2,true)

var main: Node
var pointer: Pointer
var context = "pointer"
var mouse_position = Vector2.ZERO

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	pointer = Pointer.new()
	add_child(pointer)
	pointer.size = Vector2(34,34)
	pointer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_position = get_viewport().get_mouse_position()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		mouse_position = event.position

func _process(_delta: float) -> void:
	# Use viewport input coordinates for both native and injected mouse events.
	pointer.position = mouse_position
	context = "pointer"
	if main.ui.hud.visible and not main.paused and main.tactical_ui.relic_button.visible and get_viewport().gui_get_hovered_control() == main.tactical_ui.relic_button:
		context = "hand"
	if is_instance_valid(main.level) and main.ui.hud.visible and not main.paused and not main.tactical_ui.help_overlay.visible and get_viewport().gui_get_hovered_control() == null:
		var combat = main.level.combat
		if main.level.relic_at_screen(pointer.position): context = "hand"
		else:
			var enemy = combat.screen_actor(pointer.position)
			if combat.enabled and enemy != null and enemy == combat.selected:
				if combat.target_valid(enemy): context = "attack"
				elif main.level.can_talk(enemy): context = "talk"
	pointer.context = context
	pointer.queue_redraw()
