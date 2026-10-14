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
	container.name = "Lightning"
	add_child(container)
	var mat = KhGeometry.material(Color(0.55,0.58,1.0),0.2,5)
	KhGeometry.sphere(container,a,0.06,mat)
	KhGeometry.light(container,a,Color(0.55,0.58,1.0),0.6,1.6)
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

func push_wave(a: Vector3, b: Vector3) -> void:
	var direction = a.direction_to(b)
	if direction.length_squared() < 0.001:
		direction = Vector3.FORWARD
	var node = KhGeometry.ring(self,a,0.7,KhGeometry.material(Color(0.45,0.83,1.0),0.3,3),0.04)
	node.name = "PushWave"
	# Torus normal is +Y. Turn the wave toward the recipient from the left palm.
	node.quaternion = Quaternion(Vector3.UP,direction)
	node.scale = Vector3.ONE*0.2
	var t = create_tween().set_parallel(true)
	t.tween_property(node,"position",a+direction*minf(a.distance_to(b),3.2),0.35)
	t.tween_property(node,"scale",Vector3.ONE*1.6,0.35)
	t.chain().tween_property(node,"scale",Vector3.ZERO,0.15)
	t.chain().tween_callback(node.queue_free)

func heal(pos: Vector3) -> void:
	var container = Node3D.new()
	container.name = "Healing"
	add_child(container)
	container.position = pos
	var green = Color(0.24,1.0,0.48,0.35)
	var mat = KhGeometry.material(green,0.3,2.5)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var orb = KhGeometry.sphere(container,Vector3(0,1.05,0),0.34,mat)
	for height in [0.3,1.15]:
		KhGeometry.ring(container,Vector3(0,height,0),0.55,mat,0.045)
	KhGeometry.light(container,Vector3(0,1.0,0),green,0.65,2.4)
	burst(pos+Vector3.UP*0.8,Color(0.3,1.0,0.52),8)
	var t = create_tween().set_parallel(true)
	t.tween_property(orb,"scale",Vector3.ONE*2.2,0.7)
	t.tween_property(mat,"albedo_color:a",0.0,0.7)
	t.chain().tween_callback(container.queue_free)

func damage_number(pos: Vector3, damage: int) -> void:
	status_text(pos,str(damage),Color(1,0.79,0.35))

func status_text(pos: Vector3, text: String, color: Color) -> void:
	var l = Label3D.new()
	add_child(l)
	l.position = pos
	l.text = text
	l.font_size = 36
	l.pixel_size = 0.0075
	l.modulate = color
	l.outline_modulate = Color(0.08,0.02,0.01)
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	var t = create_tween().set_parallel(true)
	t.tween_property(l,"position",pos+Vector3(0,1.3,0),0.7)
	t.tween_property(l,"modulate:a",0.0,0.7)
	t.chain().tween_callback(l.queue_free)
