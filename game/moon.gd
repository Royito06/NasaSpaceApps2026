extends Node3D
## Level 1: the Moon. A lander, a rover the players drive, two rock sites and the walk-back circle.
## Inspired by Apollo 15 (1971), the first mission with a lunar rover. Built in code like the Mars scene:
## kit models where they exist, simple shapes for the rover. Runs on the Compatibility renderer.

signal tapped(id: String)

const World := preload("res://world.gd")
const UIPNG := "res://assets/kenney_ui/PNG/"
const ROCK := Color(0.50, 0.50, 0.54)
const LANDER_AT := Vector3(-3.0, 0, -1.0)
const WALKBACK_R := 12.2     # the walk-back line: 5 km from the lander, the farthest Apollo 15 drove (scene units)
const DRIVE_SPEED := 3.0     # calm: units per second
const BOUNDS := Rect2(-4.0, -3.2, 14.2, 5.6)   # where the rover may drive (x, z, width, depth)
const POINTS := {
	"lander": Vector3(-1.5, 0, 0.5),   # where the rover parks
	"near": Vector3(2.3, 0, -1.4),     # the close rock site, inside the circle
	"far": Vector3(8.4, 0, 0.9),       # the far rock site, outside the circle
}
const SITE_ROCK := {"near": Vector3(2.5, 0, -2.3), "far": Vector3(8.7, 0, 0.0)}
# Five loose rocks lie in front of each site. The crew's bag holds three: which ones is up to the players.
const ROCK_OFFSETS := [Vector3(-1.6, 0, 0.7), Vector3(-1.1, 0, 1.3), Vector3(-0.4, 0, 1.6), Vector3(0.3, 0, 1.5), Vector3(0.8, 0, 0.9)]
const ROCK_KINDS := {"near": ["grey", "grey", "dark", "grey", "dark"], "far": ["grey", "dark", "white", "grey", "dark"]}
const ROCK_COL := {"grey": Color(0.50, 0.50, 0.54), "dark": Color(0.27, 0.27, 0.31), "white": Color(0.96, 0.96, 0.99)}

var helper: Node3D           # the Mars scene, used only for its model loader
var cam: Camera3D
var rover: Node3D
var crew_bob: Node3D
var dust: CPUParticles3D
var tray: Node3D
var walk_ring: MeshInstance3D
var goal_rings: Array[MeshInstance3D] = []
var tappables := {}          # id -> {pos, radius, marker, on}
var rocks: Array = []        # the loose rocks at the current site: {node, kind}
var stand: Array[Node3D] = []   # two astronauts on foot: one on the lander's ladder, one on the ground
var stand_base: Array[Vector3] = [Vector3(-2.0, 0.55, 0.15), Vector3(-0.35, 0.0, 1.45)]
var tape: MeshInstance3D
var hammer: Node3D
var feather: Node3D
var _dep_a := false
var _dep_b := false
var drive_on := false
var reduced_motion := false
var _t := 0.0
var _hop := 0.0

func _ready() -> void:
	_build_sky_and_light()
	_build_ground()
	_build_sites()
	_build_rover()
	_build_deploy_and_drop()
	_build_markers()
	reset_scene()

# ---------------------------------------------------------------- helpers

func _mat(col: Color, unshaded := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = 1.0
	if unshaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m

func _shape(mesh: Mesh, col: Color, pos: Vector3, parent: Node3D = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = _mat(col)
	mi.position = pos
	(parent if parent != null else self).add_child(mi)
	return mi

func _box(size: Vector3, col: Color, pos: Vector3, parent: Node3D = null) -> MeshInstance3D:
	var bm := BoxMesh.new()
	bm.size = size
	return _shape(bm, col, pos, parent)

## A kit model, recoloured to moon grey (the kits are tinted for Mars).
func _moon_prop(base: String, mname: String, pos: Vector3, yaw: float, scl: float, col: Color = ROCK) -> Node3D:
	var n: Node3D = helper.prop(base, mname, pos, yaw, scl, self)
	var m := _mat(col)
	for c in n.find_children("*", "MeshInstance3D", true, false):
		(c as MeshInstance3D).material_override = m
	return n

# ---------------------------------------------------------------- scene

func _build_sky_and_light() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.015, 0.015, 0.03)     # no air: the sky is black even by day
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.66, 0.78)
	env.ambient_light_energy = 0.38
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	cam = Camera3D.new()
	cam.environment = env
	cam.far = 400.0
	cam.fov = 32.0
	add_child(cam)
	cam.look_at_from_position(Vector3(2.2, 5.4, 14.5), Vector3(2.9, 0.3, 0.0), Vector3.UP)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-34, -62, 0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 40.0
	add_child(sun)
	# Earth, low over the horizon: close enough to answer in seconds.
	var earth := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 2.0
	sm.height = 4.0
	earth.mesh = sm
	earth.material_override = _mat(Color(0.26, 0.50, 0.95), true)
	earth.position = Vector3(-8.0, -1.3, -62.0)
	add_child(earth)
	var cloud := MeshInstance3D.new()
	var cm := SphereMesh.new()
	cm.radius = 1.2
	cm.height = 0.9
	cloud.mesh = cm
	cloud.material_override = _mat(Color(0.92, 0.95, 1.0), true)
	cloud.position = Vector3(-7.5, -0.6, -60.5)
	add_child(cloud)

func _build_ground() -> void:
	var pm := PlaneMesh.new()
	pm.size = Vector2(130, 46)
	_shape(pm, Color(0.40, 0.40, 0.43), Vector3(2, -0.02, -1))
	_moon_prop(World.KK, "lander_A", LANDER_AT, 25.0, 1.7, Color(0.80, 0.78, 0.72))
	_moon_prop(World.SK, "craterLarge", Vector3(5.6, 0, -3.6), 0.0, 2.6, Color(0.36, 0.36, 0.39))
	_moon_prop(World.SK, "crater", Vector3(-6.2, 0, 1.6), 40.0, 2.0, Color(0.36, 0.36, 0.39))
	_moon_prop(World.SK, "crater", Vector3(4.9, 0, 2.6), 0.0, 1.5, Color(0.36, 0.36, 0.39))
	_moon_prop(World.SK, "craterLarge", Vector3(-1.0, 0, -8.0), 0.0, 3.4, Color(0.36, 0.36, 0.39))
	_moon_prop(World.SK, "rocks_smallB", Vector3(0.4, 0, 2.3), 0.0, 1.2)
	_moon_prop(World.SK, "rock_largeB", Vector3(10.6, 0, -2.6), 30.0, 1.5)
	# The walk-back circle: inside it, the crew could still walk home if the rover broke down.
	walk_ring = MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = WALKBACK_R - 0.07
	tm.outer_radius = WALKBACK_R + 0.07
	tm.rings = 96
	walk_ring.mesh = tm
	walk_ring.material_override = _mat(Color(1.0, 0.78, 0.25), true)
	walk_ring.scale = Vector3(1, 0.1, 1)
	walk_ring.position = LANDER_AT + Vector3(0, 0.03, 0)
	add_child(walk_ring)

func _build_sites() -> void:
	# Close site: ordinary grey rocks.
	_moon_prop(World.SK, "rock_largeA", SITE_ROCK.near, 10.0, 1.2)
	_moon_prop(World.SK, "rocks_smallA", SITE_ROCK.near + Vector3(0.7, 0, 0.5), 0.0, 1.0)
	# Far site: a rare white rock among the grey ones.
	_moon_prop(World.SK, "rock_largeB", SITE_ROCK.far, 0.0, 1.3)
	var white := _box(Vector3(0.42, 0.34, 0.36), Color(0.95, 0.95, 0.98), SITE_ROCK.far + Vector3(-0.2, 0.62, 0.25))
	white.rotation_degrees = Vector3(12, 30, 8)
	_km_label("2 km", SITE_ROCK.near + Vector3(0.9, 0.35, 0.9))
	_km_label("5 km", SITE_ROCK.far + Vector3(0.2, 0.35, 1.7))

func _km_label(text: String, at: Vector3) -> void:
	var l := Label3D.new()
	l.text = text
	l.font = load("res://assets/fonts/AtkinsonHyperlegible-Bold.ttf")
	l.font_size = 72
	l.pixel_size = 0.0055
	l.outline_size = 22
	l.modulate = Color(1.0, 0.86, 0.4)
	l.outline_modulate = Color(0.08, 0.07, 0.12)
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.position = at
	add_child(l)

func _build_rover() -> void:
	# The rover is built from simple shapes: a flat frame, four wheels, two seats and a dish.
	rover = Node3D.new()
	add_child(rover)
	_box(Vector3(1.35, 0.1, 0.8), Color(0.78, 0.78, 0.80), Vector3(0, 0.3, 0), rover)
	for sx in [-0.5, 0.5]:
		for sz in [-0.46, 0.46]:
			var cyl := CylinderMesh.new()
			cyl.top_radius = 0.2
			cyl.bottom_radius = 0.2
			cyl.height = 0.14
			var w := _shape(cyl, Color(0.20, 0.20, 0.23), Vector3(sx, 0.2, sz), rover)
			w.rotation_degrees.x = 90
	crew_bob = Node3D.new()
	rover.add_child(crew_bob)
	var seat_z := [-0.2, 0.2]
	var suits := ["astronautA", "astronautB"]
	var trims := [Color(1.0, 0.74, 0.22), Color(0.42, 0.82, 1.0)]
	for i in range(2):
		_box(Vector3(0.3, 0.2, 0.3), Color(0.55, 0.55, 0.60), Vector3(-0.05, 0.42, seat_z[i]), crew_bob)
		var a: Node3D = helper.prop(World.SK, suits[i], Vector3(-0.05, 0.42, seat_z[i]), -90.0, 0.62, crew_bob)
		helper.tint(a, "metalRed", trims[i])
	var mast := CylinderMesh.new()
	mast.top_radius = 0.02
	mast.bottom_radius = 0.02
	mast.height = 0.55
	_shape(mast, Color(0.7, 0.7, 0.72), Vector3(0.5, 0.62, 0), rover)
	var dish := CylinderMesh.new()
	dish.top_radius = 0.2
	dish.bottom_radius = 0.02
	dish.height = 0.08
	_shape(dish, Color(0.95, 0.85, 0.45), Vector3(0.5, 0.92, 0), rover)
	tray = Node3D.new()
	tray.position = Vector3(-0.52, 0.36, 0)
	rover.add_child(tray)
	# Moon dust kicked up by the wheels: it flies in long arcs because gravity is weak.
	dust = CPUParticles3D.new()
	dust.amount = 26
	dust.lifetime = 0.9
	dust.local_coords = false
	dust.direction = Vector3(0, 1, 0)
	dust.spread = 50.0
	dust.gravity = Vector3(0, -1.6, 0)
	dust.initial_velocity_min = 0.8
	dust.initial_velocity_max = 1.5
	dust.scale_amount_min = 0.5
	dust.scale_amount_max = 1.1
	var qm := QuadMesh.new()
	qm.size = Vector2(0.14, 0.14)
	var dm := _mat(Color(0.72, 0.72, 0.76, 0.7), true)
	dm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	qm.material = dm
	dust.mesh = qm
	dust.position = Vector3(-0.6, 0.1, 0)
	dust.emitting = false
	rover.add_child(dust)

## The astronauts on foot (for lowering the rover and for the last experiment), the tape, a hammer and a feather.
func _build_deploy_and_drop() -> void:
	var suits := ["astronautA", "astronautB"]
	var trims := [Color(1.0, 0.74, 0.22), Color(0.42, 0.82, 1.0)]
	for i in range(2):
		var a: Node3D = helper.prop(World.SK, suits[i], stand_base[i], 150.0 if i == 0 else 200.0, 0.9, self)
		helper.tint(a, "metalRed", trims[i])
		a.visible = false
		stand.append(a)
	var bm := BoxMesh.new()
	bm.size = Vector3(0.035, 0.035, 1.0)
	tape = _shape(bm, Color(0.95, 0.95, 0.9), Vector3.ZERO)
	tape.visible = false
	hammer = Node3D.new()
	add_child(hammer)
	var handle := CylinderMesh.new()
	handle.top_radius = 0.03
	handle.bottom_radius = 0.03
	handle.height = 0.55
	_shape(handle, Color(0.62, 0.62, 0.66), Vector3(0, 0.27, 0), hammer)
	_box(Vector3(0.26, 0.11, 0.11), Color(0.80, 0.80, 0.84), Vector3(0, 0.55, 0), hammer)
	feather = Node3D.new()
	add_child(feather)
	var vane := SphereMesh.new()
	vane.radius = 0.5
	vane.height = 1.0
	var f := _shape(vane, Color(0.97, 0.96, 0.92), Vector3(0, 0.3, 0), feather)
	f.scale = Vector3(0.16, 0.6, 0.03)
	var quill := CylinderMesh.new()
	quill.top_radius = 0.012
	quill.bottom_radius = 0.012
	quill.height = 0.7
	_shape(quill, Color(0.85, 0.82, 0.74), Vector3(0, 0.32, 0), feather)
	feather.rotation_degrees.z = 20
	hammer.visible = false
	feather.visible = false

## Lowering the rover from the lander: 0 = folded against the lander, 1 = on its wheels with the crew aboard.
## The two flags say which astronaut is working right now.
func set_deploy(frac: float, a_on: bool, b_on: bool) -> void:
	_dep_a = a_on
	_dep_b = b_on
	var e: float = smoothstep(0.0, 1.0, clampf(frac, 0.0, 1.0))
	rover.position = Vector3(-2.1, 0.95, 0.35).lerp(POINTS.lander, e)
	rover.rotation = Vector3(0, 0, deg_to_rad(76.0) * (1.0 - e))
	var done: bool = frac >= 1.0
	crew_bob.visible = done
	tape.visible = not done
	for st in stand:
		st.visible = not done
	if not done:
		var from: Vector3 = stand_base[1] + Vector3(0, 0.5, 0)
		var to: Vector3 = rover.position + rover.transform.basis * Vector3(0.6, 0.35, 0.0)
		var dir := to - from
		tape.transform = Transform3D(Basis.looking_at(dir.normalized(), Vector3.UP) * Basis.from_scale(Vector3(1, 1, dir.length())), (from + to) * 0.5)

## The last experiment: a hammer and a feather, held up beside an astronaut.
func set_drop(on: bool) -> void:
	hammer.visible = on
	feather.visible = on
	stand[1].visible = on
	if on:
		stand[1].position = Vector3(0.9, 0, 0.7)
		drop_reset()
	else:
		stand[1].position = stand_base[1]

func drop_reset() -> void:
	hammer.position = Vector3(0.25, 1.75, 1.3)
	feather.position = Vector3(1.55, 1.75, 1.3)

## Lets go of both. On the Moon they fall together; with Earth's air the feather drifts down. Use with await.
func drop(air: bool) -> void:
	if reduced_motion:
		hammer.position.y = 0.0
		feather.position.y = 0.0
		return
	var tw := create_tween().set_parallel(true)
	tw.tween_property(hammer, "position:y", 0.0, 0.62 if air else 1.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if air:
		var x0: float = feather.position.x
		tw.tween_method(func(k: float): feather.position = Vector3(x0 + sin(k * 14.0) * 0.22, 1.75 * (1.0 - k), 1.3), 0.0, 1.0, 3.4)
	else:
		tw.tween_property(feather, "position:y", 0.0, 1.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tw.finished

func rock_pos(i: int) -> Vector3:
	return (rocks[i].node as Node3D).position

func _build_markers() -> void:
	for id in ["near", "far", "lander"]:
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
		var pos := Vector3.ZERO
		if id == "lander":
			pos = LANDER_AT + Vector3(0, 2.3, 0)
		elif SITE_ROCK.has(id):
			pos = SITE_ROCK[id] + Vector3(0, 1.1, 0)
		tappables[id] = {"pos": pos, "radius": 95.0, "marker": marker, "on": false}
	for i in range(2):
		var ring := MeshInstance3D.new()
		var tm := TorusMesh.new()
		tm.inner_radius = 0.55
		tm.outer_radius = 0.68
		ring.mesh = tm
		var m := _mat(Color(1, 1, 1, 0.9), true)
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ring.material_override = m
		ring.scale = Vector3(1, 0.1, 1)
		ring.visible = false
		add_child(ring)
		goal_rings.append(ring)

# ---------------------------------------------------------------- state the game can set

func reset_scene() -> void:
	set_deploy(1.0, false, false)
	set_drop(false)
	rover.position = POINTS.lander
	rover.rotation = Vector3.ZERO
	for c in tray.get_children():
		c.queue_free()
	clear_rocks()
	set_drive(false)
	set_tappable([])
	set_goals([])

func set_drive(on: bool) -> void:
	drive_on = on

func set_tappable(marked: Array) -> void:
	for id in tappables:
		tappables[id].on = marked.has(id)
		tappables[id].marker.visible = marked.has(id)

func set_goals(points: Array) -> void:
	for i in range(goal_rings.size()):
		goal_rings[i].visible = i < points.size()
		if goal_rings[i].visible:
			goal_rings[i].position = POINTS[points[i]] + Vector3(0, 0.035, 0)

## Lays out the loose rocks of a site. Each one can be tapped; a white ring marks it.
func spawn_rocks(site: String) -> void:
	clear_rocks()
	for i in range(ROCK_OFFSETS.size()):
		var kind: String = ROCK_KINDS[site][i]
		var at: Vector3 = POINTS[site] + ROCK_OFFSETS[i]
		var extras: Array = []
		if kind == "white":
			# Apollo 15 found the Genesis Rock sitting on a pedestal of soil, and photographed it beside the gnomon.
			var ped := CylinderMesh.new()
			ped.top_radius = 0.15
			ped.bottom_radius = 0.24
			ped.height = 0.16
			extras.append(_shape(ped, Color(0.44, 0.44, 0.47), at + Vector3(0, 0.08, 0)))
			var rod := CylinderMesh.new()
			rod.top_radius = 0.018
			rod.bottom_radius = 0.018
			rod.height = 0.6
			extras.append(_shape(rod, Color(0.95, 0.55, 0.2), at + Vector3(0.42, 0.3, 0.05)))
			for k in range(3):
				var leg := _shape(rod, Color(0.85, 0.85, 0.88), at + Vector3(0.42, 0.14, 0.05))
				leg.scale = Vector3(1, 0.55, 1)
				leg.rotation_degrees = Vector3(28, 120 * k, 0)
				extras.append(leg)
		var r := _box(Vector3(0.34, 0.26, 0.30), ROCK_COL[kind], at + Vector3(0, 0.29 if kind == "white" else 0.13, 0))
		r.rotation_degrees = Vector3(8 * i, 37 * i, 5)
		var ring := MeshInstance3D.new()
		var tm := TorusMesh.new()
		tm.inner_radius = 0.30
		tm.outer_radius = 0.37
		ring.mesh = tm
		var m := _mat(Color(1, 1, 1, 0.85), true)
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ring.material_override = m
		ring.scale = Vector3(1, 0.1, 1)
		ring.position = at + Vector3(0, 0.03, 0)
		ring.visible = false
		add_child(ring)
		rocks.append({"node": r, "kind": kind, "ring": ring, "extras": extras})
		tappables["rock%d" % i] = {"pos": at + Vector3(0, 0.6, 0), "radius": 60.0, "marker": ring, "on": false, "flat": true}

func clear_rocks() -> void:
	for i in range(rocks.size()):
		rocks[i].node.queue_free()
		rocks[i].ring.queue_free()
		for x in rocks[i].extras:
			x.queue_free()
		tappables.erase("rock%d" % i)
	rocks = []

func rock_kind(i: int) -> String:
	return rocks[i].kind

## The crew picks up one rock: it leaves the ground and lands in the rover's tray.
func collect_rock(i: int) -> void:
	var r: MeshInstance3D = rocks[i].node
	rocks[i].ring.visible = false
	if reduced_motion:
		r.visible = false
	else:
		var tw := create_tween()
		tw.tween_property(r, "scale", Vector3.ONE * 0.05, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw.tween_callback(func(): r.visible = false)
	await add_sample(rocks[i].kind)

## How far the rover is from where it parked by the lander, in kilometres (the far site is 5 km away).
func km_from_lander() -> float:
	var a: Vector3 = POINTS.lander
	var full: float = Vector2(POINTS.far.x - a.x, POINTS.far.z - a.z).length()
	return clampf(Vector2(rover.position.x - a.x, rover.position.z - a.z).length() / full * 5.0, 0.0, 5.0)

func dist(point: String) -> float:
	var b: Vector3 = POINTS[point]
	return Vector2(rover.position.x - b.x, rover.position.z - b.z).length()

## True when the rover is right at the walk-back line.
func at_limit() -> bool:
	return Vector2(rover.position.x - LANDER_AT.x, rover.position.z - LANDER_AT.z).length() > WALKBACK_R - 0.75

## One rock lands in the rover's tray; the crew gives a slow, low-gravity hop.
func add_sample(kind: String) -> void:
	var n := tray.get_child_count()
	var r := _box(Vector3(0.16, 0.13, 0.15), ROCK_COL[kind], Vector3(0.0, 0.07 + 0.02 * n, -0.2 + 0.2 * n), tray)
	r.rotation_degrees = Vector3(10 * n, 35 * n, 0)
	if not reduced_motion:
		r.scale = Vector3.ONE * 0.05
		create_tween().tween_property(r, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_hop = 1.0
		await get_tree().create_timer(0.45).timeout

## Drives the rover to a named point by itself. Use with await.
func drive_to(point: String) -> void:
	var to: Vector3 = POINTS[point]
	var d: float = rover.position.distance_to(to)
	if d < 0.05:
		return
	if reduced_motion:
		rover.position = to
		return
	rover.rotation.y = atan2(-(to.z - rover.position.z), to.x - rover.position.x)
	dust.emitting = true
	var tw := create_tween()
	tw.tween_property(rover, "position", to, d / DRIVE_SPEED).set_trans(Tween.TRANS_SINE)
	await tw.finished
	dust.emitting = false

# ---------------------------------------------------------------- per-frame motion and taps

func _blocked(x: float, z: float) -> bool:
	if not BOUNDS.has_point(Vector2(x, z)):
		return true
	if Vector2(x - LANDER_AT.x, z - LANDER_AT.z).length() > WALKBACK_R - 0.45:
		return true   # the walk-back line: no farther
	if Vector2(x - LANDER_AT.x, z - LANDER_AT.z).length() < 1.6:
		return true
	for site in SITE_ROCK:
		var r: Vector3 = SITE_ROCK[site]
		if Vector2(x - r.x, z - r.z).length() < 0.75:
			return true
	return false

func _process(dt: float) -> void:
	_t += dt
	var moving := false
	if drive_on and visible:
		var v := Vector2.ZERO
		v.x += float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
		v.y += float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
		v = v.limit_length(1.0)
		if v != Vector2.ZERO:
			var nx: float = rover.position.x + v.x * DRIVE_SPEED * dt
			var nz: float = rover.position.z + v.y * DRIVE_SPEED * dt
			if not _blocked(nx, nz):
				rover.position.x = nx
				rover.position.z = nz
			elif not _blocked(nx, rover.position.z):
				rover.position.x = nx
			elif not _blocked(rover.position.x, nz):
				rover.position.z = nz
			rover.rotation.y = lerp_angle(rover.rotation.y, atan2(-v.y, v.x), min(dt * 9.0, 1.0))
			moving = true
		dust.emitting = moving and not reduced_motion
	# The crew bounces gently while driving, and hops when a rock is collected.
	_hop = max(_hop - dt * 1.6, 0.0)
	var bob := 0.0
	if not reduced_motion:
		bob = (abs(sin(_t * 9.0)) * 0.03 if moving else 0.0) + sin(_hop * PI) * 0.22
	crew_bob.position.y = bob
	if not reduced_motion and stand.size() == 2 and tape.visible:
		stand[0].position.y = stand_base[0].y + (abs(sin(_t * 8.0)) * 0.05 if _dep_a else 0.0)
		stand[1].position.y = stand_base[1].y + (abs(sin(_t * 8.0 + 1.0)) * 0.05 if _dep_b else 0.0)
	if not reduced_motion:
		var k: float = 1.0 + sin(_t * 2.2) * 0.08
		for ring in goal_rings:
			ring.scale = Vector3(k, 0.1, k)
	for id in tappables:
		var t: Dictionary = tappables[id]
		if t.on and not t.has("flat"):
			t.marker.position = t.pos + Vector3(0, 0.0 if reduced_motion else sin(_t * 2.6) * 0.06, 0)

func _unhandled_input(e: InputEvent) -> void:
	if not visible or not (e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT):
		return
	var k: float = get_viewport().get_visible_rect().size.y / 900.0
	var best := ""
	var best_d := 1e9
	for id in tappables:
		var t: Dictionary = tappables[id]
		if not t.on:
			continue
		var d: float = cam.unproject_position(t.pos - Vector3(0, 0.5, 0)).distance_to(e.position)
		if d < t.radius * k and d < best_d:
			best = id
			best_d = d
	if best != "":
		get_viewport().set_input_as_handled()
		tapped.emit(best)
