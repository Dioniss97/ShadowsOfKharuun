class_name KhRig
extends Node3D

var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var body: Node3D
var sword: Node3D
var phase = 0.0
var attack_duration: float = 0.9
var attack_time = 0.0
var hit_time = 0.0
var dying = false
var boss = false
var guarding: bool = false
var combat_stance: bool = false

func build(tint: Color, blade_color: Color, guardian: bool = false) -> void:
	boss = guardian
	var cloth = KhGeometry.material(tint)
	var armor = KhGeometry.material(Color(0.18,0.18,0.21),0.4)
	var trim = KhGeometry.material(Color(0.48,0.35,0.19),0.35)
	var skin = KhGeometry.material(Color(0.48,0.40,0.37))
	var dark = KhGeometry.material(Color(0.035,0.025,0.04))
	body = Node3D.new()
	add_child(body)
	KhGeometry.cylinder(body,Vector3(0,0.8,0),0.36,0.9,cloth,0.23,8)
	KhGeometry.box(body,Vector3(0,1.28,0),Vector3(0.64,0.65,0.39),cloth)
	KhGeometry.box(body,Vector3(0,1.3,-0.205),Vector3(0.34,0.42,0.05),armor)
	KhGeometry.box(body,Vector3(0,0.94,0),Vector3(0.66,0.09,0.43),trim)
	KhGeometry.box(body,Vector3(0,1.48,0.13),Vector3(0.52,0.19,0.18),armor)
	KhGeometry.sphere(body,Vector3(0,1.82,0),0.23,skin)
	KhGeometry.sphere(body,Vector3(0,1.86,0.075),0.28,dark)
	KhGeometry.box(body,Vector3(0,1.83,-0.22),Vector3(0.33,0.24,0.08),dark)
	KhGeometry.box(body,Vector3(0,1.87,-0.267),Vector3(0.22,0.025,0.018),KhGeometry.material(blade_color,0.2,2.0))
	for side in [-1,1]:
		var arm = Node3D.new()
		body.add_child(arm)
		arm.position = Vector3(side*0.42,1.5,0)
		KhGeometry.sphere(arm,Vector3.ZERO,0.20,armor)
		KhGeometry.cylinder(arm,Vector3(0,-0.29,0),0.11,0.56,cloth,0.14,8)
		KhGeometry.box(arm,Vector3(0,-0.60,-0.02),Vector3(0.18,0.17,0.2),armor)
		var leg = Node3D.new()
		add_child(leg)
		leg.position = Vector3(side*0.16,0.78,0)
		KhGeometry.cylinder(leg,Vector3(0,-0.27,0),0.12,0.52,dark,0.13,8)
		KhGeometry.box(leg,Vector3(0,-0.66,-0.06),Vector3(0.24,0.25,0.39),armor)
		if side == -1:
			left_arm = arm
			left_leg = leg
		else:
			right_arm = arm
			right_leg = leg
	sword = Node3D.new()
	right_arm.add_child(sword)
	sword.position = Vector3(0,-0.59,-0.10)
	# The blade grows along local +Y; -PI/2 maps it to the character's front (-Z).
	sword.rotation.x = -PI/2.0
	KhGeometry.cylinder(sword,Vector3(0,0.04,0),0.05,0.28,trim,0.05,10)
	KhGeometry.cylinder(sword,Vector3(0,0.81,0),0.035,1.35,KhGeometry.material(blade_color,0.2,4.5),0.025,10)
	KhGeometry.cylinder(sword,Vector3(0,0.81,0),0.013,1.37,KhGeometry.material(Color(1,0.92,0.82),0.2,6),0.01,8)
	KhGeometry.light(sword,Vector3(0,0.55,0),blade_color,0.8,2.4)
	# Cape panels have an intentionally angular silhouette.
	KhGeometry.box(body,Vector3(0,0.96,0.28),Vector3(0.62,1.13,0.06),cloth).rotation.x = -0.16
	# Layered panels break up the primitive torso and carry the robe silhouette.
	for side in [-1,1]:
		var panel = KhGeometry.box(body,Vector3(side*0.15,0.74,-0.25),Vector3(0.24,0.73,0.055),cloth)
		panel.rotation.z = side*0.07
		KhGeometry.box(body,Vector3(side*0.26,1.24,-0.205),Vector3(0.06,0.57,0.035),trim)
		KhGeometry.box(body,Vector3(side*0.27,0.80,0.325),Vector3(0.034,0.9,0.025),trim)
	KhGeometry.box(body,Vector3(0,0.97,-0.241),Vector3(0.15,0.13,0.045),trim)
	if guardian:
		KhGeometry.box(body,Vector3(-0.48,1.59,0),Vector3(0.4,0.19,0.5),trim).rotation.z = -0.28
		KhGeometry.box(body,Vector3(0.48,1.59,0),Vector3(0.4,0.19,0.5),trim).rotation.z = 0.28
		scale = Vector3.ONE*1.28

func animate(delta: float, speed: float) -> void:
	phase += delta*(3.0+speed*2.0)
	attack_time = maxf(0,attack_time-delta)
	hit_time = maxf(0,hit_time-delta)
	if dying:
		rotation.z = lerpf(rotation.z,-1.4,delta*4.0)
		position.y = lerpf(position.y,-0.28,delta*3.0)
		return
	var stride = minf(speed/4.0,1.0)*0.57
	left_leg.rotation.x = sin(phase)*stride
	right_leg.rotation.x = -sin(phase)*stride
	var arm_stride = sin(phase)*stride
	var ready_pose = Vector3(0.16+arm_stride*0.3,0.0,0.12)
	left_arm.rotation = Vector3(-arm_stride*0.6,0.0,-0.08)
	if combat_stance or guarding:
		# Raising the forearm moves both the hand and blade ahead of the torso.
		ready_pose = Vector3(0.62+arm_stride*0.15,0.12,0.12)
		left_arm.rotation = Vector3(0.32-arm_stride*0.25,0.0,-0.12)
	if guarding:
		ready_pose = Vector3(1.02+arm_stride*0.10,0.08,0.12)
		left_arm.rotation.x = 0.68-arm_stride*0.15
	right_arm.rotation = ready_pose
	body.position.y = sin(phase*2.0)*0.025*minf(speed,1.0)+sin(phase*0.55)*0.008
	# Hit recoil is a small independent roll, never a replacement for the swing.
	body.rotation.z = sin(hit_time*40.0)*hit_time*0.28
	if attack_time > 0:
		var p = clampf(1.0-attack_time/attack_duration,0.0,1.0)
		var raised_pose = Vector3(1.45,-0.12,0.20)
		var contact_pose = Vector3(0.18,0.22,0.14)
		# Contact at 0.42 seconds in a 0.9-second action, matching tactical damage.
		# The stroke stays in front and to the right of the body, then recovers.
		const CONTACT_PHASE = 0.42/0.9
		if p < 0.30:
			var prepare = smoothstep(0.0,0.30,p)
			right_arm.rotation = ready_pose.lerp(raised_pose,prepare)
			body.rotation.y = lerpf(0.0,-0.08,prepare)
		elif p < CONTACT_PHASE:
			var strike = smoothstep(0.30,CONTACT_PHASE,p)
			right_arm.rotation = raised_pose.lerp(contact_pose,strike)
			body.rotation.y = lerpf(-0.08,0.08,strike)
		else:
			var recover = smoothstep(CONTACT_PHASE,1.0,p)
			right_arm.rotation = contact_pose.lerp(ready_pose,recover)
			body.rotation.y = lerpf(0.08,0.0,recover)
	else:
		body.rotation.y = lerpf(body.rotation.y,0,delta*8.0)

func swing(duration: float = 0.9) -> void:
	attack_duration = maxf(duration,0.1)
	attack_time = attack_duration

func hit() -> void:
	hit_time = 0.25
