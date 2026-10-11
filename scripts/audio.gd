class_name KhAudio
extends Node
var voice_id = ""
var effects = {}
var ambient: AudioStreamPlayer
var enabled = true

func _ready() -> void:
	enabled = DisplayServer.get_name() != "headless"
	if DisplayServer.get_name() != "headless":
		var voices = DisplayServer.tts_get_voices_for_language("es")
		if voices.size() > 0:
			voice_id = voices[0]
	print("TTS español: ",voice_id if voice_id != "" else "sin voz; subtítulos disponibles")
	for key in ["sword","push","lightning","hit","enemy","slam","victory"]:
		effects[key] = synth(key)
	ambient = AudioStreamPlayer.new()
	add_child(ambient)
	ambient.stream = drone()
	ambient.volume_db = -25
	if enabled: ambient.play()

func synth(kind: String) -> AudioStreamWAV:
	var duration = 0.28 if kind != "victory" else 1.7
	var rate = 22050
	var count = int(duration*rate)
	var data = PackedByteArray()
	data.resize(count*2)
	var random = RandomNumberGenerator.new()
	random.seed = kind.hash()
	for i in range(count):
		var t = float(i)/rate
		var p = float(i)/count
		var env = sin(PI*p)*exp(-p*3)
		var sample = 0.0
		match kind:
			"sword","enemy": sample = (sin(t*(1100-800*p)*TAU)*0.3+random.randf_range(-1,1)*0.35)*env
			"push","slam": sample = (sin(t*(90-45*p)*TAU)*0.6+random.randf_range(-1,1)*0.25)*env
			"lightning": sample = random.randf_range(-1,1)*env*0.7+sin(t*700*TAU)*env*0.1
			"victory": sample = (sin(t*130.81*TAU)+sin(t*196*TAU)+sin(t*261.62*TAU))*env*0.18
			_: sample = random.randf_range(-1,1)*env*0.4
		data.encode_s16(i*2,int(clampf(sample,-1,1)*22000))
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = data
	return stream

func drone() -> AudioStreamWAV:
	var rate = 22050
	var count = rate*4
	var data = PackedByteArray()
	data.resize(count*2)
	for i in range(count):
		var t = float(i)/rate
		var sample = sin(t*55*TAU)*0.15+sin(t*82.5*TAU)*0.07+sin(t*110*TAU)*0.04
		data.encode_s16(i*2,int(sample*16000))
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = count
	return stream

func play_effect(kind: String) -> void:
	if not enabled or not effects.has(kind): return
	var p = AudioStreamPlayer.new()
	add_child(p)
	p.stream = effects[kind]
	p.volume_db = -13 if kind != "victory" else -8
	p.finished.connect(p.queue_free)
	p.play()

func speak(text: String) -> void:
	if enabled and voice_id != "":
		DisplayServer.tts_speak(text,voice_id,65,0.75,0.92,0,true)

func stop_voice() -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.tts_stop()
