class_name KhPlayer
extends CharacterBody3D

signal health_changed
signal died
const TURN_SPEED = 2.2
const CAMERA_RECENTER_SPEED = 8.0
var max_health = 340.0
var health = 340.0
var max_energy = 100.0
var energy = 100.0
var control_enabled = false
var yaw = 0.0
var pitch = -0.20
var camera_pivot: Node3D
var camera: Camera3D
var rig: KhRig
var combat: Node
var invulnerable = 0.0
var automation_direction = Vector3.ZERO
var automation_mode = false
var distance_walked = 0.0
var attack_bonus = 8
var defence = 14
var camera_follow_motion = false
var interaction_target: KhEnemy

func _ready() -> void:
	floor_snap_length = 0.7
	floor_max_angle = deg_to_rad(48)
	var collision = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.8
	collision.shape = capsule
	collision.position.y = 0.91
	add_child(collision)
	rig = KhRig.new()
	add_child(rig)
	rig.build(Color(0.065,0.105,0.15),Color(0.25,0.80,1.0))
	camera_pivot = Node3D.new()
	get_parent().add_child(camera_pivot)
	var arm = SpringArm3D.new()
	camera_pivot.add_child(arm)
	arm.spring_length = 5.8
	arm.margin = 0.22
	arm.collision_mask = 1
	arm.add_excluded_object(get_rid())
	camera = Camera3D.new()
	arm.add_child(camera)
	camera.fov = 68
	camera.position.z = arm.spring_length
	camera.near = 0.12
	camera.current = true
	camera_pivot.global_position = global_position+Vector3(0,1.7,0)
	camera_pivot.rotation = Vector3(pitch,yaw,0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo: return
	if not control_enabled:
		return
	if event is InputEventMouseMotion: camera_input(event)

func camera_input(event: InputEventMouseMotion) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= event.relative.x*0.0026
		pitch = clampf(pitch-event.relative.y*0.0023,-0.7,0.30)

func orbit_camera(delta: float) -> void:
	if control_enabled:
		yaw -= Input.get_axis("move_left","move_right")*TURN_SPEED*delta

func _physics_process(delta: float) -> void:
	invulnerable = maxf(0,invulnerable-delta)
	rig.guarding = false
	var tactical = is_instance_valid(combat) and combat.tactical
	energy = minf(max_energy,energy+delta*(3.0 if tactical else 10.0))
	var direction = Vector3.ZERO
	var running = false
	var combat_controls_movement = tactical and (combat.engaged or combat.actor_locked or not combat.queue.is_empty())
	orbit_camera(delta)
	if Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_back"):
		interaction_target = null
	if automation_mode:
		direction = automation_direction
		running = control_enabled and Input.is_action_pressed("sprint")
	elif combat_controls_movement:
		direction = combat.movement_direction
	elif is_instance_valid(interaction_target) and interaction_target.health > 0:
		direction = interaction_target.global_position-global_position
		direction.y = 0
		direction = direction.normalized()
	elif control_enabled:
		var advance = Input.get_axis("move_forward","move_back")
		# W follows the camera heading; S backs up without turning the actor.
		if advance < 0: rig.rotation.y = yaw
		direction = Vector3(sin(rig.rotation.y),0,cos(rig.rotation.y))*advance
		running = Input.is_action_pressed("sprint")
	var speed = 6.6 if running else 3.6
	velocity.x = move_toward(velocity.x,direction.x*speed,delta*22)
	velocity.z = move_toward(velocity.z,direction.z*speed,delta*22)
	if tactical and combat.actor_locked and not automation_mode:
		velocity.x = 0
		velocity.z = 0
	if not is_on_floor():
		velocity.y -= 22*delta
	else:
		velocity.y = -0.5
	var before = global_position
	move_and_slide()
	var planar_distance = Vector2(global_position.x-before.x,global_position.z-before.z).length()
	distance_walked += planar_distance
	camera_follow_motion = planar_distance > 0.001
	if global_position.y < -5:
		global_position = Vector3(0,1,8)
		velocity = Vector3.ZERO
		camera_follow_motion = false
	var flat_speed = Vector2(velocity.x,velocity.z).length()
	if (automation_mode or combat_controls_movement or is_instance_valid(interaction_target)) and direction.length() > 0.1 and (not tactical or not combat.actor_locked) and rig.attack_time <= 0:
		rig.rotation.y = lerp_angle(rig.rotation.y,atan2(-direction.x,-direction.z),delta*12)
	rig.animate(delta,flat_speed)
	update_camera(delta)

func update_camera(delta: float) -> void:
	# Releasing RMB keeps the orbit while still or paused; only actual movement recenters.
	if camera_follow_motion and not get_tree().paused and not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw = lerp_angle(yaw, rig.rotation.y, 1.0-exp(-delta*CAMERA_RECENTER_SPEED))
	camera_pivot.global_position = camera_pivot.global_position.lerp(global_position+Vector3(0,1.65,0),1.0-exp(-delta*14))
	camera_pivot.rotation.x = lerp_angle(camera_pivot.rotation.x,pitch,1.0-exp(-delta*18))
	camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y,yaw,1.0-exp(-delta*18))

func take_damage(amount: float) -> void:
	if health <= 0 or invulnerable > 0:
		return
	health = maxf(0,health-amount)
	invulnerable = 0.0 if is_instance_valid(combat) and combat.tactical else 0.32
	rig.hit()
	health_changed.emit()
	if health <= 0:
		control_enabled = false
		rig.dying = true
		died.emit()

func face_target(target: Vector3) -> void:
	var dir = target-global_position
	rig.rotation.y = atan2(-dir.x,-dir.z)

func forward() -> Vector3:
	return -rig.global_basis.z.normalized()

func snap_camera() -> void:
	camera_pivot.global_position = global_position+Vector3(0,1.65,0)
	camera_pivot.rotation = Vector3(pitch,yaw,0)
