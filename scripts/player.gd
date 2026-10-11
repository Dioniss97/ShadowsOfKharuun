class_name KhPlayer
extends CharacterBody3D

signal health_changed
signal died
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
	camera.near = 0.12
	camera.current = true
	camera_pivot.global_position = global_position+Vector3(0,1.7,0)
	camera_pivot.rotation = Vector3(pitch,yaw,0)

func _unhandled_input(event: InputEvent) -> void:
	if not control_enabled:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x*0.0026
		pitch = clampf(pitch-event.relative.y*0.0023,-0.7,0.30)
	if event.is_action_pressed("attack"):
		combat.basic_attack()
	if event.is_action_pressed("push"):
		combat.use_ability(1)
	if event.is_action_pressed("lightning"):
		combat.use_ability(2)

func _physics_process(delta: float) -> void:
	invulnerable = maxf(0,invulnerable-delta)
	energy = minf(max_energy,energy+delta*10.0)
	var direction = Vector3.ZERO
	var running = false
	if control_enabled:
		var axis = Input.get_vector("move_left","move_right","move_forward","move_back")
		direction = Vector3(cos(yaw),0,-sin(yaw))*axis.x+Vector3(sin(yaw),0,cos(yaw))*axis.y
		running = Input.is_action_pressed("sprint")
	if automation_mode:
		direction = automation_direction
	var speed = 6.6 if running else 3.6
	velocity.x = move_toward(velocity.x,direction.x*speed,delta*22)
	velocity.z = move_toward(velocity.z,direction.z*speed,delta*22)
	if not is_on_floor():
		velocity.y -= 22*delta
	else:
		velocity.y = -0.5
	var before = global_position
	move_and_slide()
	distance_walked += Vector2(global_position.x-before.x,global_position.z-before.z).length()
	if global_position.y < -5:
		global_position = Vector3(0,1,8)
		velocity = Vector3.ZERO
	var flat_speed = Vector2(velocity.x,velocity.z).length()
	if direction.length() > 0.1:
		rig.rotation.y = lerp_angle(rig.rotation.y,atan2(-direction.x,-direction.z),delta*12)
	rig.animate(delta,flat_speed)
	camera_pivot.global_position = camera_pivot.global_position.lerp(global_position+Vector3(0,1.65,0),1.0-exp(-delta*14))
	camera_pivot.rotation.x = lerp_angle(camera_pivot.rotation.x,pitch,1.0-exp(-delta*18))
	camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y,yaw,1.0-exp(-delta*18))

func take_damage(amount: float) -> void:
	if health <= 0 or invulnerable > 0:
		return
	health = maxf(0,health-amount)
	invulnerable = 0.32
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
