class_name KhTacticalCombat
extends Node

const ACTIONS = {
	"attack": {"name":"Ataque", "reach":2.15, "cost":0, "damage":26},
	"push": {"name":"Empuje", "reach":5.5, "cost":24, "damage":30},
	"lightning": {"name":"Descarga", "reach":11.0, "cost":32, "damage":58},
	"defend": {"name":"Defensa", "reach":0.0, "cost":0, "damage":0}
}
var tactical = true
var player: KhPlayer
var level: Node3D
var enabled = false
var selected: KhEnemy
var engaged = false
var clock = KhRoundQueue.new()
var rng = RandomNumberGenerator.new()
var movement_direction = Vector3.ZERO
var actor_locked = false
var push_cooldown = 0.0
var lightning_cooldown = 0.0
var attack_cooldown: float:
	get: return clock.round_left
var round_left: float:
	get: return clock.round_left
var round_seconds: float:
	get: return clock.round_seconds
var queue: Array:
	get: return clock.pending
var current_action: Dictionary:
	get: return clock.current
var ability_error = ""
var error_time = 0.0
var last_result = "Selecciona al centinela y prepara tus órdenes"
var resolved_actions = 0
var event_log: Array = []
var selection_ring: MeshInstance3D
var approach_time = 0.0
var stalled_time = 0.0
var last_position = Vector3.ZERO

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	rng.seed = 8172
	clock.action_started.connect(_on_started)
	clock.action_impact.connect(_on_impact)
	clock.action_finished.connect(_on_finished)
	selection_ring = KhGeometry.ring(level,Vector3.ZERO,0.75,KhGeometry.material(Color(0.25,0.75,1.0),0.3,1.7),0.035)
	selection_ring.visible = false
	last_position = player.global_position

func action_name(id: String) -> String:
	return ACTIONS.get(id,{"name":"Orden"}).name

func valid_targets() -> Array:
	var targets = []
	for e in level.enemies:
		if is_instance_valid(e) and e.active and e.health > 0: targets.append(e)
	return targets

func target_valid(enemy: Node) -> bool:
	return is_instance_valid(enemy) and enemy is KhEnemy and enemy.active and enemy.health > 0

func nearest_target(reach: float) -> KhEnemy:
	var best: KhEnemy = null
	var distance = reach
	for e in valid_targets():
		var d = player.global_position.distance_to(e.global_position)
		if d < distance and line_of_sight(e):
			best = e
			distance = d
	return best

func line_of_sight(enemy: Node) -> bool:
	if not target_valid(enemy): return false
	var query = PhysicsRayQueryParameters3D.create(player.global_position+Vector3.UP,enemy.global_position+Vector3.UP,1)
	return player.get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func select_target(enemy: Node, engage: bool = true) -> bool:
	if not enabled or not target_valid(enemy): return false
	selected = enemy
	engaged = engage
	approach_time = 0
	stalled_time = 0
	player.rig.combat_stance = engage
	last_result = "Objetivo: %s" % enemy.display_name
	update_selection()
	return true

func select_screen(pos: Vector2) -> bool:
	var camera = player.camera
	var origin = camera.project_ray_origin(pos)
	var query = PhysicsRayQueryParameters3D.create(origin,origin+camera.project_ray_normal(pos)*100,5)
	var hit = player.get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() and hit.collider is KhEnemy: return select_target(hit.collider)
	return false

func cycle_target() -> void:
	var targets = valid_targets()
	if targets.is_empty(): return
	var index = targets.find(selected)
	select_target(targets[(index+1)%targets.size()])

func update_selection() -> void:
	selection_ring.visible = enabled and target_valid(selected)
	if selection_ring.visible:
		selection_ring.global_position = selected.global_position+Vector3(0,0.06,0)

func enqueue_action(id: String, target: Node = null) -> bool:
	if not enabled or player.health <= 0 or not ACTIONS.has(id): return false
	if id != "defend":
		if target == null: target = selected
		if not target_valid(target):
			message("Selecciona un enemigo con clic o TAB")
			return false
	var order = {"id":id,"target":target,"target_name":target.display_name if target_valid(target) else "Tú"}
	if not clock.enqueue(order):
		message("Cola llena · cancela una orden para añadir otra")
		return false
	if id != "defend":
		engaged = true
	player.rig.combat_stance = true
	return true

func basic_attack() -> bool:
	return enqueue_action("attack")

func use_ability(id: int) -> bool:
	return enqueue_action("push" if id == 1 else "lightning")

func cancel_queued(index: int) -> bool:
	return clock.cancel(index)

func clear_queue() -> void:
	clock.clear_pending()

func disengage() -> void:
	engaged = false
	clock.clear_pending()
	clock.interrupt()
	movement_direction = Vector3.ZERO
	actor_locked = false
	player.rig.attack_time = 0
	player.rig.combat_stance = false
	last_result = "Retirada · selecciona un objetivo para volver a combatir"

func manual_override() -> void:
	if engaged or not clock.current.is_empty() or not queue.is_empty(): disengage()

func stop() -> void:
	enabled = false
	engaged = false
	clock.reset()
	movement_direction = Vector3.ZERO
	actor_locked = false
	player.rig.combat_stance = false
	selection_ring.hide()

func message(text: String) -> void:
	ability_error = text
	error_time = 3

func _physics_process(delta: float) -> void:
	push_cooldown = maxf(0,push_cooldown-delta)
	lightning_cooldown = maxf(0,lightning_cooldown-delta)
	error_time = maxf(0,error_time-delta)
	update_selection()
	if not enabled or player.health <= 0:
		movement_direction = Vector3.ZERO
		return
	clock.advance(delta)
	actor_locked = not clock.current.is_empty()
	movement_direction = Vector3.ZERO
	if target_valid(clock.current.get("target")):
		player.face_target(clock.current.target.global_position)
	if not clock.current.is_empty() or clock.round_left > 0: return
	var order: Dictionary = {}
	# Remove impossible orders rather than blocking the queue forever.
	while not queue.is_empty():
		var candidate: Dictionary = queue[0]
		if candidate.id == "defend" or target_valid(candidate.target):
			order = candidate
			break
		queue.pop_front()
		message("Orden descartada: el objetivo ha caído")
	if order.is_empty():
		if not engaged or not target_valid(selected): return
		order = {"id":"attack","target":selected,"target_name":selected.display_name,"automatic":true}
	var data = ACTIONS[order.id]
	if order.id != "defend":
		var d = player.global_position.distance_to(order.target.global_position)
		if d > data.reach or not line_of_sight(order.target):
			approach(delta,order.target)
			return
		player.face_target(order.target.global_position)
	approach_time = 0
	stalled_time = 0
	var cooldown = push_cooldown if order.id == "push" else (lightning_cooldown if order.id == "lightning" else 0.0)
	if cooldown > 0:
		last_result = "Esperando recarga de %s · %.1f s" % [data.name,cooldown]
		return
	if player.energy < data.cost:
		if not queue.is_empty(): queue.pop_front()
		message("%s cancelada: energía insuficiente" % data.name)
		return
	if not queue.is_empty(): queue.pop_front()
	player.energy -= data.cost
	if order.id == "push": push_cooldown = 7
	if order.id == "lightning": lightning_cooldown = 10
	clock.start(order)

func approach(delta: float, target: Node) -> void:
	var direction = target.global_position-player.global_position
	direction.y = 0
	approach_time += delta
	if player.global_position.distance_to(last_position) < 0.006:
		stalled_time += delta
	else: stalled_time = maxf(0,stalled_time-delta*2)
	last_position = player.global_position
	direction = direction.normalized()
	if stalled_time > 0.45:
		var side = Vector3(-direction.z,0,direction.x)
		direction = (direction*0.3+side*0.85).normalized()
	movement_direction = direction
	last_result = "Acercándose a %s" % target.display_name
	if stalled_time > 3.0 or approach_time > 12:
		if not queue.is_empty(): queue.pop_front()
		else: engaged = false
		message("No hay una ruta libre al objetivo · cambia de posición")
		approach_time = 0
		stalled_time = 0
		movement_direction = Vector3.ZERO

func _on_started(order: Dictionary) -> void:
	actor_locked = true
	player.rig.combat_stance = true
	if order.id == "defend":
		player.defending_left = clock.round_seconds*2
		last_result = "Defensa preparada · protección durante dos rondas"
	else:
		player.rig.swing(0.9)
		last_result = "Preparando %s" % action_name(order.id)

func _on_impact(order: Dictionary) -> void:
	if not enabled or player.health <= 0: return
	resolved_actions += 1
	if order.id == "defend":
		level.fx.wave(player.global_position,1.2,Color(0.35,0.70,1.0))
		record({"id":"defend","source":"player","hit":true,"damage":0})
		return
	var target = order.target
	if not target_valid(target):
		last_result = "Sin impacto: el objetivo ha caído"
		return
	var data = ACTIONS[order.id]
	if player.global_position.distance_to(target.global_position) > data.reach+0.12 or not line_of_sight(target):
		last_result = "Sin impacto: objetivo fuera de alcance"
		record({"id":order.id,"source":"player","hit":false,"damage":0,"reason":"range"})
		return
	player.face_target(target.global_position)
	var result = KhCombatRules.hit_result(rng.randi_range(1,20),player.attack_bonus,target.defence)
	var amount = KhCombatRules.scaled_damage(data.damage,result)
	var event = {"id":order.id,"source":"player","hit":result.hit,"critical":result.critical,"damage":amount,"target":target.display_name,"roll":result.roll}
	record(event)
	if not result.hit:
		last_result = "%s: fallo · tirada %d" % [data.name,result.roll]
		level.fx.status_text(target.global_position+Vector3(0,2,0),"FALLO",Color(0.75,0.72,0.67))
		return
	last_result = "%s: %d de daño%s" % [data.name,int(amount)," · CRÍTICO" if result.critical else ""]
	if order.id == "attack":
		level.audio.play_effect("sword")
		target.take_damage(amount)
	elif order.id == "push":
		level.audio.play_effect("push")
		level.fx.wave(player.global_position,5.5,Color(0.28,0.70,1))
		var away = target.global_position-player.global_position
		away.y = 0
		target.take_damage(amount,away.normalized()*6)
		target.stun = maxf(target.stun,1.3)
	else:
		level.audio.play_effect("lightning")
		level.fx.lightning(player.global_position+Vector3(0,1.2,0),target.global_position+Vector3(0,1.2,0))
		target.take_damage(amount)

func _on_finished(_order: Dictionary) -> void:
	actor_locked = false

func record(event: Dictionary) -> void:
	event_log.append(event)
	if event_log.size() > 80: event_log.pop_front()
