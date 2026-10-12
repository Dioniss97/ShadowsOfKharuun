class_name KhCombat
extends Node
var player: KhPlayer
var level: Node3D
var attack_cooldown = 0.0
var push_cooldown = 0.0
var lightning_cooldown = 0.0
var selected: KhEnemy
var enabled = false
var tactical = false
var ability_error = ""
var error_time = 0.0
var pending_strikes: Array = []

func _process(delta: float) -> void:
	attack_cooldown = maxf(0,attack_cooldown-delta)
	push_cooldown = maxf(0,push_cooldown-delta)
	lightning_cooldown = maxf(0,lightning_cooldown-delta)
	error_time = maxf(0,error_time-delta)
	selected = nearest_target(13)

func _physics_process(delta: float) -> void:
	for i in range(pending_strikes.size()-1,-1,-1):
		var strike = pending_strikes[i]
		strike.time -= delta
		if strike.time > 0: continue
		pending_strikes.remove_at(i)
		var enemy = strike.target
		if enabled and player.health > 0 and is_instance_valid(enemy) and enemy.active and enemy.health > 0 and player.global_position.distance_to(enemy.global_position) <= 2.8 and line_of_sight(enemy):
			player.face_target(enemy.global_position)
			enemy.take_damage(20)

func valid_targets() -> Array:
	var list = []
	for e in level.enemies:
		if e.active and e.health > 0:
			list.append(e)
	return list

func nearest_target(reach: float) -> KhEnemy:
	var best: KhEnemy = null
	var closest = reach
	for e in valid_targets():
		var d = player.global_position.distance_to(e.global_position)
		if d < closest and line_of_sight(e):
			closest = d
			best = e
	return best

func line_of_sight(enemy: KhEnemy) -> bool:
	var query = PhysicsRayQueryParameters3D.create(player.global_position+Vector3(0,1.0,0),enemy.global_position+Vector3(0,1.0,0),1)
	var result = player.get_world_3d().direct_space_state.intersect_ray(query)
	return result.is_empty()

func basic_attack() -> bool:
	if not enabled or player.health <= 0 or attack_cooldown > 0: return false
	attack_cooldown = 0.80
	player.rig.swing()
	level.audio.play_effect("sword")
	var closest = nearest_target(2.8)
	if closest != null:
		player.face_target(closest.global_position)
		pending_strikes.append({"target":closest,"time":0.42})
	else:
		level.fx.burst(player.global_position+player.forward()*1.25+Vector3.UP,Color(0.25,0.8,1),3)
	return true

func use_ability(id: int) -> bool:
	if not enabled or player.health <= 0: return false
	var cost = 24 if id == 1 else 32
	var cd = push_cooldown if id == 1 else lightning_cooldown
	if cd > 0:
		ability_error = "La habilidad aún se está recargando"
		error_time = 1.7
		return false
	if player.energy < cost:
		ability_error = "No tienes energía suficiente"
		error_time = 1.7
		return false
	if id == 2 and nearest_target(11) == null:
		ability_error = "Acércate a un enemigo · alcance 11 m"
		error_time = 1.7
		return false
	player.energy -= cost
	player.rig.swing()
	if id == 1:
		push_cooldown = 7
		level.audio.play_effect("push")
		level.fx.wave(player.global_position,5.5,Color(0.28,0.70,1))
		for e in valid_targets():
			if player.global_position.distance_to(e.global_position) < 5.5 and line_of_sight(e):
				var away = (e.global_position-player.global_position).normalized()
				e.take_damage(30,away*(4.5 if e.guardian else 9))
	else:
		lightning_cooldown = 10
		var enemy = nearest_target(11)
		player.face_target(enemy.global_position)
		level.audio.play_effect("lightning")
		level.fx.lightning(player.global_position+Vector3(0,1.2,0),enemy.global_position+Vector3(0,1.2,0))
		enemy.take_damage(64)
	return true
