extends Node3D
@export var kind = "column"
var stone: Material
var metal: Material

func _ready() -> void:
	if stone == null:
		stone = KhGeometry.material(Color(0.15,0.14,0.16))
	metal = KhGeometry.material(Color(0.35,0.22,0.10),0.4)
	match kind:
		"column": column()
		"statue": statue()
		"brazier": brazier()
		"obelisk": obelisk()

func column() -> void:
	KhGeometry.box(self,Vector3(0,0.3,0),Vector3(1.7,0.6,1.7),stone,true)
	KhGeometry.box(self,Vector3(0,0.72,0),Vector3(1.35,0.25,1.35),metal)
	KhGeometry.box(self,Vector3(0,3.4,0),Vector3(0.9,5.3,0.9),stone,true)
	for side in [-1,1]:
		KhGeometry.box(self,Vector3(side*0.44,3.4,-0.03),Vector3(0.15,4.8,0.86),metal)
	KhGeometry.box(self,Vector3(0,6.13,0),Vector3(1.55,0.35,1.55),stone)
	KhGeometry.cylinder(self,Vector3(0,6.6,0),0.76,0.65,stone,0.15,4).rotation.y = PI/4

func statue() -> void:
	KhGeometry.box(self,Vector3(0,0.45,0),Vector3(3.7,0.9,3.1),stone,true)
	KhGeometry.box(self,Vector3(0,1.0,0),Vector3(3.1,0.25,2.65),metal)
	KhGeometry.cylinder(self,Vector3(0,3.1,0),1.25,3.9,stone,0.70,5)
	KhGeometry.box(self,Vector3(0,5.0,0),Vector3(2.05,2.4,1.35),stone)
	KhGeometry.sphere(self,Vector3(0,6.8,0.09),0.77,stone).scale = Vector3(0.9,1.35,0.92)
	KhGeometry.box(self,Vector3(0,6.8,-0.60),Vector3(0.74,0.78,0.1),KhGeometry.material(Color(0.025,0.015,0.022)))
	var glow = KhGeometry.material(Color(0.95,0.20,0.06),0.3,3)
	KhGeometry.box(self,Vector3(0,6.94,-0.67),Vector3(0.40,0.045,0.06),glow)
	for side in [-1,1]:
		KhGeometry.box(self,Vector3(side*1.30,4.8,-0.16),Vector3(0.75,2.3,0.75),stone).rotation.z = side*0.22
		KhGeometry.sphere(self,Vector3(side*1.52,3.80,-0.4),0.37,stone)
	KhGeometry.box(self,Vector3(0,3.45,-1.05),Vector3(0.23,4.65,0.28),metal)
	KhGeometry.box(self,Vector3(0,5.1,-1.05),Vector3(1.3,0.2,0.25),metal)
	KhGeometry.light(self,Vector3(0,5,-1.3),Color(1,0.22,0.06),1.6,6)

func obelisk() -> void:
	KhGeometry.box(self,Vector3(0,0.35,0),Vector3(1.8,0.7,1.8),stone,true)
	KhGeometry.cylinder(self,Vector3(0,2.85,0),0.76,4.6,stone,0.55,4).rotation.y = PI/4
	KhGeometry.cylinder(self,Vector3(0,5.6,0),0.55,0.95,metal,0,4).rotation.y = PI/4
	for i in range(5):
		KhGeometry.box(self,Vector3(0,1.7+i*0.5,-0.53),Vector3(0.30 if i%2 else 0.14,0.09,0.02),KhGeometry.material(Color(0.76,0.14,0.05),0.6,1.1))

func brazier() -> void:
	KhGeometry.box(self,Vector3(0,0.2,0),Vector3(1.2,0.4,1.2),stone,true)
	KhGeometry.cylinder(self,Vector3(0,0.95,0),0.30,1.3,metal,0.19)
	KhGeometry.cylinder(self,Vector3(0,1.65,0),0.25,0.40,metal,0.75)
	KhGeometry.cylinder(self,Vector3(0,1.90,0),0.53,0.15,KhGeometry.material(Color(1,0.25,0.025),0.5,3),0.50)
	var particles = GPUParticles3D.new()
	add_child(particles)
	particles.position.y = 2.0
	particles.amount = 22
	particles.lifetime = 0.9
	particles.visibility_aabb = AABB(Vector3(-1,-1,-1),Vector3(2,4,2))
	var pm = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = 0.34
	pm.direction = Vector3.UP
	pm.spread = 20
	pm.initial_velocity_min = 0.8
	pm.initial_velocity_max = 1.5
	pm.gravity = Vector3(0,0.6,0)
	pm.scale_min = 0.09
	pm.scale_max = 0.20
	pm.color = Color(1,0.35,0.02)
	particles.process_material = pm
	var flame = SphereMesh.new()
	flame.radius = 0.15
	flame.height = 0.3
	flame.material = KhGeometry.material(Color(1,0.27,0.015),0.5,5)
	particles.draw_pass_1 = flame
	KhGeometry.light(self,Vector3(0,2.4,0),Color(1,0.28,0.05),3.0,8)
