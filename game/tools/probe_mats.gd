extends SceneTree
# Dev helper: list the materials of a few models.
func _init() -> void:
	for f in ["astronautA", "astronautB", "satelliteDish_large"]:
		var n: Node = load("res://assets/kenney_space/Models/GLTF format/" + f + ".glb").instantiate()
		print("## ", f)
		for c in n.find_children("*", "MeshInstance3D", true, false):
			var mi := c as MeshInstance3D
			for i in range(mi.mesh.get_surface_count()):
				var m = mi.mesh.surface_get_material(i)
				var col = m.albedo_color if m is BaseMaterial3D else null
				var tex = (m.albedo_texture != null) if m is BaseMaterial3D else null
				print("  ", mi.name, " surf ", i, " mat=", m.resource_name if m else "-", " albedo=", col, " tex=", tex)
		n.free()
	quit()
