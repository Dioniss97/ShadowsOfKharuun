class_name KhEnemy
extends CharacterBody3D

signal died(enemy: KhEnemy)
enum Mode { WAIT, CHASE, WINDUP, RECOVER, DEAD }
var guardian = false
var display_name = "Acólito Sith"
var max_health = 300.0
var health = 300.0
var active = false
var target: KhPlayer
var rig: KhRig
var mode = Mode.WAIT
var timer = 0.0
var stun = 0.0
var knockback = Vector3.ZERO
var telegraph: MeshInstance3D
var bar: MeshInstance3D
var slam = false
var attacks = 0
var level: Node3D

func _ready() -> void:
	if guardian:
		max_health = 1800
		health = max_health
		display_name = "Guardián de Kharuun"
	floor_snap_length = 0.7
	var c = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.radius = 0.36 if not guardian else 0.46
	shape.height = 1.8 if not guardian else 2.3
	c.shape = shape
	c.position.y = shape.height/2
	add_child(c)
	rig = KhRig.new()
	add_child(rig)
	rig.build(Color(0.24,0.025,0.045) if guardian else Color(0.14,0.045,0.07),Color(1,0.065,0.08),guardian)
	telegraph = KhGeometry.ring(self,Vector3(0,0.05,0),1.65,KhGeometry.material(Color(1,0.12,0.04),0.3,2),0.055)
	telegraph.visible = false
	var hp_node = Node3D.new()
	add_child(hp_node)
	hp_node.position.y = 2.5 if not guardian else 3.15
	var quad = QuadMesh.new()
	quad.size = Vector2(0.94,0.075)
	var bg = KhGeometry.mesh(hp_node,quad,Vector3.ZERO,KhGeometry.material(Color(0.035,0.018,0.025)))
	bg.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bg.material_override.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	bg.material_override.no_depth_test = true
	bg.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var fill = QuadMesh.new()
	fill.size = Vector2(0.90,0.042)
	bar = KhGeometry.mesh(hp_node,fill,Vector3.ZERO,KhGeometry.material(Color(0.8,0.11,0.10),0.8,0.6))
	bar.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bar.material_override.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	bar.material_override.no_depth_test = true
	bar.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bar.material_override.render_priority = 1
	hp_node.visible = false
	bar.set_meta("holder",hp_node)

func activate() -> void:
	if mode == Mode.DEAD:
		return
	active = true
	mode = Mode.CHASE
	bar.get_meta("holder").visible = true

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 22*delta
	else:
		velocity.y = -0.5
	var desired = Vector3.ZERO
	if active and is_instance_valid(target) and target.health > 0 and mode != Mode.DEAD:
		var to_player = target.global_position-global_position
		to_player.y = 0
		var distance = to_player.length()
		rig.rotation.y = lerp_angle(rig.rotation.y,atan2(-to_player.x,-to_player.z),delta*8)
		stun = maxf(0,stun-delta)
		if stun <= 0:
			match mode:
				Mode.CHASE:
					if distance > (2.0 if guardian else 1.65):
						desired = to_player.normalized()*(2.8 if guardian else 2.55)
						# Separation preserves readable silhouettes and avoids stacked attackers.
						for other in level.enemies:
							if other != self and other.mode != Mode.DEAD:
								var separation = global_position-other.global_position
								separation.y = 0
								if separation.length() < 1.1 and separation.length() > 0.01:
									desired += separation.normalized()*1.8
					else:
						mode = Mode.WINDUP
						slam = guardian and attacks%3 == 2
						timer = 1.15 if slam else (0.72 if guardian else 0.62)
						telegraph.scale = Vector3.ONE*(2.7 if slam else 1.0)
						telegraph.visible = true
				Mode.WINDUP:
					timer -= delta
					telegraph.rotation.y += delta*2
					if timer <= 0:
						rig.swing()
						telegraph.visible = false
						attacks += 1
						var reach = 4.5 if slam else (2.65 if guardian else 2.25)
						if distance <= reach and absf(target.global_position.y-global_position.y) < 2.0:
							target.take_damage(30 if slam else (21 if guardian else 10))
							level.fx.burst(target.global_position+Vector3.UP,Color(1,0.25,0.12),9)
						if slam:
							level.fx.wave(global_position,4.5,Color(1,0.10,0.03))
							level.audio.play_effect("slam")
						else:
							level.audio.play_effect("enemy")
						mode = Mode.RECOVER
						timer = 1.0 if guardian else 1.25
				Mode.RECOVER:
					timer -= delta
					if timer <= 0:
						mode = Mode.CHASE
	knockback = knockback.move_toward(Vector3.ZERO,delta*12)
	velocity.x = desired.x+knockback.x
	velocity.z = desired.z+knockback.z
	if desired.length() > 0.1 and test_move(global_transform,desired*delta):
		var tangent = Vector3(-desired.z,0,desired.x)
		if test_move(global_transform,tangent*delta):
			tangent = -tangent
		velocity.x = tangent.x+knockback.x
		velocity.z = tangent.z+knockback.z
	move_and_slide()
	if mode == Mode.DEAD:
		velocity.x = 0
		velocity.z = 0
	rig.animate(delta,desired.length())

func take_damage(amount: float, force: Vector3 = Vector3.ZERO) -> void:
	if mode == Mode.DEAD or not active:
		return
	health = maxf(0,health-amount)
	bar.scale.x = maxf(0.001,health/max_health)
	rig.hit()
	knockback = force
	stun = 0.22 if guardian else 0.44
	if mode == Mode.WINDUP and not guardian:
		mode = Mode.RECOVER
		timer = 0.6
		telegraph.visible = false
	level.fx.burst(global_position+Vector3(0,1.1,0),Color(1,0.35,0.17),7)
	level.fx.damage_number(global_position+Vector3(0,2,0),int(amount))
	if health <= 0:
		mode = Mode.DEAD
		active = false
		telegraph.visible = false
		bar.get_meta("holder").visible = false
		rig.dying = true
		collision_layer = 0
		died.emit(self)
