class_name KhMission
extends Node

signal changed(state: int)
enum State { MENU, EXPLORATION, DIALOGUE, COMBAT, BOSS, VICTORY, DEFEAT, DUEL, GUARDIAN_DIALOGUE, TEMPLE }
var state = State.MENU
var dialogue_choice = -1
var slain_acolytes = 0
var elapsed = 0.0
var kills = 0
var guardian_resolution = ""
var heard_doctrine = false

func reset(duel: bool = false) -> void:
	dialogue_choice = -1
	slain_acolytes = 0
	elapsed = 0
	kills = 0
	guardian_resolution = ""
	heard_doctrine = false
	transition(State.DUEL if duel else State.EXPLORATION)

func transition(next: int) -> bool:
	var allowed = {
		State.MENU: [State.EXPLORATION, State.DUEL],
		State.EXPLORATION: [State.DIALOGUE, State.MENU, State.DEFEAT],
		State.DIALOGUE: [State.COMBAT, State.MENU],
		State.COMBAT: [State.GUARDIAN_DIALOGUE, State.DEFEAT, State.MENU],
		State.GUARDIAN_DIALOGUE: [State.BOSS, State.TEMPLE, State.MENU],
		State.BOSS: [State.TEMPLE, State.DEFEAT, State.MENU],
		State.TEMPLE: [State.VICTORY, State.DEFEAT, State.MENU],
		State.VICTORY: [State.MENU, State.EXPLORATION, State.DUEL],
		State.DEFEAT: [State.MENU, State.EXPLORATION, State.DUEL],
		State.DUEL: [State.MENU, State.VICTORY, State.DEFEAT]
	}
	if next == state: return true
	if not next in allowed.get(state, []):
		push_error("Transición inválida: %s -> %s" % [state, next])
		return false
	state = next
	changed.emit(state)
	return true

func enemy_died(guardian: bool) -> void:
	kills += 1
	if state == State.DUEL:
		transition(State.VICTORY)
	elif guardian and state == State.BOSS:
		guardian_resolution = "combat"
		transition(State.TEMPLE)
	elif not guardian and state == State.COMBAT:
		slain_acolytes += 1
		if slain_acolytes == 3: transition(State.GUARDIAN_DIALOGUE)

func claim_temple() -> bool:
	if state != State.TEMPLE or guardian_resolution.is_empty(): return false
	return transition(State.VICTORY)

func _process(delta: float) -> void:
	if state in [State.EXPLORATION, State.COMBAT, State.BOSS, State.DUEL, State.TEMPLE]:
		elapsed += delta

func objective() -> String:
	match state:
		State.EXPLORATION: return "Alcanza la entrada del templo"
		State.DIALOGUE: return "Escucha al guardián"
		State.COMBAT: return "Derrota a los acólitos · %d / 3" % slain_acolytes
		State.GUARDIAN_DIALOGUE: return "Decide qué hacer con el guardián"
		State.BOSS: return "Derrota al guardián de Kharuun"
		State.TEMPLE: return "Entra al templo · reclama el núcleo [E]"
		State.DUEL: return "Prueba interna · derrota al centinela"
		State.VICTORY: return "El núcleo de Kharuun es tuyo"
	return ""
