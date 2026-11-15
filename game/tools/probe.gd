extends SceneTree
# Dev helper: print the bounding box of every model so the scene can be laid out.
func _aabb(n: Node, xf: Transform3D, box: Array) -> void:
	if n is Node3D:
		xf = xf * (n as Node3D).transform
	if n is MeshInstance3D and n.mesh != null:
		var b: AABB = xf * n.mesh.get_aabb()
		box[0] = b if box[1] == false else (box[0] as AABB).merge(b)
		box[1] = true
	for c in n.get_children():
		_aabb(c, xf, box)

func _init() -> void:
	for dir in ["res://assets/kenney_space/Models/GLTF format/", "res://assets/kenney_station/Models/GLB format/", "res://assets/kaykit/gltf/"]:
		print("## ", dir)
		var d := DirAccess.open(dir)
		var names := []
		for f in d.get_files():
			if f.ends_with(".glb") or f.ends_with(".gltf"):
				names.append(f)
		names.sort()
		for f in names:
			var ps = load(dir + f)
			if not (ps is PackedScene):
				print(f, " LOAD FAIL"); continue
			var n: Node = ps.instantiate()
			var box := [AABB(), false]
			_aabb(n, Transform3D.IDENTITY, box)
			var b: AABB = box[0]
			var anims := n.find_children("*", "AnimationPlayer", true, false).size()
			print("%s size=(%.2f,%.2f,%.2f) min=(%.2f,%.2f,%.2f) anim=%d" % [f, b.size.x, b.size.y, b.size.z, b.position.x, b.position.y, b.position.z, anims])
			n.free()
	quit()
