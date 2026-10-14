class_name KhDialogue
extends Node
signal updated
signal finished
const INTRO = "Has llegado demasiado lejos, intruso. Este templo no pertenece a los vivos."
const OPTIONS = ["He venido a reclamar el poder que escondéis.", "Apártate. No tengo intención de morir aquí.", "Dime qué proteges y quizá te perdone la vida."]
const REPLIES = ["El poder no se reclama. Devora a quienes creen merecerlo. Acólitos, mostradle su error.", "La muerte ya conoce tu nombre. Mis acólitos serán los primeros en pronunciarlo.", "Protejo un sueño que jamás debe terminar. Tu misericordia es una debilidad. Acólitos, atacad."]
const OFFER = "Mis acólitos habían aprendido a obedecer; creyeron que eso bastaba para merecer el poder. Tú has demostrado algo más. No confundas una victoria con dominio. Este templo aún podría ser tu tumba… o el principio de tu verdadero aprendizaje."
const LESSON = "El miedo no desaparece cuando lo niegas. Se convierte en tu dueño. Reconócelo; aprende a dirigirlo. El poder que buscas no responde a quien pide permiso, sino a quien acepta el precio de ejercerlo."
var mission: KhMission
var audio: KhAudio
var text = INTRO
var awaiting_choice = true
var reply_elapsed = 0.0
var stage = "intro"
var next_state = KhMission.State.COMBAT

func options() -> Array:
	match stage:
		"offer": return ["No someteré mi voluntad a tu doctrina. Permíteme pasar.", "¿Qué es lo que crees poder enseñarme?"]
		"lesson": return ["Acepto tu enseñanza. Reclamaré el poder del templo.", "Ya me has enseñado lo que necesitaba. Ahora eres el último obstáculo."]
	return OPTIONS

func begin() -> void:
	stage = "intro"
	next_state = KhMission.State.COMBAT
	show_text(INTRO, true)

func begin_guardian() -> void:
	stage = "offer"
	next_state = KhMission.State.BOSS
	show_text(OFFER, true)

func show_text(value: String, choices: bool) -> void:
	text = value
	awaiting_choice = choices
	reply_elapsed = 0
	if is_instance_valid(audio): audio.speak(text)
	updated.emit()

func choose(index: int) -> bool:
	if not awaiting_choice or not mission.state in [KhMission.State.DIALOGUE, KhMission.State.GUARDIAN_DIALOGUE]: return false
	if index < 0 or index >= options().size(): return false
	if stage == "intro":
		mission.dialogue_choice = index
		show_text(REPLIES[index], false)
	elif stage == "offer":
		if index == 1:
			mission.heard_doctrine = true
			stage = "lesson"
			show_text(LESSON, true)
		else:
			next_state = KhMission.State.BOSS
			show_text("Entonces aún eliges servir a tus límites. Acércate; te mostraré cuánto te han costado.", false)
	else:
		if index == 0:
			mission.guardian_resolution = "peaceful"
			next_state = KhMission.State.TEMPLE
			show_text("El umbral te pertenece. Reclama lo que has venido a buscar; demuestra que mis palabras no han caído en tierra estéril.", false)
		else:
			next_state = KhMission.State.BOSS
			show_text("Aprendes con rapidez. Veamos si tu voluntad sobrevive al precio de esa lección.", false)
	return true

func continue_dialogue() -> void:
	if awaiting_choice or not mission.state in [KhMission.State.DIALOGUE, KhMission.State.GUARDIAN_DIALOGUE]: return
	if is_instance_valid(audio): audio.stop_voice()
	finished.emit()
