class_name KhMission
extends Node

signal changed(state: int)
enum State { MENU, EXPLORATION, DIALOGUE, COMBAT, BOSS, VICTORY, DEFEAT, DUEL }
var state = State.MENU
var dialogue_choice = -1
var slain_acolytes = 0
var elapsed = 0.0
var kills = 0

func reset(duel: bool = false) -> void:
	dialogue_choice = -1
	slain_acolytes = 0
	elapsed = 0
	kills = 0
	transition(State.DUEL if duel else State.EXPLORATION)

func transition(next: int) -> bool:
	var allowed = {
		State.MENU: [State.EXPLORATION,State.DUEL],
		State.EXPLORATION: [State.DIALOGUE,State.MENU],
		State.DIALOGUE: [State.COMBAT,State.MENU],
		State.COMBAT: [State.BOSS,State.DEFEAT,State.MENU],
		State.BOSS: [State.VICTORY,State.DEFEAT,State.MENU],
		State.VICTORY: [State.MENU,State.EXPLORATION,State.DUEL],
		State.DEFEAT: [State.MENU,State.EXPLORATION,State.DUEL],
		State.DUEL: [State.MENU,State.VICTORY,State.DEFEAT]
	}
	if next == state:
		return true
	if not next in allowed.get(state,[]):
		push_error("Transición inválida: %s -> %s" % [state,next])
		return false
	state = next
	changed.emit(state)
	return true

func enemy_died(guardian: bool) -> void:
	kills += 1
	if state == State.DUEL:
		transition(State.VICTORY)
	elif guardian and state == State.BOSS:
		transition(State.VICTORY)
	elif not guardian and state == State.COMBAT:
		slain_acolytes += 1
		if slain_acolytes == 3:
			transition(State.BOSS)

func _process(delta: float) -> void:
	if state in [State.EXPLORATION,State.DIALOGUE,State.COMBAT,State.BOSS,State.DUEL]:
		elapsed += delta

func objective() -> String:
	match state:
		State.EXPLORATION: return "Alcanza la entrada del templo"
		State.DIALOGUE: return "Escucha al guardián"
		State.COMBAT: return "Derrota a los acólitos · %d / 3" % slain_acolytes
		State.BOSS: return "Derrota al guardián de Kharuun"
		State.DUEL: return "Duelo · derrota al centinela"
		State.VICTORY: return "El templo ha caído"
	return ""
