class_name KhCharacterMaterials
extends RefCounted
## Explicit engine-side recipes: glTF does not preserve every Blender control.
static var _materials: Dictionary = {}

static func apply(instance: MeshInstance3D) -> void:
	for surface in range(instance.mesh.get_surface_count()):
		var source := instance.get_active_material(surface) as StandardMaterial3D
		if source == null: continue
		var key := source.resource_name
		if not _materials.has(key):
			var mat := source.duplicate() as StandardMaterial3D
			if key.begins_with("Skin_"):
				mat.metallic_specular = .32
				mat.subsurf_scatter_enabled = true
				mat.subsurf_scatter_skin_mode = true
				mat.subsurf_scatter_strength = .06
			elif key.begins_with("Leather_"):
				mat.metallic_specular = .30
				mat.normal_scale = .65
			elif key.begins_with("Robe_") or key.begins_with("Base_woven") or key.begins_with("Linen_"):
				mat.metallic_specular = .22
				mat.normal_scale = .65
			_materials[key] = mat
		instance.set_surface_override_material(surface,_materials[key])
