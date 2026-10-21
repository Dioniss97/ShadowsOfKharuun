extends RefCounted
## CPU skinning of the imported GLB. Reports mesh/shaft intersections rather
## than treating a hand-bone offset as proof of a correct grip.
var skeleton: Skeleton3D
var surfaces: Array = []
var weight_errors := 0
var bind_errors := 0

func setup(model: Node3D, skel: Skeleton3D) -> void:
	skeleton = skel
	for instance in model.find_children("*", "MeshInstance3D", true, false):
		if instance.skin == null: continue
		var mapping: Array = []
		for bind in instance.skin.get_bind_count():
			var name := String(instance.skin.get_bind_name(bind))
			var bone: int = skel.find_bone(name) if not name.is_empty() else instance.skin.get_bind_bone(bind)
			if bone < 0: bind_errors += 1
			mapping.append([bone,instance.skin.get_bind_pose(bind)])
		for surface in instance.mesh.get_surface_count():
			var a: Array = instance.mesh.surface_get_arrays(surface)
			var selected: Dictionary = {}
			var feet: Array[int] = []
			var count: int = a[Mesh.ARRAY_VERTEX].size()
			for i in count:
				var total := 0.0
				var hand := 0.0
				var foot := 0.0
				for k in 4:
					var w: float = a[Mesh.ARRAY_WEIGHTS][i*4+k]
					total += w
					if w <= 0.0: continue
					var bind: int = a[Mesh.ARRAY_BONES][i*4+k]
					var bone: int = mapping[bind][0]
					var name := String(skel.get_bone_name(bone))
					if name == "hand_R" or name.begins_with("finger_R_"): hand += w
					if name.begins_with("foot_") or name.begins_with("toes_"): foot += w
				if absf(total-1.0) > .001: weight_errors += 1
				if hand > .5: selected[i] = true
				if foot > .5: feet.append(i)
			surfaces.append({"arrays":a,"mapping":mapping,"selected":selected,"feet":feet})

func feet_height() -> Dictionary:
	var lowest := INF
	var highest := -INF
	var samples := 0
	for surface in surfaces:
		var a: Array = surface.arrays
		var matrices: Array = []
		for bind in surface.mapping:
			matrices.append(skeleton.get_bone_global_pose(bind[0])*bind[1])
		for i in surface.feet:
			var point := Vector3.ZERO
			for k in 4:
				var w: float = a[Mesh.ARRAY_WEIGHTS][i*4+k]
				if w > 0: point += (matrices[a[Mesh.ARRAY_BONES][i*4+k]]*a[Mesh.ARRAY_VERTEX][i])*w
			point = skeleton.global_transform*point
			lowest = minf(lowest,point.y)
			highest = maxf(highest,point.y)
			samples += 1
	return {"minimum_y_m":lowest,"maximum_y_m":highest,"sampled_vertices":samples}

func evaluate(grip: Transform3D, radius: float, length: float) -> Dictionary:
	var points := 0
	var penetrating := 0
	var triangle_hits := 0
	var minimum := 100.0
	var non_finite := 0
	var contacts := 0
	var maximum_depth := 0.0
	var inverse := grip.affine_inverse()
	for surface in surfaces:
		var a: Array = surface.arrays
		var matrices: Array = []
		for bind in surface.mapping:
			matrices.append(skeleton.get_bone_global_pose(bind[0])*bind[1])
		var posed := PackedVector3Array()
		posed.resize(a[Mesh.ARRAY_VERTEX].size())
		for i in posed.size():
			var p: Vector3 = a[Mesh.ARRAY_VERTEX][i]
			var result := Vector3.ZERO
			for k in 4:
				var w: float = a[Mesh.ARRAY_WEIGHTS][i*4+k]
				if w > 0.0: result += (matrices[a[Mesh.ARRAY_BONES][i*4+k]]*p)*w
			result = inverse*(skeleton.global_transform*result)
			posed[i] = result
			if not result.is_finite(): non_finite += 1
			if not surface.selected.has(i) or absf(result.y) > length*.5: continue
			points += 1
			var radial := Vector2(result.x,result.z).length()
			minimum = minf(minimum,radial)
			if radial < radius-.0005:
				penetrating += 1
				maximum_depth = maxf(maximum_depth,radius-radial)
			elif radial < radius+.003: contacts += 1
		var indices: PackedInt32Array = a[Mesh.ARRAY_INDEX]
		for i in range(0,indices.size(),3):
			if not (surface.selected.has(indices[i]) or surface.selected.has(indices[i+1]) or surface.selected.has(indices[i+2])): continue
			var poly: Array[Vector3] = [posed[indices[i]],posed[indices[i+1]],posed[indices[i+2]]]
			poly = clip_y(clip_y(poly,-length*.5,true),length*.5,false)
			if poly.size() < 3: continue
			var distance := projected_distance(poly)
			if distance < radius-.0005: triangle_hits += 1
	return {"sampled_vertices":points,"penetrating_vertices":penetrating,"intersecting_triangles":triangle_hits,
		"minimum_vertex_radius_m":minimum,"maximum_vertex_depth_m":maximum_depth,"near_contact_vertices":contacts,
		"non_finite_vertices":non_finite,"radius_m":radius,"tolerance_m":.0005}

func clip_y(poly: Array[Vector3], boundary: float, above: bool) -> Array[Vector3]:
	var out: Array[Vector3] = []
	if poly.is_empty(): return out
	for i in poly.size():
		var a := poly[i]
		var b := poly[(i+1)%poly.size()]
		var inside_a := a.y >= boundary if above else a.y <= boundary
		var inside_b := b.y >= boundary if above else b.y <= boundary
		if inside_a: out.append(a)
		if inside_a != inside_b: out.append(a.lerp(b,(boundary-a.y)/(b.y-a.y)))
	return out

func projected_distance(poly: Array[Vector3]) -> float:
	var positive := false
	var negative := false
	var nearest := INF
	for i in poly.size():
		var a := Vector2(poly[i].x,poly[i].z)
		var b := Vector2(poly[(i+1)%poly.size()].x,poly[(i+1)%poly.size()].z)
		var edge := b-a
		var cross := edge.cross(-a)
		positive = positive or cross > .00000001
		negative = negative or cross < -.00000001
		var t := clampf(-a.dot(edge)/maxf(edge.length_squared(),.0000000001),0,1)
		nearest = minf(nearest,(a+edge*t).length())
	return nearest if (positive and negative) or (not positive and not negative) else 0.0
