class_name KhTacticalCombat
extends Node

# Initial balance values; rounds and costs are independent of any power cooldown.
const ACTIONS = {
	"attack": {"name":"Básico", "reach":2.15, "cost":0, "damage":26},
	"flurry": {"name":"Ráfaga", "reach":2.15, "cost":0, "damage":17},
	"push": {"name":"Empuje", "reach":5.5, "cost":24, "damage":30},
	"lightning": {"name":"Descarga", "reach":11.0, "cost":32, "damage":58},
	"heal": {"name":"Curación", "reach":0.0, "cost":28, "heal":68, "self":true},
	"medkit": {"name":"Botiquín", "reach":0.0, "cost":0, "heal":95, "self":true}
}
const INITIAL_MEDKITS = 3
var tactical = true
var player: KhPlayer
var level: Node3D
var enabled = false
var selected: KhEnemy
var last_offensive_target: KhEnemy
var medkits = INITIAL_MEDKITS
var engaged = false
var clock = KhRoundQueue.new()
var rng = RandomNumberGenerator.new()
var movement_direction = Vector3.ZERO
var actor_locked = false
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
var last_result = "Selecciona un agresor y prepara tus órdenes"
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

func is_self_action(id: String) -> bool:
	return bool(ACTIONS.get(id,{}).get("self",false))

func valid_targets() -> Array:
	var targets = []
	for enemy in level.enemies:
		if target_valid(enemy): targets.append(enemy)
	return targets

func target_valid(enemy: Node) -> bool:
	return is_instance_valid(enemy) and enemy is KhEnemy and enemy.active and enemy.health > 0

func selection_valid(enemy: Node) -> bool:
	return is_instance_valid(enemy) and enemy is KhEnemy and enemy.health > 0

func nearest_target(reach: float = 100.0) -> KhEnemy:
	var best: KhEnemy = null
	var distance = reach
	for enemy in valid_targets():
		var d = player.global_position.distance_to(enemy.global_position)
		if d < distance and target_reachable(enemy):
			best = enemy
			distance = d
	return best

func line_of_sight(enemy: Node) -> bool:
	if not target_valid(enemy): return false
	var query = PhysicsRayQueryParameters3D.create(player.global_position+Vector3.UP,enemy.global_position+Vector3.UP,1)
	return player.get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func target_reachable(enemy: Node) -> bool:
	if not line_of_sight(enemy): return false
	# Conservative corridor check against static scenery only. Actor collisions are
	# handled by movement; another acolyte cannot hide every valid fallback target.
	var corridor = CapsuleShape3D.new()
	corridor.radius = 0.29
	corridor.height = 1.5
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = corridor
	query.transform = Transform3D(Basis.IDENTITY,player.global_position+Vector3(0,0.95,0))
	query.motion = enemy.global_position-player.global_position
	query.collision_mask = 1
	query.exclude = [player.get_rid(),enemy.get_rid()]
	var fractions = player.get_world_3d().direct_space_state.cast_motion(query)
	return fractions.is_empty() or fractions[0] >= 0.995

func select_target(enemy: Node, engage: bool = true) -> bool:
	if not enabled or not target_valid(enemy): return false
	selected = enemy
	if engage: engaged = true
	approach_time = 0
	stalled_time = 0
	player.rig.combat_stance = engaged
	last_result = "Selección: %s" % enemy.display_name
	update_selection()
	return true

func select_screen(pos: Vector2) -> bool:
	var enemy = screen_actor(pos)
	if not enabled or not selection_valid(enemy): return false
	if enemy == selected:
		if target_valid(enemy): return enqueue_action("attack",enemy)
		return level.request_talk(enemy)
	if target_valid(enemy): return select_target(enemy)
	selected = enemy
	update_selection()
	return true

func screen_actor(pos: Vector2) -> KhEnemy:
	var camera = player.camera
	var origin = camera.project_ray_origin(pos)
	var query = PhysicsRayQueryParameters3D.create(origin,origin+camera.project_ray_normal(pos)*100,5)
	var hit = player.get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() and selection_valid(hit.collider): return hit.collider
	return null

func cycle_target() -> void:
	var targets = valid_targets()
	if targets.is_empty(): return
	var index = targets.find(selected)
	select_target(targets[(index+1)%targets.size()])

func update_selection() -> void:
	selection_ring.visible = enabled and selection_valid(selected)
	if selection_ring.visible:
		selection_ring.global_position = selected.global_position+Vector3(0,0.06,0)

func enqueue_action(id: String, target: Node = null) -> bool:
	if not enabled or player.health <= 0 or not ACTIONS.has(id): return false
	if player.energy < ACTIONS[id].cost:
		message("Énergía insuficiente para %s" % action_name(id))
		return false
	if is_self_action(id):
		target = player
		if id == "medkit" and medkits <= 0:
			message("No quedan botiquines")
			return false
	else:
		if target == null: target = selected
		if not target_valid(target):
			message("Selecciona un agresor con clic o TAB")
			return false
	var order = {"id":id,"target":target,"target_name":"Sobre ti" if is_self_action(id) else target.display_name}
	if id == "flurry": order["impact_times"] = [0.42,0.90]
	if not clock.enqueue(order):
		message("Cola llena · cancela una orden para añadir otra")
		return false
	if not is_self_action(id): engaged = true
	player.rig.combat_stance = engaged
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
	last_offensive_target = null
	clear_queue()
	clock.interrupt()
	movement_direction = Vector3.ZERO
	actor_locked = false
	player.rig.cancel_action()
	player.rig.combat_stance = false
	last_result = "Retirada · selecciona un agresor para volver a combatir"

func manual_override() -> void:
	# D04: only F/Cancel releases automatic combat; WASD never changes orders.
	pass

func stop() -> void:
	enabled = false
	engaged = false
	clock.reset()
	selected = null
	last_offensive_target = null
	movement_direction = Vector3.ZERO
	actor_locked = false
	player.rig.cancel_action()
	player.rig.combat_stance = false
	selection_ring.hide()

func message(text: String) -> void:
	ability_error = text
	error_time = 3

func _physics_process(delta: float) -> void:
	error_time = maxf(0,error_time-delta)
	update_selection()
	movement_direction = Vector3.ZERO
	if not enabled or player.health <= 0: return
	clock.advance(delta)
	# An impact may end the encounter and open a narrative pause.
	if not enabled: return
	actor_locked = not clock.current.is_empty()
	if target_valid(clock.current.get("target")):
		player.face_target(clock.current.target.global_position)
	elif target_valid(last_offensive_target) and engaged:
		player.face_target(last_offensive_target.global_position)
	if not clock.current.is_empty() or clock.round_left > 0: return
	var order: Dictionary = {}
	var resource_failed = false
	while not queue.is_empty():
		var candidate: Dictionary = queue[0]
		if ACTIONS.has(candidate.id) and (is_self_action(candidate.id) or target_valid(candidate.get("target"))):
			if (candidate.id == "medkit" and medkits <= 0) or player.energy < ACTIONS[candidate.id].cost:
				resource_failed = true
				var medkit_failure: bool = candidate.id == "medkit"
				for index in range(queue.size()-1,-1,-1):
					var same_resource: bool = queue[index].id == "medkit" if medkit_failure else ACTIONS.get(queue[index].id,{}).get("cost",0) > 0
					if same_resource:
						queue.remove_at(index)
				message("Botiquines agotados: órdenes retiradas" if medkit_failure else "Sin energía: poderes pendientes retirados")
				record({"source":"resource","id":candidate.id,"reason":"insufficient_resource"})
				continue
			order = candidate
			break
		queue.pop_front()
		message("Orden descartada: el destinatario ya no es un agresor vivo")
	if order.is_empty():
		if resource_failed:
			clock.round_left = clock.round_seconds
			last_result = "Acción perdida por falta de recursos · recuperando"
			return
		if not engaged: return
		var recipient: KhEnemy = last_offensive_target
		if not target_valid(recipient):
			if last_offensive_target == null and target_valid(selected) and target_reachable(selected):
				recipient = selected
			else:
				recipient = nearest_target()
			if recipient == null:
				engaged = false
				player.rig.combat_stance = false
				last_result = "Sin agresores visibles y alcanzables"
				return
			if not target_valid(selected):
				selected = recipient
				update_selection()
		order = {"id":"attack","target":recipient,"target_name":recipient.display_name,"automatic":true}
	var data = ACTIONS[order.id]
	if not is_self_action(order.id):
		var d = player.global_position.distance_to(order.target.global_position)
		if d > data.reach or not line_of_sight(order.target):
			if order.get("automatic",false):
				last_result = "Esperando a %s · fuera de alcance cuerpo a cuerpo" % order.target_name
				return
			approach(delta,order.target)
			return
		player.face_target(order.target.global_position)
	approach_time = 0
	stalled_time = 0
	if not queue.is_empty(): queue.pop_front()
	player.energy -= data.cost
	if order.id == "medkit": medkits -= 1
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
	player.face_target(target.global_position)
	last_result = "Acercándose a %s" % target.display_name
	if stalled_time > 3.0 or approach_time > 12:
		if not queue.is_empty(): queue.pop_front()
		else: engaged = false
		message("No hay una ruta libre al objetivo · cancela y cambia de posición")
		approach_time = 0
		stalled_time = 0
		movement_direction = Vector3.ZERO

func _on_started(order: Dictionary) -> void:
	actor_locked = true
	player.rig.combat_stance = engaged
	if not is_self_action(order.id) and target_valid(order.target):
		last_offensive_target = order.target
	if order.id == "attack": player.rig.swing(0.9)
	elif order.id == "flurry": player.rig.swing_flurry()
	else: player.rig.cast(order.id)
	last_result = "Preparando %s · %s" % [action_name(order.id),order.target_name]

func _on_impact(order: Dictionary) -> void:
	if not enabled or player.health <= 0: return
	if int(order.get("impact_index",0)) == 0: resolved_actions += 1
	var data = ACTIONS[order.id]
	if is_self_action(order.id):
		var before = player.health
		player.health = minf(player.max_health,player.health+data.heal)
		var restored = player.health-before
		player.health_changed.emit()
		level.fx.heal(player.global_position)
		level.fx.status_text(player.global_position+Vector3(0,2,0),"+%d" % int(restored),Color(0.3,1.0,0.55))
		last_result = "%s: +%d salud" % [data.name,int(restored)]
		record({"id":order.id,"source":"player","target":"Sobre ti","hit":true,"damage":0,"healing":restored,"resource_consumed":true})
		return
	var target = order.target
	if not target_valid(target):
		last_result = "Sin impacto: el destinatario ya no es un agresor vivo"
		record_impact(order,{"hit":false,"damage":0,"reason":"invalid_target"})
		return
	if player.global_position.distance_to(target.global_position) > data.reach+0.12 or not line_of_sight(target):
		last_result = "Sin impacto: destinatario fuera de alcance"
		record_impact(order,{"hit":false,"damage":0,"reason":"range"})
		return
	player.face_target(target.global_position)
	var result = KhCombatRules.hit_result(rng.randi_range(1,20),player.attack_bonus,target.defence)
	var amount = KhCombatRules.scaled_damage(data.damage,result)
	record_impact(order,{"hit":result.hit,"critical":result.critical,"damage":amount,"roll":result.roll})
	# Casting is visible even if the hit roll fails; damage still obeys that roll.
	if order.id == "push":
		level.audio.play_effect("push")
		level.fx.push_wave(player.rig.palm_world_position(),target.global_position+Vector3(0,1.2,0))
	elif order.id == "lightning":
		level.audio.play_effect("lightning")
		level.fx.lightning(player.rig.palm_world_position(),target.global_position+Vector3(0,1.2,0))
	else: level.audio.play_effect("sword")
	if not result.hit:
		last_result = "%s: fallo · tirada %d" % [data.name,result.roll]
		level.fx.status_text(target.global_position+Vector3(0,2,0),"FALLO",Color(0.75,0.72,0.67))
		return
	last_result = "%s: %d de daño%s" % [data.name,int(amount)," · CRÍTICO" if result.critical else ""]
	if order.id == "push":
		var away = target.global_position-player.global_position
		away.y = 0
		target.take_damage(amount,away.normalized()*6)
		target.stun = maxf(target.stun,1.3)
	else: target.take_damage(amount)

func record_impact(order: Dictionary, result: Dictionary) -> void:
	var event = {"id":order.id,"source":"player","target":order.target_name,"impact_index":int(order.get("impact_index",0)),"automatic":bool(order.get("automatic",false))}
	if is_instance_valid(order.target): event["target_instance_id"] = order.target.get_instance_id()
	event.merge(result)
	record(event)

func _on_finished(_order: Dictionary) -> void:
	actor_locked = false

func record(event: Dictionary) -> void:
	event_log.append(event)
	if event_log.size() > 160: event_log.pop_front()
