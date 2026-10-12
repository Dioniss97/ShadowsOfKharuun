class_name KhGeometry
extends RefCounted

static func material(color: Color, roughness: float = 0.8, emission: float = 0.0) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	if emission > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emission
	return m

static func mesh(parent: Node3D, shape: Mesh, pos: Vector3, mat: Material) -> MeshInstance3D:
	var instance = MeshInstance3D.new()
	instance.mesh = shape
	instance.material_override = mat
	instance.position = pos
	parent.add_child(instance)
	return instance

static func box(parent: Node3D, pos: Vector3, size: Vector3, mat: Material, solid: bool = false) -> MeshInstance3D:
	var shape = BoxMesh.new()
	shape.size = size
	var instance = mesh(parent, shape, pos, mat)
	if solid:
		var body = StaticBody3D.new()
		body.position = pos
		parent.add_child(body)
		var collider = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = size
		collider.shape = box_shape
		body.add_child(collider)
	return instance

static func cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, mat: Material, top: float = -1.0, segments: int = 12) -> MeshInstance3D:
	var shape = CylinderMesh.new()
	shape.bottom_radius = radius
	shape.top_radius = radius if top < 0.0 else top
	shape.height = height
	shape.radial_segments = segments
	return mesh(parent, shape, pos, mat)

static func sphere(parent: Node3D, pos: Vector3, radius: float, mat: Material) -> MeshInstance3D:
	var shape = SphereMesh.new()
	shape.radius = radius
	shape.height = radius * 2.0
	shape.radial_segments = 12
	shape.rings = 6
	return mesh(parent, shape, pos, mat)

static func beam(parent: Node3D, a: Vector3, b: Vector3, width: float, mat: Material) -> MeshInstance3D:
	var node = cylinder(parent, (a+b)*0.5, width, a.distance_to(b), mat, width, 8)
	node.quaternion = Quaternion(Vector3.UP, (b-a).normalized())
	return node

static func ring(parent: Node3D, pos: Vector3, radius: float, mat: Material, thickness: float = 0.045) -> MeshInstance3D:
	var shape = TorusMesh.new()
	shape.inner_radius = maxf(0.01, radius-thickness)
	shape.outer_radius = radius+thickness
	shape.rings = 40
	shape.ring_segments = 6
	return mesh(parent, shape, pos, mat)

static func light(parent: Node3D, pos: Vector3, color: Color, energy: float, radius: float) -> OmniLight3D:
	var l = OmniLight3D.new()
	parent.add_child(l)
	l.position = pos
	l.light_color = color
	l.light_energy = energy
	l.omni_range = radius
	return l
