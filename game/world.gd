extends Node3D
## The 2.5D diorama, built in code: one Mars habitat room (cutaway view) and the power yard outside.
## The camera is fixed. Crew members walk with tweens along a few waypoints (no navmesh).
## Everything here runs on the Compatibility renderer (web): simple lights, fog and glow only.

signal tapped(id: String)

const SK := "res://assets/kenney_space/Models/GLTF format/"
const ST := "res://assets/kenney_station/Models/GLB format/"
const KK := "res://assets/kaykit/gltf/"
const ICONS := "res://assets/icons/"
const UIPNG := "res://assets/kenney_ui/PNG/"

const COL_ENG := Color(1.0, 0.74, 0.22)
const COL_PRO := Color(0.42, 0.82, 1.0)
const COL_ON := Color(0.30, 0.95, 0.40)
const COL_OFF := Color(0.25, 0.12, 0.10)

const PANO_YAW := 235.0
const DOOR_X := 3.5        # the airlock wall
const NOOK_X := -1.5       # the line between the shelter nook and the main room
const MOVE_SPEED := 2.2       # units per second when a player steers an astronaut
const WALK_SPEED := 2.0    # units per second: calm, never rushed
const UNIT_X := [4.7, 5.85, 7.0, 8.15]

# Named floor points the crew can walk to.
const POINTS := {
	"eng_home": Vector3(0.9, 0, 0.45),
	"pro_home": Vector3(-0.5, 0, 0.45),
	"eng_console": Vector3(0.8, 0, -0.45),
	"pro_console": Vector3(-0.55, 0, -0.45),
	"greenhouse": Vector3(2.3, 0, -0.35),
	"door_in": Vector3(2.95, 0, 0.0),
	"door_out": Vector3(4.05, 0, 0.0),
	"power": Vector3(7.55, 0, 0.05),
	"nook_gate": Vector3(-1.5, 0, 1.0),
	"shelter": Vector3(-2.15, 0, 0.75),
	"shelter_a": Vector3(-2.95, 0, 0.55),
	"shelter_b": Vector3(-2.2, 0, 0.55),
	"dish_pt": Vector3(4.08, 0, -2.4),
	"shelter_help": Vector3(-1.3, 0, 1.0),
	"power_help": Vector3(6.4, 0, 0.05),
}

const TANK_ON := Color(0.45, 0.85, 1.0)
const TANK_OFF := Color(0.16, 0.18, 0.24)
const PLANT_COL := {"normal": Color(0.30, 0.72, 0.30), "weak": Color(0.66, 0.64, 0.30), "strong": Color(0.22, 0.82, 0.30)}
const NOOK_FREE := Rect2(-1.85, -0.45, 0.75, 1.2)   # where the extra cargo goes when the shelter is reinforced

# Where a steered astronaut may stand, as rectangles on the floor (x, z, width, depth). No physics needed.
const WALK := [
	Rect2(-1.1, -0.45, 4.25, 1.2),    # main room, in front of the consoles
	Rect2(-3.2, 0.75, 6.35, 0.6),     # front strip of the room, from the shelter to the door
	Rect2(-3.2, 0.42, 1.35, 0.33),    # shelter mat, in front of the bunks
	Rect2(3.0, -0.22, 1.2, 0.44),     # doorway
	Rect2(3.95, -0.2, 5.35, 2.1),     # yard, in front of the power units
	Rect2(3.9, -2.9, 0.3, 2.7),       # path beside the power units
	Rect2(3.9, -2.9, 2.7, 1.15),      # behind the power units, by the antenna
]

var cam: Camera3D
var env: Environment
var sun: DirectionalLight3D
var fill: DirectionalLight3D
var room_lights: Array[OmniLight3D] = []
var grow_light: OmniLight3D
var grow_bar_mat: StandardMaterial3D
var backdrop_mat: StandardMaterial3D
var storm_fx: CPUParticles3D
var unit_lamps: Array[StandardMaterial3D] = []
var unit_nodes: Array[Node3D] = []
var unit_marks: Array[Sprite3D] = []     # "needs repair" icons over broken units
var unit_on: Array[bool] = [true, true, true, true]
var extra_shield: Array[Node3D] = []   # the cargo added when the shelter is reinforced
var crew := {}                          # role -> {node, body, phase, walking, yaw}
var sprouts: Array[MeshInstance3D] = []
var tank_mats: Array[StandardMaterial3D] = []
var leaf: StandardMaterial3D
var goal_rings: Array[MeshInstance3D] = []
var shelter_reinforced := false
var controls := {}                      # role -> "wasd", "arrows" or "both": who steers which astronaut
var tappables := {}                     # id -> {pos: Vector3, radius: float, marker: Sprite3D}
var reduced_motion := false
var _t := 0.0
var _mood: Tween
var _mood_name := "day"
var _power_frac := 1.0

func _ready() -> void:
	_build_sky_and_light()
	_build_ground()
	_build_room()
	_build_shelter()
	_build_power_yard()
	_build_crew()
	_build_storm_fx()
	_build_goal_rings()
	_build_camera()
	reset_scene()

# ---------------------------------------------------------------- helpers

func _bounds(n: Node, xf: Transform3D, acc: Array) -> void:
	if n is Node3D:
		xf = xf * (n as Node3D).transform
	if n is MeshInstance3D and (n as MeshInstance3D).mesh != null:
		var b: AABB = xf * (n as MeshInstance3D).mesh.get_aabb()
		acc[0] = b if not acc[1] else (acc[0] as AABB).merge(b)
		acc[1] = true
	for c in n.get_children():
		_bounds(c, xf, acc)

## Loads a model and returns a pivot whose origin is the centre of the model's footprint, on the floor.
func _prop(base: String, mname: String, pos: Vector3, yaw_deg := 0.0, scl := 1.0, parent: Node3D = null) -> Node3D:
	var path: String = base + mname + (".gltf" if base == KK else ".glb")
	var pivot := Node3D.new()
	var ps = load(path)
	if ps is PackedScene:
		var inner: Node3D = ps.instantiate()
		var acc := [AABB(), false]
		_bounds(inner, Transform3D.IDENTITY, acc)
		var b: AABB = acc[0]
		var c := b.get_center()
		inner.position -= Vector3(c.x, b.position.y, c.z)
		pivot.add_child(inner)
	else:
		push_warning("missing model: " + path)
	pivot.position = pos
	pivot.rotation_degrees.y = yaw_deg
	pivot.scale = Vector3.ONE * scl
	(parent if parent != null else self).add_child(pivot)
	return pivot

func _box(size: Vector3, pos: Vector3, col: Color, parent: Node3D = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = 0.9
	mi.material_override = m
	mi.position = pos
	(parent if parent != null else self).add_child(mi)
	return mi

func _glow_mat(col: Color, energy := 2.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.emission_enabled = true
	m.emission = col
	m.emission_energy_multiplier = energy
	return m

func _icon_sprite(file: String, col: Color, size := 0.34) -> Sprite3D:
	var s := Sprite3D.new()
	var tex: Texture2D = load(file)
	s.texture = tex
	s.pixel_size = size / float(max(tex.get_width(), 1))
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.modulate = col
	s.no_depth_test = true
	s.render_priority = 2
	return s

# ---------------------------------------------------------------- world

func _build_sky_and_light() -> void:
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.3
	env.glow_bloom = 0.0
	env.fog_enabled = true
	env.fog_density = 0.008
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38, -50, 0)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 40.0
	add_child(sun)
	fill = DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-30, 150, 0)
	add_child(fill)
	# Real Mars: Perseverance Mastcam-Z 360° panorama (NASA/JPL-Caltech/MSSS/ASU), on a cylinder behind the base.
	var cyl := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 30.0
	cm.bottom_radius = 30.0
	cm.height = 10.2
	cm.cap_top = false
	cm.cap_bottom = false
	cm.radial_segments = 64
	cyl.mesh = cm
	cyl.position = Vector3(2, -0.65, -2)
	cyl.rotation_degrees.y = PANO_YAW
	backdrop_mat = StandardMaterial3D.new()
	backdrop_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	backdrop_mat.cull_mode = BaseMaterial3D.CULL_FRONT
	backdrop_mat.albedo_texture = load("res://assets/nasa/PIA24264.jpg")
	# Only the top strip of the photo (far terrain, hills, sky); the rover deck below it is cropped out.
	backdrop_mat.uv1_scale = Vector3(-1.75, 0.36, 1)
	backdrop_mat.uv1_offset = Vector3(0, 0.012, 0)
	backdrop_mat.disable_fog = true
	cyl.material_override = backdrop_mat
	add_child(cyl)

func _build_ground() -> void:
	var g := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(90, 90)
	g.mesh = pm
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color(0.56, 0.30, 0.19)
	gm.roughness = 1.0
	g.material_override = gm
	g.position.y = -0.02
	add_child(g)
	_prop(SK, "rock_largeA", Vector3(9.3, 0, 1.5), 30, 1.3)
	_prop(SK, "rocks_smallA", Vector3(4.6, 0, 2.2), 0, 1.2)
	_prop(SK, "rocks_smallB", Vector3(-5.0, 0, 1.6), 80, 1.2)
	_prop(SK, "rock_largeB", Vector3(-5.6, 0, -1.4), 10, 1.4)
	_prop(SK, "crater", Vector3(7.0, 0, 2.3), 0, 1.6)
	_prop(SK, "craterLarge", Vector3(-6.5, 0, -5.0), 0, 2.4)
	# The rest of the base, far behind the room.
	_prop(SK, "hangar_roundGlass", Vector3(-7.5, 0, -11.0), 20, 1.6)
	_prop(KK, "basemodule_A", Vector3(-1.5, 0, -11.0), 0, 1.6)
	_prop(KK, "roofmodule_solarpanels", Vector3(-1.5, 1.6, -11.0), 0, 1.6)
	_prop(KK, "tunnel_straight_A", Vector3(-4.3, 0, -11.2), 0, 1.6)
	for i in range(3):
		_prop(KK, "solarpanel", Vector3(11.0 + 1.5 * i, 0, -8.0), 0, 1.6)
	_prop(SK, "satelliteDish_large", Vector3(5.3, 0, -3.6), -35, 1.9)
	_prop(SK, "rover", Vector3(9.6, 0, -2.8), -60, 1.7)

func _build_room() -> void:
	# Floor: 7 x 3 tiles. Tile tops sit at y = 0.
	for x in range(-3, 4):
		for z in range(-1, 2):
			_prop(ST, "floor", Vector3(x, -0.3, z))
	# A blue mat marks the storm shelter corner.
	_box(Vector3(1.9, 0.02, 2.7), Vector3(-2.5, 0.01, 0.0), Color(0.30, 0.52, 0.78))
	# Back wall (no front wall: this is a cutaway view).
	var back := ["wall", "wall", "wall-banner", "wall-window", "wall", "wall-window", "wall"]
	for i in range(7):
		_prop(ST, back[i], Vector3(i - 3, 0, -1.5))
	for z in range(-1, 2):
		_prop(ST, "wall", Vector3(-3.5, 0, z), 90)
	_prop(ST, "wall", Vector3(DOOR_X, 0, -1), 90)
	_prop(ST, "wall-door", Vector3(DOOR_X, 0, 0), 90)
	# Consoles along the back wall.
	_prop(ST, "computer-screen", Vector3(-0.55, 0, -1.05))
	_prop(ST, "computer-system", Vector3(0.8, 0, -1.0))
	# Greenhouse shelf: a few sprouts under a grow lamp. The lamp is the first thing to go when power is low.
	_prop(ST, "table", Vector3(2.35, 0, -1.0))
	_box(Vector3(0.95, 0.06, 0.42), Vector3(2.35, 0.43, -1.0), Color(0.30, 0.20, 0.14))
	leaf = StandardMaterial3D.new()
	leaf.albedo_color = PLANT_COL.normal
	leaf.roughness = 0.8
	for i in range(6):   # six plants, the number NASA's Veggie garden on the Space Station holds
		var s := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.top_radius = 0.0
		cone.bottom_radius = 0.08
		cone.height = 0.16 + 0.04 * float(i % 2)
		cone.radial_segments = 6
		s.mesh = cone
		s.material_override = leaf
		s.position = Vector3(2.06 + 0.29 * float(i % 3), 0.46 + cone.height * 0.5, -1.1 + 0.2 * float(i / 3))
		add_child(s)
		sprouts.append(s)
	grow_bar_mat = _glow_mat(Color(1.0, 0.45, 0.9), 1.0)
	var bar := _box(Vector3(0.9, 0.05, 0.12), Vector3(2.35, 0.98, -1.0), Color.WHITE)
	bar.material_override = grow_bar_mat
	grow_light = OmniLight3D.new()
	grow_light.light_color = Color(1.0, 0.5, 0.9)
	grow_light.omni_range = 1.6
	grow_light.position = Vector3(2.35, 0.9, -0.9)
	add_child(grow_light)
	# Oxygen tanks on a rack by the back wall: the oxygen machine fills them at night. Full tanks glow.
	_box(Vector3(0.62, 0.08, 0.2), Vector3(1.6, 0.04, -1.2), Color(0.42, 0.44, 0.52))
	for i in range(4):
		var tank := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.06
		cyl.bottom_radius = 0.06
		cyl.height = 0.52
		cyl.radial_segments = 10
		tank.mesh = cyl
		var tm := _glow_mat(TANK_ON, 0.9)
		tank.material_override = tm
		tank.position = Vector3(1.375 + 0.15 * float(i), 0.34, -1.2)
		add_child(tank)
		tank_mats.append(tm)
	# Room lights: they dim when power is low.
	for x in [-2.3, 0.2, 2.4]:
		var l := OmniLight3D.new()
		l.light_color = Color(1.0, 0.93, 0.80)
		l.omni_range = 3.6
		l.position = Vector3(x, 1.7, 0.4)
		add_child(l)
		room_lights.append(l)

func _build_shelter() -> void:
	# The storm shelter is the bunk corner. NASA's own example builds a shelter out of water bags and cargo.
	_prop(ST, "bed-single", Vector3(-2.95, 0, -0.2))
	_prop(ST, "bed-single", Vector3(-2.2, 0, -0.2))
	# The thin shelter the crew starts with.
	_prop(ST, "container", Vector3(-3.15, 0, -1.05))
	_prop(ST, "container", Vector3(-2.55, 0, -1.05))
	# Cargo and water added when the crew reinforces it.
	var adds := [
		["container-wide", Vector3(-1.95, 0, -1.05)],
		["container", Vector3(-3.15, 0.6, -1.05)],
		["container", Vector3(-2.55, 0.6, -1.05)],
		["container", Vector3(-1.95, 0.7, -1.05)],
		["container-tall", Vector3(-1.5, 0, -0.9)],
		["container-tall", Vector3(-1.5, 0, -0.3)],
		["container-wide", Vector3(-1.5, 0, 0.3)],
	]
	for a in adds:
		extra_shield.append(_prop(ST, a[0], a[1]))

func _build_power_yard() -> void:
	for i in range(4):
		var u := _prop(SK, "machine_generator", Vector3(UNIT_X[i], 0, -0.9), 0, 1.35)
		unit_nodes.append(u)
		var lamp := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.1
		sm.height = 0.2
		lamp.mesh = sm
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_color = COL_ON
		lamp.material_override = m
		lamp.position = Vector3(UNIT_X[i], 0.72, -0.9)
		add_child(lamp)
		unit_lamps.append(m)
		var mark := _icon_sprite(ICONS + "gears.svg", Color(1.0, 0.72, 0.2), 0.36)
		mark.position = Vector3(UNIT_X[i], 1.15, -0.9)
		mark.visible = false
		add_child(mark)
		unit_marks.append(mark)
	# Cable from the units to the room.
	_box(Vector3(5.0, 0.06, 0.08), Vector3(6.1, 0.03, -1.45), Color(0.18, 0.16, 0.18))
	_box(Vector3(0.08, 0.06, 0.6), Vector3(3.65, 0.03, -1.2), Color(0.18, 0.16, 0.18))

func _build_crew() -> void:
	_add_crew("eng", "astronautA", COL_ENG, "gears.svg", POINTS.eng_home)
	_add_crew("pro", "astronautB", COL_PRO, "energy-shield.svg", POINTS.pro_home)
	_add_tappable("eng", Vector3.ZERO, 70.0, crew.eng.node)
	_add_tappable("pro", Vector3.ZERO, 70.0, crew.pro.node)
	_add_tappable("power", Vector3(6.4, 0.5, -0.9), 150.0)
	_add_tappable("shelter", Vector3(-2.55, 0.5, -0.4), 130.0)
	_add_tappable("dish", Vector3(5.3, 1.0, -3.4), 90.0)
	# The spots a player taps to do the job, one visible change each.
	_add_tappable("stack1", Vector3(-2.55, 0.75, -1.05), 75.0)
	_add_tappable("stack2", Vector3(-1.5, 0.55, -0.6), 75.0)
	_add_tappable("stack3", Vector3(-1.5, 0.45, 0.3), 75.0)
	_add_tappable("fix1", Vector3.ZERO, 70.0)
	_add_tappable("fix2", Vector3.ZERO, 70.0)
	_add_tappable("fix3", Vector3.ZERO, 70.0)
	_add_tappable("greenhouse", Vector3(2.35, 0.75, -1.0), 10.0)   # only an arrow: "look here"
	_add_tappable("oxygen", Vector3(1.6, 0.72, -1.2), 10.0)        # only an arrow, too
	_add_tappable("power_look", Vector3(6.4, 0.95, -0.9), 10.0)
	_add_tappable("shelter_look", Vector3(-2.55, 0.95, -0.4), 10.0)
	_add_tappable("eng_console", Vector3(0.8, 0.45, -1.0), 80.0)
	_add_tappable("pro_console", Vector3(-0.55, 0.45, -1.0), 80.0)

func _add_crew(role: String, model: String, col: Color, icon: String, at: Vector3) -> void:
	var node := Node3D.new()
	node.position = at
	add_child(node)
	var body := Node3D.new()
	node.add_child(body)
	var suit := _prop(SK, model, Vector3.ZERO, 180, 0.95, body)
	tint(suit, "metalRed", col)
	# A ring on the floor shows which astronaut a player is steering.
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.27
	tm.outer_radius = 0.35
	ring.mesh = tm
	var rm := StandardMaterial3D.new()
	rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rm.albedo_color = col
	ring.material_override = rm
	ring.scale = Vector3(1, 0.12, 1)
	ring.position.y = 0.03
	ring.visible = false
	node.add_child(ring)
	# Role badge above the helmet (icons: game-icons.net, CC BY 3.0).
	var disc := MeshInstance3D.new()
	var qm := SphereMesh.new()
	qm.radius = 0.2
	qm.height = 0.4
	disc.mesh = qm
	var dm := StandardMaterial3D.new()
	dm.albedo_color = col
	dm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	disc.material_override = dm
	disc.position.y = 1.1
	node.add_child(disc)
	var s := _icon_sprite(ICONS + icon, Color(0.12, 0.10, 0.16), 0.3)
	s.position.y = 1.1
	node.add_child(s)
	var glow := OmniLight3D.new()
	glow.light_color = Color(1.0, 0.95, 0.88)
	glow.light_energy = 0.45
	glow.omni_range = 1.7
	glow.position = Vector3(0, 0.9, 0.9)
	node.add_child(glow)
	crew[role] = {"node": node, "body": body, "ring": ring, "phase": 0.0, "walking": false, "working": false, "moving": false, "yaw": 0.0}

func _add_tappable(id: String, pos: Vector3, radius: float, follow: Node3D = null) -> void:
	var marker := Sprite3D.new()
	marker.texture = load(UIPNG + "Yellow/Default/arrow_basic_s.png")
	marker.pixel_size = 0.012
	marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	marker.shaded = false
	marker.no_depth_test = true
	marker.render_priority = 3
	marker.visible = false
	add_child(marker)
	var back := Sprite3D.new()
	back.texture = marker.texture
	back.pixel_size = 0.0165
	back.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	back.shaded = false
	back.no_depth_test = true
	back.render_priority = 2
	back.modulate = Color(0.10, 0.08, 0.16)
	marker.add_child(back)
	tappables[id] = {"pos": pos, "radius": radius, "marker": marker, "follow": follow, "on": false, "silent": false}

func _build_goal_rings() -> void:
	for i in range(2):
		var ring := MeshInstance3D.new()
		var tm := TorusMesh.new()
		tm.inner_radius = 0.30
		tm.outer_radius = 0.40
		ring.mesh = tm
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_color = Color(1, 1, 1, 0.9)
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ring.material_override = m
		ring.scale = Vector3(1, 0.1, 1)
		ring.visible = false
		add_child(ring)
		goal_rings.append(ring)

func _build_storm_fx() -> void:
	# Solar particles are invisible in real life. We draw them so the storm can be seen.
	storm_fx = CPUParticles3D.new()
	storm_fx.amount = 130
	storm_fx.lifetime = 3.0
	storm_fx.preprocess = 3.0
	storm_fx.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	storm_fx.emission_box_extents = Vector3(11, 3.5, 5)
	storm_fx.direction = Vector3(-0.82, -0.57, 0.0)
	storm_fx.spread = 3.0
	storm_fx.gravity = Vector3.ZERO
	storm_fx.initial_velocity_min = 1.6
	storm_fx.initial_velocity_max = 2.4
	storm_fx.scale_amount_min = 0.6
	storm_fx.scale_amount_max = 1.3
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.25, 0.75, 1.0])
	ramp.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 1), Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	storm_fx.color_ramp = ramp
	var dot_grad := Gradient.new()
	dot_grad.offsets = PackedFloat32Array([0.0, 0.35, 1.0])
	dot_grad.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.55), Color(1, 1, 1, 0)])
	var dot := GradientTexture2D.new()
	dot.gradient = dot_grad
	dot.fill = GradientTexture2D.FILL_RADIAL
	dot.fill_from = Vector2(0.5, 0.5)
	dot.fill_to = Vector2(1.0, 0.5)
	dot.width = 64
	dot.height = 64
	var qm := QuadMesh.new()
	qm.size = Vector2(0.2, 0.2)
	var pm := StandardMaterial3D.new()
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pm.albedo_color = Color(1.0, 0.86, 0.45, 0.9)
	pm.albedo_texture = dot
	pm.vertex_color_use_as_albedo = true
	pm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	pm.disable_fog = true
	qm.material = pm
	storm_fx.mesh = qm
	storm_fx.position = Vector3(3.0, 4.2, -1.0)
	storm_fx.emitting = false
	add_child(storm_fx)

func _build_camera() -> void:
	cam = Camera3D.new()
	cam.far = 400.0
	cam.fov = 32.0
	add_child(cam)
	cam.position = Vector3(2.2, 5.4, 14.5)
	cam.look_at(Vector3(2.9, 0.3, 0.0), Vector3.UP)
	cam.current = true

# ---------------------------------------------------------------- state the game can set

func reset_scene() -> void:
	set_units_online(4)
	set_shelter_reinforced(false)
	set_room_power(1.0, false)
	set_mood("day", false)
	set_storm(false)
	place("eng", "eng_home")
	place("pro", "pro_home")
	set_goals([])
	for sp in sprouts:
		sp.visible = true
		sp.material_override = leaf
	set_plants("normal", false)

## How many of the four oxygen tanks are full.
func set_tanks(n: int) -> void:
	for i in range(4):
		var on: bool = i < n
		tank_mats[i].albedo_color = TANK_ON if on else TANK_OFF
		tank_mats[i].emission_enabled = on

## Harvest day: each plant is "ready" (tall and green), "small" (pale: it missed its light) or "gone" (picked).
func set_harvest(states: Array) -> void:
	for i in range(sprouts.size()):
		var sp: MeshInstance3D = sprouts[i]
		var st: String = states[i]
		var h: float = (sp.mesh as CylinderMesh).height
		var grow: float = 1.75 if st == "ready" else 0.7
		var m: StandardMaterial3D = leaf.duplicate()
		m.albedo_color = PLANT_COL.strong if st == "ready" else PLANT_COL.weak
		sp.material_override = m
		sp.visible = st != "gone"
		sp.scale = Vector3(grow * 0.8, grow, grow * 0.8) if st == "ready" else Vector3(1.0, grow, 1.0)
		sp.position.y = 0.46 + h * grow * 0.5
		sp.rotation.z = 0.0 if st == "ready" else (0.45 if i % 2 == 0 else -0.45)

## How many of the four power units are working (their lamps glow green).
func set_units_online(n: int) -> void:
	for i in range(4):
		_set_unit(i, i < n)

func _set_unit(i: int, on: bool) -> void:
	unit_on[i] = on
	unit_lamps[i].albedo_color = COL_ON if on else COL_OFF
	unit_nodes[i].rotation_degrees.z = 0.0 if on else 5.0
	unit_marks[i].visible = not on

func _wait(sec: float) -> void:
	if reduced_motion:
		return
	await get_tree().create_timer(sec).timeout

## Engineering repairs the broken units one by one. Use with await.
func repair_units() -> void:
	crew.eng.working = true
	for i in range(4):
		if unit_on[i]:
			continue
		await _wait(1.0)
		_set_unit(i, true)
	await _wait(0.5)
	crew.eng.working = false

## Protection stacks water and cargo around the shelter. Use with await.
func reinforce_shelter() -> void:
	shelter_reinforced = true
	for role in crew:
		var at: Vector3 = crew[role].node.position
		if NOOK_FREE.has_point(Vector2(at.x, at.z)):
			await walk(role, role + "_home")   # step out of the way of the cargo
	crew.pro.working = true
	for n in extra_shield:
		n.visible = true
		if not reduced_motion:
			n.scale = Vector3.ONE * 0.05
			create_tween().tween_property(n, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await _wait(0.35)
	await _wait(0.3)
	crew.pro.working = false

## The greenhouse the next morning: "weak" (the lamp was off: small, pale, drooping plants),
## "strong" (the lamp was on: tall green plants) or "normal" (the start of the sol).
func set_plants(mode: String, animate := true) -> void:
	var grow: float = {"normal": 1.0, "weak": 0.7, "strong": 1.75}[mode]
	var dur := 1.8 if (animate and not reduced_motion) else 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(leaf, "albedo_color", PLANT_COL[mode], dur)
	for i in range(sprouts.size()):
		var sp: MeshInstance3D = sprouts[i]
		var h: float = (sp.mesh as CylinderMesh).height
		tw.tween_property(sp, "scale", Vector3(1.0 if mode == "weak" else grow * 0.8, grow, 1.0 if mode == "weak" else grow * 0.8), dur)
		tw.tween_property(sp, "position:y", 0.46 + h * grow * 0.5, dur)
		tw.tween_property(sp, "rotation:z", (0.45 if i % 2 == 0 else -0.45) if mode == "weak" else 0.0, dur)

## One tap of the shelter job: a few pieces of cargo pop into place. step is 0, 1 or 2.
func reinforce_step(step: int) -> void:
	shelter_reinforced = true
	var groups: Array = [[0, 1, 2], [3, 4], [5, 6]]
	for i in groups[step]:
		var n: Node3D = extra_shield[i]
		n.visible = true
		if not reduced_motion:
			n.scale = Vector3.ONE * 0.05
			create_tween().tween_property(n, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await _wait(0.18)

## Puts the three repair arrows over the unit the crew will fix.
func set_fix_unit(unit: int) -> void:
	var offs := [Vector3(-0.3, 0.55, 0.35), Vector3(0.0, 0.85, 0.0), Vector3(0.3, 0.55, 0.35)]
	for i in range(3):
		tappables["fix%d" % (i + 1)].pos = Vector3(UNIT_X[unit], 0, -0.9) + offs[i]

## One tap of the power job. The unit shakes back into shape; on the third tap it comes back on.
func repair_step(unit: int, step: int) -> void:
	if step == 2:
		_set_unit(unit, true)
	if not reduced_motion:
		var n: Node3D = unit_nodes[unit]
		n.scale = Vector3.ONE * 1.35 * 0.88
		create_tween().tween_property(n, "scale", Vector3.ONE * 1.35, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await _wait(0.3)

## A crew member looks busy for a moment.
func work(role: String, sec: float) -> void:
	crew[role].working = true
	await _wait(sec)
	crew[role].working = false

## White rings on the floor show where to walk next.
func set_goals(points: Array) -> void:
	for i in range(goal_rings.size()):
		var ring: MeshInstance3D = goal_rings[i]
		ring.visible = i < points.size()
		if ring.visible:
			ring.position = POINTS[points[i]] + Vector3(0, 0.035, 0)

## A message leaves the antenna for Earth. Use with await.
func send_message() -> void:
	var dot := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.16
	sm.height = 0.32
	dot.mesh = sm
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = Color(0.65, 0.92, 1.0)
	m.disable_fog = true
	dot.material_override = m
	dot.position = Vector3(5.3, 1.7, -3.6)
	add_child(dot)
	if not reduced_motion:
		var tw := create_tween()
		tw.tween_property(dot, "position", Vector3(1.5, 7.5, -9.0), 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await tw.finished
	dot.queue_free()

## Two crew members walk at the same time. Use with await.
func walk_both(r1: String, p1: String, r2: String, p2: String) -> void:
	walk(r1, p1)
	await walk(r2, p2)
	while crew[r1].walking:
		await get_tree().process_frame

func set_shelter_reinforced(on: bool) -> void:
	shelter_reinforced = on
	for n in extra_shield:
		n.visible = on
		n.scale = Vector3.ONE

## 1.0 = everything on. With any power unit off the grow lamp goes off and the room lights dim.
func set_room_power(frac: float, animate := true) -> void:
	_power_frac = frac
	# In daylight the open room is already lit by the sun, so the lamps count for less.
	var day_k: float = 1.0 if _mood_name == "night" else 0.3
	var room_e: float = lerp(0.06, 0.95, clamp((frac - 0.5) / 0.5, 0.0, 1.0)) * day_k
	var grow_on: bool = frac >= 0.99   # with any unit off, the greenhouse lamp is the first thing switched off
	var dur := 1.5 if (animate and not reduced_motion) else 0.0
	var tw := create_tween().set_parallel(true)
	for l in room_lights:
		tw.tween_property(l, "light_energy", room_e, dur)
	tw.tween_property(grow_light, "light_energy", 0.8 if grow_on else 0.0, dur)
	tw.tween_property(grow_bar_mat, "emission_energy_multiplier", 1.0 if grow_on else 0.0, dur)
	tw.tween_property(grow_bar_mat, "albedo_color", Color(1.0, 0.45, 0.9) if grow_on else Color(0.25, 0.2, 0.25), dur)

## "day", "storm" or "night". Slow fades only: nothing flashes.
func set_mood(mood: String, animate := true) -> void:
	var m: Dictionary = {
		"day": {"sky": Color(0.80, 0.62, 0.48), "amb": Color(0.95, 0.78, 0.66), "amb_e": 0.42, "sun": Color(1.0, 0.90, 0.78), "sun_e": 0.85, "fill_e": 0.18, "fog": Color(0.86, 0.63, 0.46), "back": Color(1, 1, 1)},
		"storm": {"sky": Color(0.60, 0.42, 0.44), "amb": Color(0.86, 0.64, 0.64), "amb_e": 0.40, "sun": Color(1.0, 0.78, 0.6), "sun_e": 0.6, "fill_e": 0.15, "fog": Color(0.70, 0.48, 0.44), "back": Color(0.8, 0.68, 0.68)},
		"night": {"sky": Color(0.10, 0.09, 0.17), "amb": Color(0.46, 0.48, 0.72), "amb_e": 0.42, "sun": Color(0.55, 0.62, 1.0), "sun_e": 0.18, "fill_e": 0.05, "fog": Color(0.12, 0.10, 0.18), "back": Color(0.20, 0.18, 0.28)},
	}[mood]
	var dur := 2.0 if (animate and not reduced_motion) else 0.0
	_mood_name = mood
	set_room_power(_power_frac, animate)
	if _mood != null and _mood.is_valid():
		_mood.kill()
	_mood = create_tween().set_parallel(true)
	_mood.tween_property(env, "background_color", m.sky, dur)
	_mood.tween_property(env, "ambient_light_color", m.amb, dur)
	_mood.tween_property(env, "ambient_light_energy", m.amb_e, dur)
	_mood.tween_property(env, "fog_light_color", m.fog, dur)
	_mood.tween_property(sun, "light_color", m.sun, dur)
	_mood.tween_property(sun, "light_energy", m.sun_e, dur)
	_mood.tween_property(fill, "light_energy", m.fill_e, dur)
	_mood.tween_property(backdrop_mat, "albedo_color", m.back, dur)
	fill.light_color = Color(0.75, 0.80, 1.0)

func set_storm(on: bool) -> void:
	storm_fx.emitting = on
	storm_fx.visible = on

## Which things can be tapped. `marked` ones show a yellow arrow; `silent` ones can be tapped but show nothing.
func set_tappable(marked: Array, silent: Array = []) -> void:
	for id in tappables:
		tappables[id].on = marked.has(id)
		tappables[id].silent = silent.has(id)
		tappables[id].marker.visible = marked.has(id)

## Who steers which astronaut: {"eng": "wasd", "pro": "arrows"}, {"eng": "both"} or {}.
func set_controls(map: Dictionary) -> void:
	controls = map
	for role in crew:
		crew[role].ring.visible = map.has(role)

## Distance on the floor between an astronaut and a named point.
func dist(role: String, point: String) -> float:
	var a: Vector3 = crew[role].node.position
	var b: Vector3 = POINTS[point]
	return Vector2(a.x - b.x, a.z - b.z).length()

func prop(base: String, mname: String, pos: Vector3, yaw_deg: float, scl: float, parent: Node3D) -> Node3D:
	return _prop(base, mname, pos, yaw_deg, scl, parent)

## Recolours every surface that uses the named material (the kits name theirs: "metalRed" is the suit accent).
func tint(n: Node, mat_name: String, col: Color) -> void:
	var meshes: Array = n.find_children("*", "MeshInstance3D", true, false)
	if n is MeshInstance3D:
		meshes.append(n)
	for c in meshes:
		var mi := c as MeshInstance3D
		if mi.mesh == null:
			continue
		for i in range(mi.mesh.get_surface_count()):
			var m = mi.mesh.surface_get_material(i)
			if m is BaseMaterial3D and m.resource_name == mat_name:
				var d: BaseMaterial3D = m.duplicate()
				d.albedo_color = col
				mi.set_surface_override_material(i, d)

func place(role: String, point: String) -> void:
	var c: Dictionary = crew[role]
	c.node.position = POINTS[point]
	c.walking = false
	c.working = false
	c.yaw = 0.0

## Walks a crew member to a named point. Use with await.
func walk(role: String, point: String) -> void:
	var c: Dictionary = crew[role]
	var node: Node3D = c.node
	var to: Vector3 = POINTS[point]
	if reduced_motion:
		node.position = to
		return
	c.walking = true
	for p in _path(node.position, to):
		var d: float = node.position.distance_to(p)
		if d < 0.02:
			continue
		c.yaw = atan2(p.x - node.position.x, p.z - node.position.z)
		var tw := create_tween()
		tw.tween_property(node, "position", p, d / WALK_SPEED)
		await tw.finished
	c.walking = false
	c.yaw = 0.0

func _path(from: Vector3, to: Vector3) -> Array:
	var pts: Array = []
	var a_out: bool = from.x > DOOR_X
	var b_out: bool = to.x > DOOR_X
	var a_nook: bool = from.x < NOOK_X
	var b_nook: bool = to.x < NOOK_X
	var a_back: bool = a_out and from.z < -0.25
	var b_back: bool = b_out and to.z < -0.25
	# Behind the power units the only way is the path beside them.
	if a_back and not (b_back and absf(from.x - to.x) < 2.6):
		pts.append(Vector3(4.05, 0, from.z))
		pts.append(Vector3(4.05, 0, 0.0))
	if a_nook and not b_nook:
		pts.append(POINTS.nook_gate)
	if a_out != b_out:
		pts.append(POINTS.door_out if a_out else POINTS.door_in)
		pts.append(POINTS.door_in if a_out else POINTS.door_out)
	if b_back and not a_back:
		pts.append(Vector3(4.05, 0, 0.0))
		pts.append(Vector3(4.05, 0, to.z))
	if b_nook and not a_nook:
		pts.append(POINTS.nook_gate)
	pts.append(to)
	return pts

func _walkable(x: float, z: float) -> bool:
	# The floor beside the bunks is free until the crew stacks cargo there.
	if not shelter_reinforced and NOOK_FREE.has_point(Vector2(x, z)):
		return true
	for r in WALK:
		if (r as Rect2).has_point(Vector2(x, z)):
			return true
	return false

func _move_input(scheme: String) -> Vector2:
	var v := Vector2.ZERO
	if scheme == "wasd" or scheme == "both":
		v.x += float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A))
		v.y += float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
	if scheme == "arrows" or scheme == "both":
		v.x += float(Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_LEFT))
		v.y += float(Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_UP))
	return v.limit_length(1.0)

## A player steers an astronaut with the keyboard. Walls and furniture stop it (see WALK).
func _steer(c: Dictionary, scheme: String, dt: float) -> void:
	var v := _move_input(scheme)
	if v == Vector2.ZERO:
		return
	var node: Node3D = c.node
	var nx: float = node.position.x + v.x * MOVE_SPEED * dt
	var nz: float = node.position.z + v.y * MOVE_SPEED * dt
	if _walkable(nx, nz):
		node.position.x = nx
		node.position.z = nz
	elif _walkable(nx, node.position.z):
		node.position.x = nx
	elif _walkable(node.position.x, nz):
		node.position.z = nz
	c.yaw = atan2(v.x, v.y)
	c.moving = true

# ---------------------------------------------------------------- per-frame motion and taps

func _process(dt: float) -> void:
	_t += dt
	for role in crew:
		var c: Dictionary = crew[role]
		var body: Node3D = c.body
		c.moving = false
		var scheme: String = controls.get(role, "")
		if scheme != "" and not c.walking and not c.working:
			_steer(c, scheme, dt)
		if (c.walking or c.moving) and not reduced_motion:
			c.phase += dt * 9.0
			body.position.y = abs(sin(c.phase)) * 0.07
			body.rotation.z = sin(c.phase) * 0.13
		elif c.working and not reduced_motion:
			c.phase += dt * 11.0
			body.position.y = abs(sin(c.phase)) * 0.035
			body.rotation.z = sin(c.phase * 0.5) * 0.05
		else:
			body.position.y = lerp(body.position.y, 0.0, min(dt * 10.0, 1.0))
			body.rotation.z = lerp(body.rotation.z, 0.0, min(dt * 10.0, 1.0))
		body.rotation.y = lerp_angle(body.rotation.y, c.yaw, min(dt * 8.0, 1.0))
	if not reduced_motion:
		var k: float = 1.0 + sin(_t * 2.2) * 0.08
		for ring in goal_rings:
			ring.scale = Vector3(k, 0.1, k)
	for id in tappables:
		var t: Dictionary = tappables[id]
		if not t.on:
			continue
		var p: Vector3 = _tap_pos(t)
		var bob := 0.0 if reduced_motion else sin(_t * 2.6) * 0.06
		t.marker.position = p + Vector3(0, 0.55 + bob, 0)

func _tap_pos(t: Dictionary) -> Vector3:
	if t.follow != null:
		return (t.follow as Node3D).position + Vector3(0, 0.95, 0)
	return t.pos

func _unhandled_input(e: InputEvent) -> void:
	if not (e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT):
		return
	var k: float = get_viewport().get_visible_rect().size.y / 900.0
	var best := ""
	var best_d := 1e9
	for id in tappables:
		var t: Dictionary = tappables[id]
		if not (t.on or t.silent):
			continue
		var wp: Vector3 = _tap_pos(t) - (Vector3(0, 0.45, 0) if t.follow != null else Vector3.ZERO)
		var sp: Vector2 = cam.unproject_position(wp)
		var d: float = sp.distance_to(e.position)
		if d < t.radius * k and d < best_d:
			best = id
			best_d = d
	if best != "":
		get_viewport().set_input_as_handled()
		tapped.emit(best)
