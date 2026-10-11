class_name KhDialogue
extends Node
signal updated
signal finished
const INTRO = "Has llegado demasiado lejos, intruso. Este templo no pertenece a los vivos."
const OPTIONS = ["He venido a reclamar el poder que escondéis.","Apártate. No tengo intención de morir aquí.","Dime qué proteges y quizá te perdone la vida."]
const REPLIES = ["El poder no se reclama. Devora a quienes creen merecerlo. Acólitos, mostradle su error.","La muerte ya conoce tu nombre. Mis acólitos serán los primeros en pronunciarlo.","Protejo un sueño que jamás debe terminar. Tu misericordia es una debilidad. Acólitos, atacad."]
var mission: KhMission
var audio: KhAudio
var text = INTRO
var awaiting_choice = true
var reply_elapsed = 0.0

func begin() -> void:
	text = INTRO
	awaiting_choice = true
	reply_elapsed = 0
	audio.speak(text)
	updated.emit()

func choose(index: int) -> bool:
	if not awaiting_choice or mission.state != KhMission.State.DIALOGUE or index < 0 or index > 2: return false
	mission.dialogue_choice = index
	text = REPLIES[index]
	awaiting_choice = false
	reply_elapsed = 0
	audio.speak(text)
	updated.emit()
	return true

func continue_dialogue() -> void:
	if awaiting_choice or mission.state != KhMission.State.DIALOGUE: return
	audio.stop_voice()
	finished.emit()

func _process(delta: float) -> void:
	if mission != null and mission.state == KhMission.State.DIALOGUE and not awaiting_choice:
		reply_elapsed += delta
		if reply_elapsed > 18:
			continue_dialogue()
