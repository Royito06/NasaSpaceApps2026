extends Node3D
## Deep space: the title screen (Earth drifts into view) and the mission select
## (the Moon, Mars, and worlds still to come). Everything is simple shapes built in code.

signal tapped(id: String)

const World := preload("res://world.gd")
const SLOTS := ["moon", "mars", "asteroid", "more"]
const CAM_DIST := 10.0
const CAM_FOV := 40.0
const EARTH_TITLE := Vector3(3.9, -1.5, 0.0)
const EARTH_AWAY := Vector3(9.5, -6.5, -3.0)

var helper: Node3D           # the Mars scene, used only for its model loader
var cam: Camera3D
var earth: Node3D
var worlds := {}             # id -> {node: Node3D, mats: Array of [material, base colour]}
var mode := ""
var open_ids: Array = []     # the worlds that can be tapped
var reduced_motion := false
var rocket: Node3D
var flame: MeshInstance3D
var travel := 0.0            # the trip from the Moon to Mars: 0 at the Moon, 1 at Mars
const TRAVEL_SECS := 11.0
var _t := 0.0
var _fly: Tween

func _ready() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.012, 0.012, 0.035)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.60, 0.80)
	env.ambient_light_energy = 0.3
	cam = Camera3D.new()
	cam.environment = env
	cam.fov = CAM_FOV
	cam.far = 300.0
	add_child(cam)
	cam.position = Vector3(0, 0, CAM_DIST)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-18, 42, 0)
	sun.light_energy = 1.25
	add_child(sun)
	_build_stars()
	_build_earth()
	_build_worlds()
	_build_rocket()

func _mat(col: Color, unshaded := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = 1.0
	if unshaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m

func _ball(radius: float, m: StandardMaterial3D, parent: Node3D) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = radius
	sm.height = radius * 2.0
	sm.radial_segments = 32
	sm.rings = 16
	mi.mesh = sm
	mi.material_override = m
	parent.add_child(mi)
	return mi

## A flat patch lying on a ball's surface: land, cloud, crater or dark plain.
func _patch(parent: Node3D, ball_r: float, lat: float, lon: float, size: float, m: StandardMaterial3D) -> void:
	var dir := Vector3(cos(lat) * sin(lon), sin(lat), cos(lat) * cos(lon))
	var mi := _ball(1.0, m, parent)
	var up := Vector3.UP if absf(dir.y) < 0.95 else Vector3.RIGHT
	mi.transform = Transform3D(Basis.looking_at(-dir, up) * Basis.from_scale(Vector3(size, size, size * 0.35)), dir * (ball_r - size * 0.22))

func _build_stars() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	var qm := QuadMesh.new()
	qm.size = Vector2(0.16, 0.16)
	var sm := _mat(Color(0.92, 0.94, 1.0), true)
	sm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	qm.material = sm
	mm.mesh = qm
	mm.instance_count = 340
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026
	for i in range(mm.instance_count):
		var s: float = rng.randf_range(0.35, 1.5)
		var at := Vector3(rng.randf_range(-70, 70), rng.randf_range(-40, 40), rng.randf_range(-75, -30))
		mm.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ONE * s), at))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	add_child(mmi)

func _build_earth() -> void:
	earth = Node3D.new()
	add_child(earth)
	var spin := Node3D.new()
	spin.name = "Spin"
	earth.add_child(spin)
	_ball(2.7, _mat(Color(0.20, 0.45, 0.92)), spin)
	var land := _mat(Color(0.30, 0.68, 0.36))
	var cloud := _mat(Color(0.95, 0.97, 1.0))
	var lands := [[0.5, 0.2, 0.9], [0.1, 0.9, 0.75], [-0.4, 0.5, 0.6], [0.3, 2.4, 1.0], [-0.2, 3.3, 0.8], [0.7, 4.2, 0.6], [-0.6, 5.2, 0.7], [0.0, 5.6, 0.5]]
	for l in lands:
		_patch(spin, 2.7, l[0], l[1], l[2], land)
	var clouds := [[0.8, 1.2, 0.5], [-0.1, 1.7, 0.45], [0.35, 3.0, 0.4], [-0.7, 2.2, 0.5], [0.15, 4.8, 0.45]]
	for c in clouds:
		_patch(spin, 2.74, c[0], c[1], c[2], cloud)
	earth.position = EARTH_AWAY

func _add_world(id: String, node: Node3D, mats: Array) -> void:
	node.visible = false
	add_child(node)
	var list: Array = []
	for m in mats:
		list.append([m, (m as StandardMaterial3D).albedo_color])
	worlds[id] = {"node": node, "mats": list}

func _build_worlds() -> void:
	# The Moon: grey, with darker plains and craters.
	var moon := Node3D.new()
	var m_grey := _mat(Color(0.74, 0.74, 0.78))
	var m_dark := _mat(Color(0.52, 0.52, 0.57))
	_ball(1.0, m_grey, moon)
	for p in [[0.4, 0.3, 0.42], [-0.2, 1.0, 0.3], [0.1, 5.6, 0.36], [-0.6, 0.0, 0.25], [0.7, 5.0, 0.22], [0.0, 2.6, 0.4], [0.5, 3.6, 0.3]]:
		_patch(moon, 1.0, p[0], p[1], p[2], m_dark)
	_add_world("moon", moon, [m_grey, m_dark])
	# Mars: rust red, darker regions and a white polar cap.
	var mars := Node3D.new()
	var m_rust := _mat(Color(0.82, 0.40, 0.22))
	var m_shade := _mat(Color(0.56, 0.26, 0.16))
	var m_cap := _mat(Color(0.96, 0.95, 0.94))
	_ball(1.15, m_rust, mars)
	for p in [[0.2, 0.4, 0.5], [-0.3, 1.3, 0.4], [0.1, 5.4, 0.45], [-0.5, 4.4, 0.35], [0.4, 2.8, 0.4]]:
		_patch(mars, 1.15, p[0], p[1], p[2], m_shade)
	_patch(mars, 1.15, 1.35, 0.3, 0.34, m_cap)
	_add_world("mars", mars, [m_rust, m_shade, m_cap])
	# An asteroid: a tumbling rock from the kit.
	var rock := Node3D.new()
	var m_rock := _mat(Color(0.58, 0.55, 0.52))
	var r: Node3D = helper.prop(World.SK, "rock_largeA", Vector3(0, -0.55, 0), 0.0, 2.3, rock)
	for c in r.find_children("*", "MeshInstance3D", true, false):
		(c as MeshInstance3D).material_override = m_rock
	_add_world("asteroid", rock, [m_rock])
	# More worlds: a ringed planet.
	var more := Node3D.new()
	var m_tan := _mat(Color(0.88, 0.74, 0.50))
	var m_ring := _mat(Color(0.78, 0.70, 0.60))
	_ball(0.85, m_tan, more)
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 1.15
	tm.outer_radius = 1.65
	tm.rings = 48
	ring.mesh = tm
	ring.material_override = m_ring
	ring.scale = Vector3(1, 0.05, 1)
	ring.rotation_degrees = Vector3(18, 0, 12)
	more.add_child(ring)
	_add_world("more", more, [m_tan, m_ring])

## A small rocket made of simple shapes, nose up. It carries the story from the Moon to Mars.
func _build_rocket() -> void:
	rocket = Node3D.new()
	rocket.visible = false
	add_child(rocket)
	var white := _mat(Color(0.95, 0.95, 0.98))
	var red := _mat(Color(0.92, 0.30, 0.22))
	var body := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.17
	cyl.bottom_radius = 0.17
	cyl.height = 0.72
	cyl.radial_segments = 16
	body.mesh = cyl
	body.material_override = white
	rocket.add_child(body)
	var nose := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.17
	cone.height = 0.34
	cone.radial_segments = 16
	nose.mesh = cone
	nose.material_override = red
	nose.position.y = 0.53
	rocket.add_child(nose)
	for i in range(3):
		var fin := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.05, 0.3, 0.26)
		fin.mesh = bm
		fin.material_override = red
		var a := TAU * float(i) / 3.0
		fin.position = Vector3(sin(a) * 0.2, -0.3, cos(a) * 0.2)
		fin.rotation.y = a
		rocket.add_child(fin)
	var win := _ball(0.075, _mat(Color(0.35, 0.75, 1.0)), rocket)
	win.position = Vector3(0, 0.14, 0.15)
	flame = MeshInstance3D.new()
	var fc := CylinderMesh.new()
	fc.top_radius = 0.12
	fc.bottom_radius = 0.0
	fc.height = 0.42
	fc.radial_segments = 12
	flame.mesh = fc
	flame.material_override = _mat(Color(1.0, 0.72, 0.25), true)
	flame.position.y = -0.57
	rocket.add_child(flame)

# ---------------------------------------------------------------- state the game can set

## "title": Earth drifts into view. "select": the worlds line up. Anything else hides them.
func set_mode(new_mode: String, open: Array, locked: Array) -> void:
	open_ids = open
	for id in worlds:
		worlds[id].node.visible = new_mode == "select" or (new_mode == "travel" and (id == "moon" or id == "mars"))
		for pair in worlds[id].mats:
			(pair[0] as StandardMaterial3D).albedo_color = (pair[1] as Color) * (0.3 if locked.has(id) else 1.0)
	if new_mode == mode:
		return
	mode = new_mode
	rocket.visible = mode == "travel"
	if mode == "travel":
		travel = 0.0
		for id in ["moon", "mars"]:
			worlds[id].node.rotation = Vector3.ZERO
	if _fly != null and _fly.is_valid():
		_fly.kill()
	if mode == "title":
		earth.scale = Vector3.ONE
		if reduced_motion:
			earth.position = EARTH_TITLE
		else:
			earth.position = EARTH_AWAY
			_fly = create_tween()
			_fly.tween_property(earth, "position", EARTH_TITLE, 3.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	elif mode == "select":
		# Earth stays in a corner: home, where the missions start.
		earth.scale = Vector3.ONE * 0.26
		earth.position = Vector3(-_half_width() + 1.0, 2.85, -1.0)

func _half_width() -> float:
	var size: Vector2 = get_viewport().get_visible_rect().size
	return CAM_DIST * tan(deg_to_rad(CAM_FOV * 0.5)) * size.x / max(size.y, 1.0)

func _process(dt: float) -> void:
	_t += dt
	if not visible:
		return
	if not reduced_motion:
		earth.get_node("Spin").rotation.y += dt * 0.12
	if mode == "travel":
		_travel_step(dt)
		return
	if mode != "select":
		return
	# The worlds sit above the four columns of the menu, whatever the window's shape.
	var w := _half_width() * 2.0
	for i in range(SLOTS.size()):
		var n: Node3D = worlds[SLOTS[i]].node
		n.scale = Vector3.ONE * 0.82
		n.position = Vector3((-0.375 + 0.25 * i) * w, -0.15 + (0.0 if reduced_motion else sin(_t * 0.8 + i * 1.3) * 0.06), 0.0)
		if not reduced_motion:
			n.rotation.y += dt * (0.5 if SLOTS[i] == "asteroid" else 0.2)
			if SLOTS[i] == "asteroid":
				n.rotation.x += dt * 0.3

## The trip: the rocket leaves the Moon, Earth and the Moon shrink behind it, and Mars grows ahead.
## Sizes and distances are not to scale. It is slow and smooth, and with less motion it shows the arrival only.
func _travel_step(dt: float) -> void:
	travel = 1.0 if reduced_motion else minf(travel + dt / TRAVEL_SECS, 1.0)
	var k: float = travel * travel * (3.0 - 2.0 * travel)   # ease in and out
	var w: float = _half_width()
	earth.scale = Vector3.ONE * lerpf(0.5, 0.09, k)
	earth.position = Vector3(lerpf(-0.70, -0.86, k) * w, lerpf(0.5, 1.5, k), 0.0)
	var moon_n: Node3D = worlds.moon.node
	moon_n.scale = Vector3.ONE * lerpf(0.42, 0.055, k)
	moon_n.position = earth.position + Vector3(lerpf(2.3, 0.42, k), lerpf(1.0, 0.2, k), 0.0)
	var mars_n: Node3D = worlds.mars.node
	mars_n.scale = Vector3.ONE * lerpf(0.16, 1.45, k)
	mars_n.position = Vector3(lerpf(0.86, 0.66, k) * w, lerpf(1.3, 0.9, k), 0.0)
	if not reduced_motion:
		mars_n.rotation.y += dt * 0.15
	# The rocket flies a gentle arc from the Moon to just short of Mars, nose first.
	var from := Vector3(-0.70 * w + 2.3 + 0.55, 1.6, 0.4)
	var to := Vector3(0.66 * w - 2.85, 1.1, 0.4)
	var at: Vector3 = from.lerp(to, k) + Vector3(0, sin(PI * k) * 0.55, 0)
	var ahead: Vector3 = from.lerp(to, minf(k + 0.02, 1.0)) + Vector3(0, sin(PI * minf(k + 0.02, 1.0)) * 0.55, 0)
	rocket.position = at
	var dir: Vector3 = ahead - at
	rocket.rotation = Vector3(0, 0, (atan2(dir.y, dir.x) if dir.length() > 0.0001 else 0.0) - PI * 0.5)
	rocket.scale = Vector3.ONE * 1.25
	flame.visible = travel < 1.0
	flame.scale = Vector3(1.0, 1.0 + (0.0 if reduced_motion else sin(_t * 7.0) * 0.14), 1.0)   # a slow flicker, about once a second

func _unhandled_input(e: InputEvent) -> void:
	if not visible or mode != "select" or not (e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT):
		return
	var k: float = get_viewport().get_visible_rect().size.y / 900.0
	for id in open_ids:
		var n: Node3D = worlds[id].node
		if cam.unproject_position(n.position).distance_to(e.position) < 130.0 * k:
			get_viewport().set_input_as_handled()
			tapped.emit(id)
			return
