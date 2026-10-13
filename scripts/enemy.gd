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
var tactical_mode = false
var defence = 12
var attack_bonus = 5
var round_clock = KhRoundQueue.new()
var phrase_index = 0
const NEUTRAL_LINES = ["Escoge bien tus palabras. El umbral no admite imprudencias.", "Mi maestro no tendrá piedad de quien desafíe su voluntad.", "Ten cuidado con lo que buscas. El poder siempre exige un precio."]

func next_phrase() -> String:
	var phrase: String = NEUTRAL_LINES[phrase_index]
	phrase_index = (phrase_index+1)%NEUTRAL_LINES.size()
	return phrase

func _ready() -> void:
	if guardian:
		max_health = 520 if tactical_mode else 1800
		health = max_health
		display_name = "Guardián de Kharuun"
	floor_snap_length = 0.7
	if tactical_mode:
		round_clock.round_seconds = 3.0 if guardian else 3.8
		round_clock.action_started.connect(_tactical_started)
		round_clock.action_impact.connect(_tactical_impact)
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
	rig.combat_stance = true

func _physics_process(delta: float) -> void:
	if tactical_mode:
		_tactical_physics(delta)
		return
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

func _tactical_physics(delta: float) -> void:
	if not is_on_floor(): velocity.y -= 22*delta
	else: velocity.y = -0.5
	var desired = Vector3.ZERO
	stun = maxf(0,stun-delta)
	if active and mode != Mode.DEAD and is_instance_valid(target) and target.health > 0:
		var direction = target.global_position-global_position
		direction.y = 0
		rig.rotation.y = atan2(-direction.x,-direction.z)
		if stun > 0 and not round_clock.current.is_empty() and not round_clock.impact_done:
			round_clock.interrupt()
			rig.attack_time = 0
			telegraph.hide()
		# Stagger cancels a pending hit; recovery keeps ticking with the animation.
		round_clock.advance(delta)
		if stun <= 0 and active and target.health > 0:
			if round_clock.round_left > 0:
				mode = Mode.RECOVER if round_clock.impact_done else Mode.WINDUP
			else:
				mode = Mode.CHASE
				if direction.length() > (2.0 if guardian else 1.8) or not _tactical_visible():
					desired = direction.normalized()*2.4
					for other in level.enemies:
						if other != self and other.health > 0:
							var separation = global_position-other.global_position
							separation.y = 0
							if separation.length() > 0.01 and separation.length() < 1.1: desired += separation.normalized()*1.3
				else:
					round_clock.start({"id":"attack","target":target,"target_name":"Intruso"})
	knockback = knockback.move_toward(Vector3.ZERO,delta*12)
	velocity.x = desired.x+knockback.x
	velocity.z = desired.z+knockback.z
	if desired.length() > 0.1 and test_move(global_transform,desired*delta):
		var tangent = Vector3(-desired.z,0,desired.x)
		if test_move(global_transform,tangent*delta): tangent = -tangent
		velocity.x = tangent.x+knockback.x
		velocity.z = tangent.z+knockback.z
	move_and_slide()
	rig.animate(delta,desired.length())

func _tactical_visible() -> bool:
	var query = PhysicsRayQueryParameters3D.create(global_position+Vector3.UP,target.global_position+Vector3.UP,1)
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func _tactical_started(_order: Dictionary) -> void:
	mode = Mode.WINDUP
	rig.swing(0.9)
	telegraph.visible = true

func _tactical_impact(_order: Dictionary) -> void:
	telegraph.visible = false
	attacks += 1
	if not active or target.health <= 0: return
	var distance = global_position.distance_to(target.global_position)
	var combat = level.combat
	if distance > 2.35 or not _tactical_visible():
		combat.record({"source":"enemy","id":"attack","hit":false,"damage":0,"reason":"range"})
		return
	var effective_defence = target.defence
	var result = KhCombatRules.hit_result(combat.rng.randi_range(1,20),attack_bonus,effective_defence)
	var damage = KhCombatRules.scaled_damage(18 if guardian else 11,result)
	var before = target.health
	if result.hit:
		target.take_damage(damage)
		level.fx.burst(target.global_position+Vector3.UP,Color(1,0.25,0.12),7)
		level.audio.play_effect("enemy")
	else:
		level.fx.status_text(target.global_position+Vector3(0,2,0),"FALLO",Color(0.75,0.72,0.67))
	combat.record({"source":"enemy","id":"attack","hit":result.hit,"damage":before-target.health,"roll":result.roll})

func stop_tactical() -> void:
	round_clock.reset()
	telegraph.hide()
	active = false

func take_damage(amount: float, force: Vector3 = Vector3.ZERO) -> void:
	if mode == Mode.DEAD or not active:
		return
	health = maxf(0,health-amount)
	bar.scale.x = maxf(0.001,health/max_health)
	rig.hit()
	knockback = force
	stun = (1.3 if force.length() > 0.1 else 0.0) if tactical_mode else (0.22 if guardian else 0.44)
	if tactical_mode and stun > 0:
		round_clock.interrupt()
		rig.attack_time = 0
		telegraph.hide()
	if mode == Mode.WINDUP and not guardian and not tactical_mode:
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
		collision_mask = 1
		round_clock.reset()
		died.emit(self)
