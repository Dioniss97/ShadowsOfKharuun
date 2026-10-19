class_name KhWardrobe
extends RefCounted
signal changed
const TUNIC := "umbral"
var owned_uniforms: Array[String] = [TUNIC]
var uniform_id := ""
var head_id := ""

func equip_uniform(id: String) -> bool:
	if not owned_uniforms.has(id): return false
	if uniform_id != id:
		uniform_id = id
		changed.emit()
	return true

func remove_uniform() -> void:
	if uniform_id == "": return
	uniform_id = ""
	changed.emit()
