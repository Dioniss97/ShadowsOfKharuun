class_name KhEffects
extends Node3D
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 190919

func burst(pos: Vector3, color: Color, count: int = 12) -> void:
	var mat = KhGeometry.material(color,0.3,3)
	for i in range(count):
		var node = KhGeometry.sphere(self,pos,0.045,mat)
		var offset = Vector3(rng.randf_range(-1,1),rng.randf_range(0.3,1.4),rng.randf_range(-1,1))
		var t = create_tween().set_parallel(true)
		t.tween_property(node,"position",pos+offset,0.4)
		t.tween_property(node,"scale",Vector3.ZERO,0.4)
		t.chain().tween_callback(node.queue_free)

func wave(pos: Vector3, radius: float, color: Color) -> void:
	var node = KhGeometry.ring(self,pos+Vector3(0,0.12,0),1.0,KhGeometry.material(color,0.3,3),0.065)
	node.scale = Vector3.ONE*0.2
	var t = create_tween()
	t.tween_property(node,"scale",Vector3.ONE*radius,0.4)
	t.tween_property(node,"scale",Vector3.ONE*(radius+0.8),0.15)
	t.tween_callback(node.queue_free)

func lightning(a: Vector3, b: Vector3) -> void:
	var container = Node3D.new()
	add_child(container)
	var mat = KhGeometry.material(Color(0.55,0.58,1.0),0.2,5)
	for branch in range(3):
		var prev = a
		for i in range(1,7):
			var p = a.lerp(b,float(i)/6)
			if i < 6:
				p += Vector3(rng.randf_range(-0.25,0.25),rng.randf_range(-0.25,0.25),rng.randf_range(-0.25,0.25))
			KhGeometry.beam(container,prev,p,0.022,mat)
			prev = p
	var t = create_tween()
	t.tween_interval(0.20)
	t.tween_callback(container.queue_free)

func damage_number(pos: Vector3, damage: int) -> void:
	var l = Label3D.new()
	add_child(l)
	l.position = pos
	l.text = str(damage)
	l.font_size = 36
	l.pixel_size = 0.0075
	l.modulate = Color(1,0.79,0.35)
	l.outline_modulate = Color(0.08,0.02,0.01)
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	var t = create_tween().set_parallel(true)
	t.tween_property(l,"position",pos+Vector3(0,1.3,0),0.7)
	t.tween_property(l,"modulate:a",0.0,0.7)
	t.chain().tween_callback(l.queue_free)
