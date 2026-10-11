extends Node
var main: Node
var capture = false
var combat_time = 0.0
var hits = 0
var ability_uses = 0
var last_attack = 0.0
var damage_taken = 0.0
var previous_health = 340.0
var battle = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	call_deferred("run")

func frames(count: int) -> void:
	for i in range(count): await get_tree().physics_frame

func run() -> void:
	await frames(10)
	main.ui.menu.start_requested.emit()
	await frames(10)
	var p = main.level.player
	p.automation_mode = true
	p.automation_direction = Vector3(0,0,-1)
	for i in range(700):
		await get_tree().physics_frame
		if main.mission.state == KhMission.State.DIALOGUE: break
	if main.mission.state != KhMission.State.DIALOGUE:
		finish(false,"No se alcanzó el diálogo")
		return
	await frames(720)
	main.dialogue.choose(2)
	await frames(660)
	main.dialogue.continue_dialogue()
	previous_health = p.health
	battle = true
	for i in range(15000):
		await get_tree().physics_frame
		if main.mission.state in [KhMission.State.VICTORY,KhMission.State.DEFEAT]: break
	battle = false
	finish(main.mission.state == KhMission.State.VICTORY,"Partida normal con IA de prueba; sin alterar salud, daño ni cooldowns")

func _physics_process(delta: float) -> void:
	if not battle: return
	combat_time += delta
	last_attack += delta
	var p = main.level.player
	var combat = main.level.combat
	if p.health < previous_health: damage_taken += previous_health-p.health
	previous_health = p.health
	var target = combat.nearest_target(80)
	if target == null: return
	var dir = target.global_position-p.global_position
	dir.y = 0
	var distance = dir.length()
	var move = dir.normalized() if distance > 2.2 else Vector3.ZERO
	var evade = Vector3.ZERO
	for e in combat.valid_targets():
		var away = p.global_position-e.global_position
		away.y = 0
		if e.mode == KhEnemy.Mode.WINDUP and away.length() < (5.5 if e.slam else 3.15):
			evade += away.normalized()
	if evade.length() > 0.1: move = evade.normalized()
	p.automation_direction = move
	p.yaw = atan2(-dir.x,-dir.z)
	if distance < 2.8 and last_attack > 0.95:
		if combat.basic_attack():
			hits += 1
			last_attack = 0
	if combat.push_cooldown <= 0 and distance < 5.2:
		if combat.use_ability(1): ability_uses += 1
	if combat.lightning_cooldown <= 0 and distance < 10.5:
		if combat.use_ability(2): ability_uses += 1

func finish(passed: bool, details: String) -> void:
	var report = {"passed":passed,"details":details,"mission_seconds":main.mission.elapsed,"combat_seconds":combat_time,"damage_taken":damage_taken,"remaining_health":main.level.player.health,"basic_attacks":hits,"ability_uses":ability_uses,"kills":main.mission.kills,"state":main.mission.state}
	var file = FileAccess.open("res://tests/playthrough_report.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	file.close()
	print("KHARUUN_PLAYTHROUGH | ",JSON.stringify(report))
	get_tree().quit(0 if passed else 1)
