extends Node
## Junior Astronaut Mission Trainer: minimal demo.
## One Mars room, two roles with split information, one job before a solar storm.
## A narrator (the crew's commander) guides the players through a dialogue box with a 3D portrait.
## The player sets the pace: nothing is timed and nothing flashes.

const World := preload("res://world.gd")
const Moon := preload("res://moon.gd")
const Space := preload("res://space.gd")
const UI := preload("res://ui_kit.gd")
const Strings := preload("res://strings.gd")

# Level 2 (Mars) numbers: the team's Mars-surface model. Each one is listed with its source on "NASA data used".
const BG_MSV := 0.69          # mSv in one normal sol on Mars (Curiosity RAD, measurement). The Radiation bar counts in these sols.
const SHELTER_K := 0.3        # share of a storm that gets through a reinforced shelter (simplified game assumption)
const GOAL_POWER := 75.0      # % of power at dawn (game rule)
const GOAL_RAD := 6.0         # sols of normal radiation in one sol (game rule, not a health limit)
const RAD_BAR_MAX := 14.0     # top of the Radiation bar, in sols
const STARTS := {
	"a": {"offline": 1, "storm": 8.1, "size": "big"},      # 20 May 2024: 8.1 mGy measured on Mars by Curiosity (measurement)
	"b": {"offline": 2, "storm": 1.38, "size": "small"},   # a small storm, close to September 2017 (game rule)
}
const TANKS_FULL := 4          # oxygen tanks the base holds (game rule). One tank is half a sol of oxygen for a crew of 4 (calculation)
const TANKS_USED := 2          # tanks the crew breathes in one sol (calculation from NASA's 0.895 kg per person per day)
const SUN_DAYS := 7            # bonus sol: a solar particle event this recent counts as a storm today (game rule)
const SUN_MSV := {"big": 8.1, "small": 1.38, "none": 0.0}
# The free mission: three sols drawn at random. All of these are the team's tested game rules.
const F_SOLS := 3
const F_FAULT := 0.35          # chance that one more power unit fails each sol (at most 2 off)
const F_BIG := 0.20            # chance of the big storm each sol
const F_SMALL := 0.25          # chance of a storm that adds 2 sols
const F_RAD_GOAL := 12.0       # sols of normal radiation in the whole mission
const F_CARDS := [[2012, 3, 7], [2017, 9, 10], [2021, 10, 28], [2024, 5, 11], [2025, 11, 11]]   # real solar particle events in NASA DONKI
# Level 1 (the Moon). Sources: Apollo 15 Mission Report and Apollo Lunar Surface Journal; see "NASA data used".
const O2_FULL := 7.0                             # hours of oxygen in the suit backpack (NASA Mission Control, during Apollo 15)
const ROVER_KMH := 10.0                          # typical rover speed (measurement)
const SITE_KM := {"near": 2.0, "far": 5.0}       # 5 km: the farthest Apollo 15 drove from its lander (measurement); 2 km: game rule
const WALK_BACK_H := {"near": 1.2, "far": 3.0}   # hours to walk home at Apollo 15's walking speed (calculation)
const ROCK_WORK_H := 2.5                         # hours of rock work at a site (game rule)
const ROCK_POINTS := {"grey": 1.0, "dark": 1.0, "white": 4.0}   # science points per rock; the rare white rock is worth 4 (game rule)
const SCIENCE_MAX := 6.0
const COL_O2 := Color(0.45, 0.85, 1.0)
const COL_SCI := Color(1.0, 0.82, 0.3)
# The NASA terminal makes real requests from the player's browser. If NASA does not answer, the game says so
# and falls back to the archived copy bundled with it. Nothing archived is ever labelled live.
const NASA_KEY_FILE := "res://nasa_key.txt"   # optional, ignored by git: one line with the team's own api.nasa.gov key
const DONKI_URL := "https://api.nasa.gov/DONKI/SEP?startDate=%s&endDate=%s&api_key=%s"   # DONKI allows 60 days at most
const PHOTO_ID := "as15-86-11603"
const PHOTO_META_URL := "https://images-api.nasa.gov/search?nasa_id=as15-86-11603"
const PHOTO_URL := "https://images-assets.nasa.gov/image/as15-86-11603/as15-86-11603~small.jpg"
const TERM_GREEN := Color(0.55, 1.0, 0.66)
const IGNORE := Control.MOUSE_FILTER_IGNORE
const SPEAKER_COL := {"cmd": Color(0.45, 0.92, 0.78), "eng": Color(1.0, 0.74, 0.22), "pro": Color(0.42, 0.82, 1.0), "earth": Color(0.70, 0.78, 1.0), "mc": Color(0.78, 0.84, 1.0)}
const BOX := Color(0.09, 0.08, 0.15, 0.78)   # dialogue box and notes: see-through, so the scene shows behind
const BARS_W := 176      # width kept free in the bottom-right corner for the two bars
const VOICE_TONE := {"cmd": [0.9, 0.95], "mc": [1.0, 1.0], "eng": [1.15, 1.0], "pro": [1.3, 1.0], "earth": [0.8, 0.9]}   # read-aloud [pitch, pace] per character
const STORM_PIC_URL := "https://images-assets.nasa.gov/image/PIA26302/PIA26302~small.jpg"   # Curiosity, 20 May 2024
const MODAL_STATES := ["title", "players", "select", "m_card", "m_term", "p_term", "m_compare", "to_mars", "to_moon", "decide", "compare", "debrief", "end", "f_decide", "f_end"]
const NOTE_STATES := ["meet", "role_eng", "role_pro", "ask_earth", "earth_q"]

var world: Node3D               # level 2: Mars
var moon: Node3D                # level 1: the Moon
var space: Node3D               # level 0: deep space, for the title and the mission select
var level := 0
var moon_done := false          # Mars unlocks once the Moon level has been played
var mars_done := false
var nasa_key := "DEMO_KEY"      # NASA's public demo key (about 10 requests an hour) unless nasa_key.txt holds another
var _live := {}                 # what the NASA terminal already fetched, kept for this session
var oxygen := O2_FULL           # Moon: hours of oxygen left if the crew had to walk home from where it is
var science := 0.0              # Moon: science points collected
var m_site := ""                # Moon: the rock site the crew drove to
var m_dug: Array = []           # Moon: which loose rocks the crew picked up (up to 3 of 5)
var m_dep := 1.0                # Moon: how far the rover has been lowered from the lander (0 to 1)
var dep_a := false              # Moon: "let it go" switched on by a tap (the W key also works)
var dep_b := false              # Moon: "pull the tape" switched on by a tap (the Up key also works)
var _dep_seen := [false, false]
var m_pending := -1             # Moon: the rare rock waiting for its photo
var m_photo: Texture2D          # Moon: the photo of the rare rock where it lay
var drop_guess := ""            # Moon: the prediction for the hammer and the feather
var drop_done := {"moon": false, "air": false}
var m_final := {}               # Moon: the reserve and science the trip ended with
var m_runs: Array = []          # Moon: one entry per finished trip: {site, oxygen, science, shot}
var m_shot: Texture2D           # Moon: picture of the rover at the rock site, for the comparison
var term := {}                  # NASA terminal, per level: {step: 0 idle / 1 asking / 2 done, ok, ...what came back}
var live_off := false           # development: skip the network and use the fallback
var m_limit := false            # Moon: the rover has touched the walk-back line
var ui: Control
var lang := "en"
var state := "title"
var page := 0                   # which narrator line of the current scene is showing
var players := 1
var active := "eng"             # with one player: the astronaut the keys steer
var voice_on := false
var show_src := false           # tags on every number (Measurement / Calculation / Game rule) during play
var data_open := false
var settings_open := false
var busy := false
var reported := {"eng": false, "pro": false}
var votes := {"eng": "", "pro": ""}
var choice := ""
var job := {}                   # the job's little game: plugs and sockets, or water bags and storm rays
var runs: Array = []            # one entry per finished plan: {choice, power, exposure, shot}
var earth_guess := ""
var picks := {}                 # answers: prediction, picked plan, debrief
var tanks := TANKS_FULL          # Mars: full oxygen tanks this morning
var tanks_view := TANKS_FULL     # Mars: full oxygen tanks shown right now
var sun := {"size": "small", "live": false, "date": "", "at": ""}   # bonus sol: what today's real Sun means for the base
const LOG_FILE := "user://logbook.json"   # the crew logbook: on the device only, never sent anywhere
var logb := {}                  # the crew logbook
var log_keep := true            # false in development runs, so tests never write the player's logbook
var logbook_open := false
var log_note := ""
var f := {}                     # free mission: {sol, offline, tanks, science, expo, low, storm, card, fault, log}
var hv := {}                    # harvest day: {ready, dark, picked, msg}
var m_briefed := false          # Moon: Mission Control has named the two things to watch
var carried := ""               # sol 31: the plan from sol 30 that the crew picked, whose consequences carry over
var start := "a"                # which Mars morning is being played: "a" (sol 30), "b" (sol 31) or "c" (bonus sol: today's real Sun)
var power := 75.0               # Mars: % of power
var exposure := 1.0             # Mars: today's radiation, in sols of normal radiation
var portraits := {}             # speaker -> {vp: SubViewport, holder: Node3D, phase: float}
var _dirty := true
var _fresh := true              # true while drawing a scene for the first time: the box slides in
var _drawn := ""
var _spoken := ""
var _t := 0.0
var _fills: Array = []
var _vals: Array = []
var _val_seen := ["", ""]       # last value shown on each bar, to highlight a change
var _val_at := [0.0, 0.0]
var ghosts: Control             # the box that is leaving: it fades out under the new one
var tips: Control               # hover tips, drawn above everything
var fade: ColorRect             # the fade between levels
var _type_tw: Tween
var _typing: Label              # the line being typed out, so a tap can finish it
var _tip_for: Control
var _tip_node: Control

func t(key: String) -> String:
	return Strings.t(key, lang)

func _ready() -> void:
	if FileAccess.file_exists(NASA_KEY_FILE):
		var key := FileAccess.get_file_as_string(NASA_KEY_FILE).strip_edges()
		if key != "":
			nasa_key = key
	world = World.new()
	add_child(world)
	world.tapped.connect(_on_tapped)
	moon = Moon.new()
	moon.helper = world
	add_child(moon)
	moon.tapped.connect(_on_tapped)
	space = Space.new()
	space.helper = world
	add_child(space)
	space.tapped.connect(_on_tapped)
	for who in ["cmd", "eng", "pro", "earth", "mc"]:
		_make_portrait(who)
	var layer := CanvasLayer.new()
	add_child(layer)
	ghosts = Control.new()
	ui = Control.new()
	tips = Control.new()
	for c in [ghosts, ui, tips]:
		c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		c.mouse_filter = IGNORE
		layer.add_child(c)
	fade = ColorRect.new()
	fade.color = Color(0.02, 0.02, 0.05, 0.0)
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = IGNORE
	layer.add_child(fade)
	_log_load()
	_reset_run()
	world.set_units_online(4)
	world.set_room_power(1.0, false)
	_go("title")
	_dev_hooks()

## The storm card: one archived NASA DONKI record per Mars morning, bundled in data/. Never fetched live.
func _storm_line() -> String:
	if start == "c":
		return _sun_line()
	return t("donki_" + start)

## The bonus sol's storm comes from what NASA DONKI lists for the last few days.
func _storm_size() -> String:
	if start == "f":
		return f.storm
	return sun.size if start == "c" else STARTS[start].size

func _storm_msv() -> float:
	if start == "f":
		return SUN_MSV[f.storm]
	return SUN_MSV[sun.size] if start == "c" else STARTS[start].storm

## Reads the terminal's answer for the bonus sol. A live answer decides "storm or no storm";
## with no answer, the archived September 2017 event is used and labelled archived.
func _sun_read() -> void:
	var st: Dictionary = term.get("mars", {})
	sun = {"size": "small", "live": false, "date": "", "at": str(st.get("at", ""))}
	if not st.get("ok", false):
		return
	sun.live = true
	sun.size = "none"
	var latest := str(st.get("latest", ""))
	if latest.length() >= 10:
		var age: float = Time.get_unix_time_from_system() - Time.get_unix_time_from_datetime_string(latest.substr(0, 10))
		if age <= SUN_DAYS * 86400.0:
			sun.size = "big"   # DONKI gives no size for Mars: the game trains for the biggest surge Curiosity measured
			sun.date = latest.substr(0, 10)
	if start == "c":
		# The crew's diary of the real Sun: one entry a day, only when NASA really answered.
		var today := Time.get_date_string_from_system()
		var known := false
		for pair in logb.sun:
			if pair[0] == today:
				known = true
		if not known:
			logb.sun.append([today, sun.size])
			logb.sun = logb.sun.slice(-60)
			_log_save()

func _sun_line() -> String:
	if not sun.live:
		return t("sun_arch")
	if sun.size == "none":
		return t("sun_calm").format({"time": sun.at})
	return t("sun_storm").format({"time": sun.at, "date": _iso_date(sun.date)})

## Tanks the oxygen machine fills in one night: it runs on the base's power (game rule).
func _tanks_made(p: float) -> int:
	return 2 if p >= 99.0 else (1 if p >= 74.0 else 0)

## Full tanks the next dawn: this morning's, minus what the crew breathes, plus what the machine fills.
func _tanks_after(c: String) -> int:
	return clampi(tanks - TANKS_USED + _tanks_made(_p_after(c)), 0, TANKS_FULL)

func _meet_ready() -> bool:
	return start != "a" or reported.eng or reported.pro or page >= 4

## Which resource the narrator is naming right now: 0 or 1 = a bar, 2 = the oxygen tanks, -1 = none.
func _brief_focus() -> int:
	if level == 1 and state == "m_drive" and not m_briefed:
		return page
	if level == 2 and state == "meet" and not _meet_ready():
		return [-1, 0, 2, 1][page]
	return -1

## How many power units are off this morning. On sol 31 it depends on yesterday:
## a unit left broken stays off, and one more fails overnight (game rule).
func _offline() -> int:
	if start == "b":
		return 2 if carried == "a" else 1
	if start == "f":
		return f.offline
	return 1

func _p_start() -> float:
	return 100.0 - 25.0 * _offline()

## Power at dawn after a job: repairing brings one unit back.
func _p_after(c: String) -> float:
	return _p_start() + (25.0 if c == "b" else 0.0)

## Today's radiation after a job, in sols of normal radiation: the normal sol plus the storm.
func _x_after(c: String) -> float:
	return (BG_MSV + _storm_msv() * (SHELTER_K if c == "a" else 1.0)) / BG_MSV

func _goal_met(p: float, x: float) -> bool:
	return p >= GOAL_POWER and snappedf(x, 0.1) <= GOAL_RAD

func _n1(x: float) -> String:
	return "%.1f" % x

## The numbers of this morning, ready to drop into the texts.
func _sc() -> Dictionary:
	return {"n": _offline(), "p0": int(_p_start()), "p1": int(_p_after("b")), "xt": _n1(_x_after("b")), "xs": _n1(_x_after("a"))}

## A live 3D portrait for the dialogue box: the same low-poly model, framed head and shoulders.
func _make_portrait(who: String) -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(320, 320)
	vp.own_world_3d = true
	vp.transparent_bg = true
	vp.msaa_3d = Viewport.MSAA_2X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)
	var env := Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 0.95, 0.9)
	env.ambient_light_energy = 0.6
	var cam := Camera3D.new()
	cam.environment = env
	cam.fov = 30.0
	vp.add_child(cam)
	var key := DirectionalLight3D.new()
	key.light_energy = 0.9
	key.rotation_degrees = Vector3(-28, -38, 0)
	vp.add_child(key)
	var holder := Node3D.new()
	vp.add_child(holder)
	if who == "earth":
		world.prop(World.SK, "satelliteDish_large", Vector3.ZERO, -30.0, 1.0, holder)
		cam.look_at_from_position(Vector3(0.5, 1.0, 2.25), Vector3(0, 0.42, 0), Vector3.UP)
		env.ambient_light_energy = 1.1
	else:
		var suit: Node3D = world.prop(World.SK, "astronautB" if who == "pro" else "astronautA", Vector3.ZERO, 180.0, 1.0, holder)
		world.tint(suit, "metalRed", SPEAKER_COL[who])
		if who == "cmd":
			# The commander wears the same suit with a different trim and grey hair.
			world.tint(suit, "rock", Color(0.86, 0.86, 0.9))
			world.tint(suit, "rockDark", Color(0.72, 0.72, 0.78))
		cam.look_at_from_position(Vector3(0.22, 0.64, 1.2), Vector3(0, 0.57, 0), Vector3.UP)
	portraits[who] = {"vp": vp, "holder": holder, "phase": float(portraits.size()) * 1.7}

func _process(dt: float) -> void:
	_t += dt
	if _dirty:
		_dirty = false
		_rebuild()
	if _fills.size() == 2 and is_instance_valid(_fills[0]):
		var specs := _bar_specs()
		for i in range(2):
			UI.vbar_set(_fills[i], specs[i].frac)
			_vals[i].text = specs[i].val
			if specs[i].val != _val_seen[i]:
				# The number that just changed pops, so the consequence is easy to spot.
				if _val_seen[i] != "" and not world.reduced_motion and _t - _val_at[i] > 0.45:
					_val_at[i] = _t
					var l: Label = _vals[i]
					l.pivot_offset = l.size * 0.5
					l.scale = Vector2(1.35, 1.35)
					l.create_tween().tween_property(l, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				_val_seen[i] = specs[i].val
	if not world.reduced_motion:
		for who in portraits:
			portraits[who].holder.rotation.y = sin(_t * 0.9 + portraits[who].phase) * 0.16
	if state == "m_deploy" and not busy and not _overlay():
		# The rover comes down only while both astronauts work: one lets it go, the other pulls the tape.
		var a_on: bool = dep_a or Input.is_physical_key_pressed(KEY_W)
		var b_on: bool = dep_b or Input.is_physical_key_pressed(KEY_UP)
		if a_on and b_on:
			m_dep = minf(m_dep + dt / 6.0, 1.0)
		moon.set_deploy(m_dep, a_on, b_on)
		if [a_on, b_on] != _dep_seen:
			_dep_seen = [a_on, b_on]
			_render()
		if m_dep >= 1.0:
			_deploy_done()
	if level == 1 and state == "m_drive" and not busy:
		# The reserve is what would be left after walking home from here: it drops as the rover drives away.
		oxygen = O2_FULL - 0.7 * moon.km_from_lander()
	_check_zones()

# ---------------------------------------------------------------- flow

func _render() -> void:
	_dirty = true

func _go(s: String) -> void:
	state = s
	page = 0
	if s == "title" or s == "select":
		_set_level(0)
	elif s == "players":
		_moon_reset()
		_set_level(1)   # the solo or co-op question is asked on the Moon
	_render()

func _next_page() -> void:
	page += 1
	_render()

func _set_busy(b: bool) -> void:
	busy = b
	_sync_world()

func _overlay() -> bool:
	return data_open or settings_open or logbook_open

# ---------------------------------------------------------------- the crew logbook (this device only)

func _log_blank() -> Dictionary:
	return {"missions": 0, "free": 0, "free_met": 0, "pred": 0, "pred_right": 0, "sols": 0, "both": 0, "last": [], "streak": 0, "hinted": false, "stars": 0, "best": 0, "sun": []}

## Reads the logbook saved on this device. Anything missing or odd in the file is ignored.
func _log_load() -> void:
	logb = _log_blank()
	if not FileAccess.file_exists(LOG_FILE):
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string(LOG_FILE))
	if not (d is Dictionary):
		return
	for k in ["missions", "free", "free_met", "pred", "pred_right", "sols", "both", "streak", "stars", "best"]:
		if d.has(k) and (d[k] is float or d[k] is int):
			logb[k] = maxi(int(d[k]), 0)
	logb.hinted = bool(d.get("hinted", false))
	logb.best = mini(logb.best, 3)
	if d.get("sun") is Array:
		for pair in d["sun"]:
			if pair is Array and pair.size() == 2 and pair[0] is String and (pair[0] as String).length() == 10 and ["none", "big"].has(pair[1]):
				logb.sun.append([pair[0], pair[1]])
		logb.sun = logb.sun.slice(-60)
	if d.get("last") is Array:
		for e in d["last"]:
			if e is Dictionary and e.get("sols") is Array:
				var sols: Array = []
				for pair in e["sols"]:
					if pair is Array and pair.size() == 2 and ["none", "small", "big"].has(pair[0]) and ["a", "b", "s"].has(pair[1]):
						sols.append([pair[0], pair[1]])
				logb.last.append({"met": bool(e.get("met", false)), "sols": sols})
		logb.last = logb.last.slice(-5)

func _log_save() -> void:
	if not log_keep:
		return
	var fa := FileAccess.open(LOG_FILE, FileAccess.WRITE)
	if fa != null:
		fa.store_string(JSON.stringify(logb))
		fa.close()

func _log_add(key: String, n := 1) -> void:
	logb[key] += n
	_log_save()

func _log_clear() -> void:
	logb = _log_blank()
	log_note = ""
	_log_save()
	_render()

func _open_logbook() -> void:
	logbook_open = true
	log_note = ""
	_render()

func _close_logbook() -> void:
	logbook_open = false
	_render()

## The logbook as plain text, for a parent or a teacher. It goes to the clipboard, nowhere else.
func _log_text() -> String:
	var lines: Array = [t("lb_title")]
	lines.append("%s: %d" % [t("lb_missions"), logb.missions])
	lines.append("%s: %s" % [t("lb_free"), t("lb_of").format({"n": logb.free_met, "m": logb.free})])
	lines.append("%s: %s" % [t("lb_pred"), t("lb_of").format({"n": logb.pred_right, "m": logb.pred})])
	lines.append("%s: %s" % [t("lb_read"), t("lb_of").format({"n": logb.both, "m": logb.sols})])
	lines.append("%s: %d" % [t("lb_stars"), logb.stars])
	if logb.free > 0:
		lines.append(t("lb_best").format({"n": logb.best}))
	if not logb.sun.is_empty():
		lines.append(_log_sun_line())
	for e in logb.last:
		lines.append(_log_line(e))
	lines.append(t("lb_private"))
	return "\n".join(lines)

func _log_copy() -> void:
	DisplayServer.clipboard_set(_log_text())
	log_note = t("lb_copied")
	_render()

## The real-Sun diary: days counted, never streaks.
func _log_sun_line() -> String:
	var calm := 0
	for pair in logb.sun:
		calm += 1 if pair[1] == "none" else 0
	return t("lb_sun").format({"d": logb.sun.size(), "c": calm, "a": logb.sun.size() - calm})

## A gold star for a goal that was met; a faint one for a goal that was not.
func _star(ok: bool, px: int) -> TextureRect:
	return UI.ui_icon("Yellow/Default/star.png", Color.WHITE if ok else Color(1, 1, 1, 0.22), px)

## How many of the free mission's three goals were met.
func _f_stars() -> int:
	return (1 if f.science else 0) + (1 if snappedf(f.expo, 0.1) <= F_RAD_GOAL else 0) + (1 if not f.low else 0)

## How much help the Commander offers right now: 0 none, 1 a nudge, 2 a nudge and highlighted reports.
## Only hints change with it. The odds and the rules never do.
func _scaffold_tier() -> int:
	if logb.streak >= 2 or f.blind >= 2:
		return 2
	if logb.streak == 1 or not (f.read.eng and f.read.pro):
		return 1
	return 0

func _f_guess(n: int) -> void:
	f.guess = n
	_render()

func _log_line(e: Dictionary) -> String:
	var parts: Array = []
	for pair in e.sols:
		parts.append(t("f_st_" + pair[0]) + " · " + t("f_job_" + pair[1]))
	return "  |  ".join(parts) + "  →  " + t("lb_met" if e.met else "lb_not")

## Shows one level's scene and hides the other.
func _set_level(n: int) -> void:
	if n != level and not world.reduced_motion:
		fade.color.a = 1.0
		fade.create_tween().tween_property(fade, "color:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		var c: Camera3D = [space.cam, moon.cam, world.cam][n]
		var base: float = [40.0, 32.0, 32.0][n]
		c.fov = base + 5.0
		c.create_tween().tween_property(c, "fov", base, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	level = n
	space.visible = n == 0
	moon.visible = n == 1
	world.visible = n == 2
	[space.cam, moon.cam, world.cam][n].current = true

func _moon_reset() -> void:
	oxygen = O2_FULL
	science = 0.0
	m_site = ""
	m_dug = []
	m_limit = false
	m_pending = -1
	m_photo = null
	moon.reset_scene()

func _start_moon() -> void:
	m_runs = []
	picks.erase("m_plan")
	term.erase("moon")
	_moon_reset()
	m_dep = 0.0
	m_briefed = false
	dep_a = false
	dep_b = false
	drop_guess = ""
	drop_done = {"moon": false, "air": false}
	moon.set_deploy(0.0, false, false)
	_set_level(0)
	_go("to_moon")   # the rocket flies from Earth to the Moon while Mission Control gives the brief

func _land_moon() -> void:
	_set_level(1)
	_go("m_term")

## The rover is down: the crew climbs aboard.
func _deploy_done() -> void:
	m_dep = 1.0
	dep_a = false
	dep_b = false
	moon.set_deploy(1.0, false, false)
	_go("m_drive")

func _dep_toggle(which: String) -> void:
	if which == "a":
		dep_a = not dep_a
	else:
		dep_b = not dep_b
	_render()

## The photo of the rare rock where it lies: a real crop of the scene.
func _m_take_photo() -> void:
	_set_busy(true)
	m_photo = await _capture_at(moon.cam, moon.rock_pos(m_pending))
	busy = false
	_render()

func _drop_predict(g: String) -> void:
	drop_guess = g
	_render()

func _drop(mode: String) -> void:
	_set_busy(true)
	moon.drop_reset()
	await _wait(0.4)
	await moon.drop(mode == "air")
	if mode == "moon" and not drop_done.moon:
		# The hammer and the feather: a prediction that came true, or not.
		logb.pred += 1
		if drop_guess == "same":
			logb.pred_right += 1
		_log_save()
	drop_done[mode] = true
	busy = false
	_render()

func _start_mars() -> void:
	_set_level(2)
	start = "a"
	carried = ""
	runs = []
	reported = {"eng": false, "pro": false}
	earth_guess = ""
	picks.erase("predict")
	picks.erase("plan")
	picks.erase("specks")
	term.erase("mars")
	data_open = false
	active = "eng"
	tanks = TANKS_FULL
	_reset_run()
	_go("meet")

## The bonus sol: the same morning as sol 30, but the storm report is today's real Sun.
func _start_c() -> void:
	_set_level(2)
	start = "c"
	carried = ""
	runs = []
	tanks = TANKS_FULL
	sun = {"size": "small", "live": false, "date": "", "at": ""}
	reported = {"eng": false, "pro": false}
	picks.erase("predict")
	picks.erase("plan")
	term.erase("mars")
	data_open = false
	active = "eng"
	_reset_run()
	_go("meet")

## The free mission: three sols with storms and faults drawn at random, and one report at the end.
func _start_free() -> void:
	_set_level(2)
	start = "f"
	carried = ""
	runs = []
	data_open = false
	f = {"sol": 1, "offline": 0, "tanks": TANKS_FULL, "science": false, "expo": 0.0, "low": false, "storm": "none", "card": [], "fault": false, "log": [], "read": {"eng": false, "pro": false}, "blind": 0, "hint": false, "guess": -1}
	_f_new_sol()
	if logb.streak >= 2 and not logb.hinted:
		# Two hard missions in a row: the Commander offers a hint, once. The odds never change.
		logb.hinted = true
		_log_save()
		_go("f_hint")
	else:
		_go("f_intro")

func _f_read(role: String) -> void:
	f.read[role] = true
	_render()

func _f_hint_pick(yes: bool) -> void:
	f.hint = yes
	if yes:
		_next_page()
	else:
		_go("f_intro")

## A new morning: one more unit may have failed overnight, and a storm card is drawn.
func _f_new_sol() -> void:
	f.fault = false
	if randf() < F_FAULT and f.offline < 2:
		f.offline += 1
		f.fault = true
	var r := randf()
	f.storm = "big" if r < F_BIG else ("small" if r < F_BIG + F_SMALL else "none")
	f.card = F_CARDS[randi() % F_CARDS.size()] if f.storm == "small" else []
	votes = {"eng": "", "pro": ""}
	f.read = {"eng": false, "pro": false}
	choice = ""
	job = {}
	tanks = f.tanks
	tanks_view = f.tanks
	power = 100.0 - 25.0 * f.offline
	exposure = f.expo
	world.reset_scene()   # the water bags go back to the water store every morning
	world.set_units_online(4 - f.offline)
	world.set_room_power(power / 100.0, false)
	world.set_tanks(f.tanks)

## A job is greyed out only when the crew can already know it is pointless.
func _f_pick_ok(id: String) -> bool:
	return not ((id == "b" and f.offline == 0 and f.read.eng) or (id == "s" and f.science))

## The job plays as a short film, then the storm and the night. The sol's numbers follow the team's rules.
func _f_do(c: String) -> void:
	choice = c
	busy = true
	var both_read: bool = f.read.eng and f.read.pro
	logb.sols += 1
	if both_read:
		logb.both += 1
	else:
		f.blind += 1
	_log_save()
	var idle: bool = c == "b" and f.offline == 0   # chosen without reading Engineering's report: nothing was broken
	_go("f_act")
	if c == "a":
		await world.walk_both("pro", "shelter", "eng", "shelter_help")
		for step in range(3):
			world.work("pro" if step % 2 == 0 else "eng", 0.4)
			await world.reinforce_step(step)
			await _wait(0.2)
	elif c == "b":
		await world.walk_both("eng", "power", "pro", "power_help")
		if idle:
			await _wait(0.8)
		else:
			for step in range(3):
				world.work("eng" if step % 2 == 0 else "pro", 0.4)
				await world.repair_step(4 - f.offline, step)
				await _wait(0.2)
			f.offline -= 1
			_tween_var("power", 100.0 - 25.0 * f.offline, 0.7)
			world.set_room_power((100.0 - 25.0 * f.offline) / 100.0)
	else:
		await world.walk_both("eng", "power", "pro", "power_help")
		if not world.reduced_motion:
			# The crew drives out of sight and comes back with the rock: a slow fade, nothing flashes.
			var out := fade.create_tween()
			out.tween_property(fade, "color:a", 1.0, 0.6)
			out.tween_interval(0.5)
			out.tween_property(fade, "color:a", 0.0, 0.6)
			await out.finished
		f.science = true
		_render()
	await _wait(0.5)
	var add: float = 1.0 + SUN_MSV[f.storm] * (SHELTER_K if c == "a" else 1.0) / BG_MSV
	if f.storm != "none":
		_go("f_storm")
		world.set_mood("storm")
		world.set_storm(true)
	await world.walk_both("eng", "shelter_a", "pro", "shelter_b")
	if f.storm != "none":
		await _wait(1.0)
	_go("f_night")
	world.set_mood("night")
	var used: int = TANKS_USED + (1 if c == "s" else 0)
	tanks_view = maxi(f.tanks - used, 0)
	world.set_tanks(tanks_view)
	_render()
	_tween_var("exposure", f.expo + add, 2.0)
	await _wait(2.4)
	world.set_storm(false)
	await _wait(0.6)
	var made: int = _tanks_made(100.0 - 25.0 * f.offline)
	var after: int = f.tanks - used + made
	var low: bool = after < 1
	if low:
		f.low = true
	f.tanks = maxi(after, 0)
	f.expo += add
	f.log.append({"sol": f.sol, "storm": f.storm, "job": c, "add": add, "made": made, "used": used, "tanks": f.tanks, "low": low, "idle": idle, "guess": f.guess})
	if f.guess >= 0:
		# The crew's prediction of the tanks at dawn goes into the logbook. It changes nothing in the mission.
		logb.pred += 1
		if f.guess == f.tanks:
			logb.pred_right += 1
		_log_save()
	exposure = f.expo
	tanks = f.tanks
	tanks_view = f.tanks
	world.set_mood("day")
	world.set_tanks(f.tanks)
	busy = false
	_go("f_result")

func _f_next() -> void:
	if f.sol >= F_SOLS:
		# The mission goes into the crew logbook.
		var sols: Array = []
		for e in f.log:
			sols.append([e.storm, e.job])
		var met := _f_met()
		logb.missions += 1
		logb.free += 1
		logb.free_met += 1 if met else 0
		logb.streak = 0 if met else logb.streak + 1
		if met:
			logb.hinted = false   # the Commander steps back; the hint can be offered again after two hard missions
		var stars := _f_stars()
		logb.stars += stars
		logb.best = maxi(logb.best, stars)
		logb.last.append({"met": met, "sols": sols})
		logb.last = logb.last.slice(-5)
		_log_save()
		_go("f_end")
		return
	f.sol += 1
	f.guess = -1
	_f_new_sol()
	_go("f_decide")

func _f_met() -> bool:
	return f.science and not f.low and snappedf(f.expo, 0.1) <= F_RAD_GOAL

## Harvest day, after sol 31: how many of the six plants are ready depends on the nights the lamp was on.
func _start_harvest() -> void:
	var p31: String = picks.get("plan", runs[0].choice)
	var dark := 0
	if carried != "b":
		dark += 1   # sol 30: the lamp was on that night only if the crew repaired the power
	if _p_after(p31) < 99.0:
		dark += 1   # sol 31
	hv = {"ready": 6 - 2 * dark, "dark": dark, "picked": [], "msg": ""}
	_log_add("missions")
	world.reset_scene()
	for run in runs:
		if run.choice == p31:
			power = run.power
			exposure = run.exposure
			tanks_view = run.tanks
	world.set_units_online(int(round(power / 25.0)))
	world.set_room_power(power / 100.0, false)
	world.set_tanks(tanks_view)
	world.set_harvest(_hv_states())
	_go("harvest")

func _hv_states() -> Array:
	var out: Array = []
	for i in range(6):
		out.append("gone" if hv.picked.has(i) else ("ready" if i < hv.ready else "small"))
	return out

## A tap on a plant: the ready ones are picked; the small ones stay.
func _hv_tap(i: int) -> void:
	if busy or state != "harvest" or hv.picked.has(i):
		return
	if i >= hv.ready:
		hv.msg = "small"
		_render()
		return
	hv.msg = ""
	hv.picked.append(i)
	world.set_harvest(_hv_states())
	world.work("eng", 0.4)
	if hv.picked.size() >= hv.ready:
		page = 1
	_render()

func _m_brief_next() -> void:
	if page == 0:
		_next_page()
	else:
		m_briefed = true
		page = 2
		_render()

## The Moon level is finished: back to the mission select, where Mars is now open.
func _moon_complete() -> void:
	moon.set_drop(false)
	moon_done = true
	_log_add("missions")
	_go("select")

## On the Moon the answer really takes 2.6 seconds: 1.3 there and 1.3 back.
func _m_ask() -> void:
	_go("m_ask")
	await _wait(2.6)
	if state == "m_ask" and page == 0:
		_next_page()

func _m_reserve_at(site: String) -> float:
	return O2_FULL - SITE_KM[site] / ROVER_KMH - WALK_BACK_H[site]

## The rover reached a rock site. Being far from the lander already costs reserve: the walk home is longer.
func _m_arrive(site: String, auto: bool) -> void:
	_set_busy(true)
	if auto:
		await moon.drive_to(site)
	m_site = site
	m_dug = []
	moon.spawn_rocks(site)
	_tween_var("oxygen", _m_reserve_at(site), 0.8)
	busy = false
	_go("m_collect")

func _m_rocks_left() -> Array:
	var left: Array = []
	if m_dug.size() < 3:
		for i in range(5):
			if not m_dug.has(i):
				left.append("rock%d" % i)
	return left

## The players choose a rock: science goes up, and the time it takes comes out of the oxygen reserve.
func _m_dig(i: int) -> void:
	if busy or state != "m_collect" or m_dug.has(i) or m_dug.size() >= 3:
		return
	if moon.rock_kind(i) == "white" and m_photo == null:
		m_pending = i   # the rare rock gets photographed where it lies before it is picked up
		_render()
		return
	_set_busy(true)
	m_pending = -1
	m_dug.append(i)
	_tween_var("science", science + ROCK_POINTS[moon.rock_kind(i)], 0.5)
	_tween_var("oxygen", oxygen - ROCK_WORK_H / 3.0, 0.5)
	await moon.collect_rock(i)
	busy = false
	if m_dug.size() == 3:
		await _m_leave()
	else:
		_render()

## The crew stops collecting (the bag holds three rocks, but fewer is allowed) and heads home.
func _m_leave() -> void:
	_set_busy(true)
	var sci := 0.0
	for i in m_dug:
		sci += ROCK_POINTS[moon.rock_kind(i)]
	m_final = {"oxygen": _m_reserve_at(m_site) - ROCK_WORK_H / 3.0 * m_dug.size(), "science": sci}
	await _wait(0.55)
	m_shot = await _capture()
	busy = false
	_go("m_return")

func _m_home(auto: bool) -> void:
	_set_busy(true)
	if auto:
		await moon.drive_to("lander")
	oxygen = m_final.oxygen
	science = m_final.science
	m_runs.append({"site": m_site, "oxygen": m_final.oxygen, "science": m_final.science, "shot": m_shot})
	busy = false
	_go("m_result")

## The other rock site, from the same start. It plays by itself.
func _m_retry() -> void:
	var other := "far" if m_runs[0].site == "near" else "near"
	_moon_reset()
	busy = true
	_go("m_auto")
	await moon.drive_to(other)
	m_site = other
	m_dug = []
	moon.spawn_rocks(other)
	_tween_var("oxygen", _m_reserve_at(other), 1.0)
	await _wait(0.6)
	for i in ([2, 0, 1] if other == "far" else [0, 1, 2]):
		m_dug.append(i)
		_tween_var("science", science + ROCK_POINTS[moon.rock_kind(i)], 0.4)
		_tween_var("oxygen", oxygen - ROCK_WORK_H / 3.0, 0.4)
		await moon.collect_rock(i)
		await _wait(0.25)
	await _m_leave()
	await _m_home(true)

func _reset_run() -> void:
	power = _p_start()
	exposure = 1.0
	votes = {"eng": "", "pro": ""}
	choice = ""
	job = {}
	tanks_view = tanks
	world.reset_scene()
	world.set_units_online(4 - _offline())
	world.set_room_power(power / 100.0, false)
	world.set_tanks(tanks)

## Solo or co-op is chosen once; then the players pick a mission.
func _set_players(n: int) -> void:
	players = n
	_go("select")

func _play_again() -> void:
	data_open = false
	_go("select")

func _job_role() -> String:
	return "pro" if choice == "a" else "eng"

func _helper_role() -> String:
	return "eng" if choice == "a" else "pro"

func _job_point() -> String:
	return "shelter" if choice == "a" else "power"

func _other_choice() -> String:
	return "b" if runs[0].choice == "a" else "a"

## Tells the scene what can be tapped, where to walk and which astronaut each player steers, for this moment.
func _sync_world() -> void:
	var marked: Array = []
	var silent: Array = []
	var goals: Array = []
	var ctl := {}
	if level == 0:
		var open: Array = []
		var locked: Array = ["asteroid", "more"]
		if state == "select" and not _overlay():
			open = ["moon", "mars"] if moon_done else ["moon"]
		if not moon_done:
			locked.append("mars")
		space.reduced_motion = world.reduced_motion
		if state == "to_mars" or state == "to_moon":
			# The trip plays behind the brief: Earth to the Moon, or the Moon to Mars.
			space.set_mode("travel_mars" if state == "to_mars" else "travel_moon", [], [])
		elif state != "cover":
			space.set_mode(state if (state == "title" or state == "select") else "", open, locked)
	if level == 1:
		var drive := false
		if not busy and not _overlay():
			match state:
				"m_drive":
					if m_briefed:
						marked = ["near", "far"]
						goals = ["near", "far"]
						drive = true
				"m_collect":
					marked = _m_rocks_left()
				"m_return":
					marked = ["lander"]
					goals = ["lander"]
					drive = true
		moon.reduced_motion = world.reduced_motion
		moon.set_tappable(marked)
		moon.set_goals(goals)
		moon.set_drive(drive)
		world.set_tappable([], [])
		world.set_goals([])
		world.set_controls({})
		return
	moon.reduced_motion = world.reduced_motion
	moon.set_tappable([])
	moon.set_goals([])
	moon.set_drive(false)
	if not busy and not _overlay():
		var roles: Array = []
		match state:
			"meet":
				if _meet_ready():
					roles = ["eng", "pro"]
					for r in roles:
						if not reported[r]:
							marked.append(r + "_console")
							goals.append(r + "_console")
				elif page >= 1:
					marked = [["power_look", "oxygen", "shelter_look"][page - 1]]   # the narrator points at what it names
			"harvest":
				marked = ["greenhouse"]
			"ask_earth":
				roles = ["eng", "pro"]
				marked = ["dish"]
				goals = ["dish_pt"]
			"go_job":
				roles = [_job_role()]
				marked = [_job_point()]
				goals = [_job_point()]
			"result":
				if page == 1:
					marked = ["greenhouse"]   # an arrow points at the plants the next morning
		if not roles.is_empty():
			if players == 2:
				for r in roles:
					ctl[r] = "wasd" if r == "eng" else "arrows"
			else:
				if not roles.has(active):
					active = roles[0]
				ctl[active] = "both"
				silent = roles
	if start != "a" and state != "harvest":
		marked = []   # after sol 30: no arrows, only the rings on the floor
	world.set_tappable(marked, silent)
	world.set_goals(goals)
	world.set_controls(ctl)

## Walking an astronaut onto a spot does the same as tapping it.
func _check_zones() -> void:
	if busy or _overlay() or _dirty:
		return
	match state:
		"m_drive":
			if not m_briefed:
				return
			for site in ["near", "far"]:
				if moon.dist(site) < 0.9:
					_m_arrive(site, false)
					return
			if not m_limit and moon.at_limit():
				m_limit = true
				_render()
		"m_return":
			if moon.dist("lander") < 1.0:
				_m_home(false)
		"meet":
			for r in ["eng", "pro"]:
				if _meet_ready() and not reported[r] and world.dist(r, r + "_console") < 0.4:
					_open_role(r)
					return
		"ask_earth":
			for r in ["eng", "pro"]:
				if world.dist(r, "dish_pt") < 0.8:
					_send_message(r)
					return
		"go_job":
			if world.dist(_job_role(), _job_point()) < 0.55:
				_arrive_job()

func _on_tapped(id: String) -> void:
	if busy or _overlay():
		return
	match id:
		"moon":
			if state == "select":
				_start_moon()
		"mars":
			if state == "select" and moon_done:
				_go("to_mars")
		"near", "far":
			if state == "m_drive" and m_briefed:
				_m_arrive(id, true)
		"lander":
			if state == "m_return":
				_m_home(true)
		"rock0", "rock1", "rock2", "rock3", "rock4":
			_m_dig(int(id.substr(4)))
		"eng", "pro":
			if players == 1 and active != id:
				active = id
				_sync_world()
		"eng_console", "pro_console":
			var r := id.substr(0, 3)
			if state == "meet" and _meet_ready() and not reported[r]:
				_open_role(r)
		"dish":
			if state == "ask_earth":
				_send_message(_nearest("dish_pt"))
		"shelter", "power":
			if state == "go_job" and id == _job_point():
				_arrive_job()

func _unhandled_input(e: InputEvent) -> void:
	if state == "title" and not _overlay():
		# Any key or click starts the game.
		if (e is InputEventKey and e.pressed and not e.echo) or (e is InputEventMouseButton and e.pressed):
			get_viewport().set_input_as_handled()
			_go("players")
		return
	if e is InputEventKey and e.pressed and not e.echo:
		_finish_typing()
	if not (e is InputEventKey and e.pressed and not e.echo) or busy or _overlay():
		return
	if state == "select" and e.physical_keycode == KEY_U:
		moon_done = true   # presenter shortcut: unlock Mars without playing the Moon
		_render()
		return
	if players == 1 and (e.physical_keycode == KEY_SPACE or e.physical_keycode == KEY_Q):
		active = "pro" if active == "eng" else "eng"
		_sync_world()

func _nearest(point: String) -> String:
	if players == 1:
		return active
	return "eng" if world.dist("eng", point) <= world.dist("pro", point) else "pro"

func _open_role(r: String) -> void:
	_set_busy(true)
	await world.walk(r, r + "_console")
	busy = false
	# Protection's console is the NASA terminal: the storm report comes after the live request.
	_go("p_term" if r == "pro" else "role_" + r)

## One web request. Returns [worked, body].
func _http_get(url: String, timeout := 9.0) -> Array:
	if live_off:
		return [false, PackedByteArray()]
	var req := HTTPRequest.new()
	req.timeout = timeout
	add_child(req)
	if req.request(url) != OK:
		req.queue_free()
		return [false, PackedByteArray()]
	var res: Array = await req.request_completed
	req.queue_free()
	return [res[0] == HTTPRequest.RESULT_SUCCESS and res[1] == 200, res[3]]

## Asks NASA DONKI for the solar particle events of the last 60 days.
func _fetch_donki() -> Dictionary:
	var now := Time.get_unix_time_from_system()
	var url := DONKI_URL % [Time.get_date_string_from_unix_time(int(now - 59 * 86400)), Time.get_date_string_from_unix_time(int(now)), nasa_key]
	var r: Array = await _http_get(url)
	if not r[0]:
		return {"ok": false}
	var d = JSON.parse_string((r[1] as PackedByteArray).get_string_from_utf8())
	if not (d is Array):
		return {"ok": false}
	var days := {}
	var latest := ""
	for e in d:
		if e is Dictionary:
			var tm := str(e.get("eventTime", ""))
			if tm.length() >= 10:
				days[tm.substr(0, 10)] = true
				if tm > latest:
					latest = tm
	return {"ok": true, "records": d.size(), "days": days.size(), "latest": latest}

## Downloads one real Apollo 15 photo and its caption from the NASA Image and Video Library.
func _fetch_photo() -> Dictionary:
	var m: Array = await _http_get(PHOTO_META_URL)
	if not m[0]:
		return {"ok": false}
	var out := {"ok": false, "date": "1971-07-31", "title": ""}
	var j = JSON.parse_string((m[1] as PackedByteArray).get_string_from_utf8())
	if j is Dictionary and j.has("collection"):
		var items = j["collection"].get("items", [])
		if items is Array and not items.is_empty():
			var data = items[0].get("data", [])
			if data is Array and not data.is_empty():
				out.title = str(data[0].get("title", ""))
				var dc := str(data[0].get("date_created", ""))
				if dc.length() >= 10:
					out.date = dc.substr(0, 10)
	var p: Array = await _http_get(PHOTO_URL)
	if p[0]:
		var img := Image.new()
		if img.load_jpg_from_buffer(p[1]) == OK:
			out["tex"] = ImageTexture.create_from_image(img)
			out.ok = true
	return out

## The player presses the terminal's button: the request goes out while the steps show on screen.
func _term_run(kind: String) -> void:
	term[kind] = {"step": 1}
	_render()
	var t0 := Time.get_ticks_msec()
	var now := Time.get_time_string_from_system().substr(0, 5)
	var result: Dictionary = {}
	var again: bool = kind == "mars" and start == "c"   # the bonus sol is about today: it asks NASA again
	if _live.has(kind) and not again:
		result = (_live[kind] as Dictionary).duplicate()   # already fetched this session: do not ask NASA twice
		result["cached"] = true
	elif kind == "mars":
		result = await _fetch_donki()
		if result.get("ok", false):
			result["at"] = now
			if _live.has(kind) and (_live[kind] as Dictionary).has("tex"):
				result["tex"] = _live[kind].tex
			else:
				var pic: Array = await _http_get(STORM_PIC_URL)
				if pic[0]:
					var img := Image.new()
					if img.load_jpg_from_buffer(pic[1]) == OK:
						result["tex"] = ImageTexture.create_from_image(img)
		elif _live.has(kind):
			result = (_live[kind] as Dictionary).duplicate()   # NASA did not answer again: the answer from earlier in this session
			result["cached"] = true
	else:
		result = await _fetch_photo()
		if result.get("ok", false):
			result["at"] = now
	if result.get("ok", false) and not result.get("cached", false):
		_live[kind] = result.duplicate()
	await _wait(max(0.0, 2.6 - (Time.get_ticks_msec() - t0) / 1000.0))   # long enough to read the steps
	result["step"] = 2
	if not result.has("at"):
		result["at"] = now
	term[kind] = result
	if kind == "mars":
		_sun_read()
	_render()

func _tell(role: String) -> void:
	reported[role] = true
	if reported.eng and reported.pro:
		_go("ask_earth" if start == "a" else "decide")
	else:
		_go("meet")

## "Another storm": a new morning where the other job meets the goals.
func _start_b() -> void:
	carried = picks.get("plan", runs[0].choice)   # sol 31 follows the plan the crew picked on the comparison
	for run in runs:
		if run.choice == carried:
			tanks = run.tanks   # the tanks that plan left for this morning
	start = "b"
	runs = []
	reported = {"eng": false, "pro": false}
	picks.erase("predict")
	picks.erase("plan")
	_reset_run()
	_go("meet")

func _send_message(r: String) -> void:
	_set_busy(true)
	await world.walk(r, "dish_pt")
	await world.send_message()
	busy = false
	_go("earth_q")
	if not m_runs.is_empty():
		page = 1   # the players already felt the 2.6 seconds on the Moon: go straight to the 40-against-30 question

func _guess(g: String) -> void:
	earth_guess = g
	_render()

## Each role votes for a job. A player alone votes for both roles with one tap.
func _vote(role: String, id: String) -> void:
	votes[role] = id
	if players == 1:
		votes = {"eng": id, "pro": id}
	_render()

func _wait(sec: float) -> void:
	if world.reduced_motion:
		return
	await get_tree().create_timer(sec).timeout

func _tween_var(prop: String, to: float, dur: float) -> void:
	if world.reduced_motion:
		set(prop, to)
		return
	create_tween().tween_property(self, prop, to, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

## The crew agreed on a job. The first time the players walk there and do it; the retry plays by itself.
func _start_job(c: String) -> void:
	choice = c
	job = {}
	if runs.is_empty():
		active = _job_role()
		_go("go_job")
	else:
		_auto_job()

## The lead astronaut reached the job. The other one comes to help: each job needs both.
func _arrive_job() -> void:
	_set_busy(true)
	await world.walk_both(_job_role(), _job_point(), _helper_role(), _job_point() + "_help")
	# The second storm is harder: one more wire to match, or more gaps than water bags.
	var hard: bool = start == "b"
	if choice == "b":
		var n := 4 if hard else 3
		var order: Array = range(n)
		order.shuffle()
		if order == range(n):
			order.reverse()
		job = {"n": n, "order": order, "done": [], "sel": -1}
	else:
		job = {"slots": 8 if hard else 6, "rays": [1, 2, 3, 4, 6, 7] if hard else [0, 1, 2, 3, 4, 5], "bags": [], "stock": 6, "shown": 0}
	busy = false
	_go("do_job")

## Rewiring: the player picks a plug.
func _wire_pick(i: int) -> void:
	if busy or state != "do_job" or job.done.has(i):
		return
	job.sel = i
	_render()

## Rewiring: the player picks a socket. The right one connects; a wrong one just lets go of the plug.
func _wire_plug(slot: int) -> void:
	if busy or state != "do_job" or job.sel < 0:
		return
	if job.order[slot] != job.sel:
		job.sel = -1
		_render()
		return
	_set_busy(true)
	job.done.append(job.sel)
	job.sel = -1
	_render()
	var last: bool = job.done.size() == job.n
	world.work(_job_role() if job.done.size() % 2 == 1 else _helper_role(), 0.5)
	await world.repair_step(4 - _offline(), 2 if last else 0)
	if last:
		await _after_job()
	else:
		busy = false
		_render()

func _rays_blocked() -> int:
	var n := 0
	for r in job.rays:
		if job.bags.has(r):
			n += 1
	return n

## Shielding: the player puts a water bag in a gap, or picks one back up. Each blocked ray is less storm inside.
func _bag_tap(slot: int) -> void:
	if busy or state != "do_job":
		return
	if job.bags.has(slot):
		job.bags.erase(slot)
		_render()
		return
	if job.bags.size() >= job.stock:
		return
	_set_busy(true)
	job.bags.append(slot)
	_render()
	var blocked := _rays_blocked()
	world.work(_job_role() if job.bags.size() % 2 == 1 else _helper_role(), 0.4)
	while job.shown < blocked / 2:
		await world.reinforce_step(job.shown)   # the real shelter fills up as the rays get blocked
		job.shown += 1
	if blocked == job.rays.size():
		await _wait(0.5)
		await _after_job()
	else:
		busy = false
		_render()

## The retry: the same job as a short film, without the little game.
func _auto_job() -> void:
	busy = true
	_go("act_work")
	await world.walk_both(_job_role(), _job_point(), _helper_role(), _job_point() + "_help")
	for step in range(3):
		world.work(_job_role() if step % 2 == 0 else _helper_role(), 0.5)
		if choice == "a":
			await world.reinforce_step(step)
		else:
			await world.repair_step(4 - _offline(), step)
		await _wait(0.35)
	await _after_job()

## The job is done. The storm arrives and everyone goes to the shelter.
func _after_job() -> void:
	busy = true
	if choice == "b":
		_tween_var("power", _p_after("b"), 0.7)
		world.set_room_power(_p_after("b") / 100.0)
	await _wait(0.8)
	if _storm_msv() <= 0.0:
		# No storm today: the crew goes to its bunks and the night passes.
		await world.walk_both("eng", "shelter_a", "pro", "shelter_b")
		await _advance()
		return
	_go("act_storm")
	world.set_mood("storm")
	world.set_storm(true)
	await world.walk_both("eng", "shelter_a", "pro", "shelter_b")
	busy = false
	_go("storm")

## One sol passes: night falls, and the Radiation bar climbs while the storm passes.
func _advance() -> void:
	busy = true
	_go("act_night")
	world.set_mood("night")
	await _wait(0.8)
	tanks_view = maxi(tanks - TANKS_USED, 0)   # the tanks the crew breathed today are empty
	world.set_tanks(tanks_view)
	_render()
	if _storm_msv() > 0.0:
		_tween_var("exposure", _x_after(choice), 3.0)   # slow on purpose: the players watch the storm add up
		await _wait(3.4)
		world.set_storm(false)
		await _wait(0.9)
	else:
		await _wait(1.6)
	var shot: Texture2D = await _capture()
	runs.append({"choice": choice, "power": _p_after(choice), "exposure": _x_after(choice), "shot": shot, "tanks": _tanks_after(choice), "made": _tanks_made(_p_after(choice))})
	power = runs[-1].power
	exposure = runs[-1].exposure
	if runs.size() == 2 and picks.get("predict", "") != "":
		# The replay's prediction: more or less radiation than the first job?
		logb.pred += 1
		if picks["predict"] == ("more" if runs[1].exposure > runs[0].exposure else "less"):
			logb.pred_right += 1
		_log_save()
	if start == "c":
		_log_add("missions")
	if runs.size() == 1:
		# Stars for the crew's own plan on this sol: one for each goal met. Replays do not add stars.
		_log_add("stars", (1 if runs[0].power >= GOAL_POWER else 0) + (1 if snappedf(runs[0].exposure, 0.1) <= GOAL_RAD else 0))
	busy = false
	_go("result")

## Morning comes: plants that had no lamp are small and pale, plants that had it are tall and green.
func _to_morning() -> void:
	world.set_mood("day")
	world.set_plants("strong" if runs[-1].power >= 100.0 else "weak")
	tanks_view = runs[-1].tanks   # what the oxygen machine filled overnight
	world.set_tanks(tanks_view)
	_next_page()

## Runs a replay without its animations, for players who do not want to watch it.
func _fast(what: Callable) -> void:
	var keep: bool = world.reduced_motion
	world.reduced_motion = true
	moon.reduced_motion = true
	await what.call()
	world.reduced_motion = keep
	moon.reduced_motion = keep
	_render()

func _skip_m_retry() -> void:
	await _fast(_m_retry)

func _skip_retry() -> void:
	_reset_run()
	picks["predict"] = picks.get("predict", "")
	await _fast(func():
		choice = _other_choice()
		await _auto_job()
		await _advance())

func _retry() -> void:
	_reset_run()
	_go("retry_intro")

func _pick(q: String, option: String) -> void:
	picks[q] = option
	_render()

func _finish() -> void:
	mars_done = true
	data_open = true
	_go("end")

func _open_data() -> void:
	data_open = true
	_render()

func _close_data() -> void:
	data_open = false
	_render()

func _open_settings() -> void:
	settings_open = true
	_render()

func _close_settings() -> void:
	settings_open = false
	_render()

func _toggle_lang() -> void:
	lang = "es" if lang == "en" else "en"
	_render()

func _toggle_motion() -> void:
	world.reduced_motion = not world.reduced_motion
	UI.reduced = world.reduced_motion
	_render()

func _toggle_sources() -> void:
	show_src = not show_src
	_render()

func _toggle_voice() -> void:
	voice_on = not voice_on
	if voice_on:
		_spoken = ""   # read the current line aloud
	elif DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		DisplayServer.tts_stop()
	_render()

## Optional read-aloud for early readers, with the device's own speech voices. Off by default.
func _speak(text: String, who := "cmd", again := true) -> void:
	if not voice_on or not DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		return
	var voice := _pick_voice()
	if voice == "":
		# Browsers load their voices a moment after the page opens: try once more shortly.
		if again:
			await get_tree().create_timer(0.6).timeout
			_speak(text, who, false)
		return
	# Each character has its own pitch and pace, so the crew does not sound like one person.
	var tone: Array = VOICE_TONE.get(who, [1.0, 1.0])
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(text.replace("\n", " "), voice, 70, tone[0], tone[1])

## The device's best voice for the game's language: Mexican or Latin American Spanish first, US English first.
func _pick_voice() -> String:
	var want: Array = ["es-MX", "es-US", "es-419", "es-ES", "es"] if lang == "es" else ["en-US", "en-GB", "en"]
	var all: Array = DisplayServer.tts_get_voices()
	for code in want:
		for v in all:
			var loc := str(v.get("language", "")).replace("_", "-")
			if loc == code or (code.length() == 2 and loc.begins_with(code)):
				return str(v.get("id", ""))
	var any := DisplayServer.tts_get_voices_for_language("es" if lang == "es" else "en")
	return any[0] if not any.is_empty() else ""

## A photo of one spot in the scene (the UI is hidden for that one frame).
func _capture_at(cam: Camera3D, at: Vector3) -> Texture2D:
	var blank := ImageTexture.create_from_image(Image.create(8, 6, false, Image.FORMAT_RGB8))
	if DisplayServer.get_name() == "headless":
		return blank
	ui.visible = false
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	ui.visible = true
	if img == null or img.is_empty():
		return blank
	var k: float = img.get_width() / get_viewport().get_visible_rect().size.x
	var c: Vector2 = cam.unproject_position(at) * k
	var w := int(300 * k)
	var h := int(200 * k)
	var r := Rect2i(int(clampf(c.x - w * 0.45, 0, img.get_width() - w)), int(clampf(c.y - h * 0.6, 0, img.get_height() - h)), w, h)
	img = img.get_region(r)
	img.resize(300, 200, Image.INTERPOLATE_BILINEAR)
	return ImageTexture.create_from_image(img)

## A picture of the room for the side-by-side comparison (the UI is hidden for that one frame).
func _capture() -> Texture2D:
	if DisplayServer.get_name() == "headless":
		return null
	ui.visible = false
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	ui.visible = true
	if img == null or img.is_empty():
		return null
	var w := img.get_width()
	var h := img.get_height()
	var r := Rect2i(0, int(h * 0.26), w, int(h * 0.40))
	img = img.get_region(r)
	img.resize(960, int(960.0 * r.size.y / r.size.x), Image.INTERPOLATE_BILINEAR)
	return ImageTexture.create_from_image(img)

# ---------------------------------------------------------------- drawing the screen

func _rebuild() -> void:
	var id_now := state + ":" + str(page)
	for c in ui.get_children():
		ui.remove_child(c)
		if id_now != _drawn and not world.reduced_motion and c.has_meta("fx"):
			ghosts.add_child(c)
			c.propagate_call("set_mouse_filter", [IGNORE])
			var out := c.create_tween()
			out.tween_property(c, "modulate:a", 0.0, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			out.tween_callback(c.queue_free)
		else:
			c.queue_free()
	_tip_hide()
	_typing = null
	_val_seen = ["", ""]
	_fills = []
	_vals = []
	_sync_world()
	var id := state + ":" + str(page)
	_fresh = id != _drawn
	_drawn = id
	if state == "title":
		_r_title()
	elif state == "players":
		_r_players()
	elif state == "select":
		_r_select()
	elif state == "poster":
		_r_poster()
	elif state == "cover":
		_r_cover()
	else:
		_r_hud()
		match state:
			"m_card":
				_r_m_card()
			"m_term":
				_r_terminal("moon")
			"p_term":
				_r_terminal("mars")
			"m_deploy":
				_r_m_deploy()
			"m_drop":
				_r_m_drop()
			"m_drive":
				_r_m_drive()
			"m_ask":
				_r_m_ask()
			"m_collect":
				_r_m_collect()
			"m_return":
				_talk("mc", t("mc_return")).add_child(UI.label(t("m_keys_back"), 19, UI.SOFT))
			"m_auto":
				_talk("mc", t("mc_auto"))
			"m_result":
				_r_m_result()
			"m_compare":
				_r_m_compare()
			"to_mars":
				_r_to_mars()
			"to_moon":
				_r_to_moon()
			"meet":
				_r_meet()
			"role_eng":
				_r_role("eng")
			"role_pro":
				_r_role("pro")
			"ask_earth":
				_hint(_talk("cmd", t("cmd_ask")))
			"earth_q":
				if page == 0:
					_r_far()
				else:
					_r_earth()
			"decide":
				_r_decide()
			"go_job":
				_hint(_talk("cmd", t("cmd_go_" + choice)))
			"do_job":
				_r_job()
			"act_work":
				_talk("cmd", t("act_" + choice))
			"act_storm":
				_talk("cmd", t("storm_arrives"))
			"storm":
				_r_storm()
			"act_night":
				_talk("cmd", t("night") if _storm_msv() > 0.0 else t("night_calm"))
			"harvest":
				_r_harvest()
			"f_intro":
				_r_f_intro()
			"f_hint":
				_r_f_hint()
			"f_decide":
				_r_f_decide()
			"f_act":
				_talk("cmd", t("act_" + choice))
			"f_storm":
				_talk("cmd", t("storm_arrives"))
			"f_night":
				_talk("cmd", t("f_night"))
			"f_result":
				_r_f_result()
			"f_end":
				_r_f_end()
			"result":
				_r_result()
			"retry_intro":
				_r_retry()
			"compare":
				_r_compare()
			"debrief":
				_r_debrief()
	if data_open:
		_r_data()
	if settings_open:
		_r_settings()
	if logbook_open:
		_r_logbook()

func _full(node: Control) -> Control:
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	node.mouse_filter = IGNORE
	ui.add_child(node)
	return node

func _margins(all: int) -> MarginContainer:
	var m := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		m.add_theme_constant_override(side, all)
	return m

func _centered(l: Label) -> Label:
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _role_icon(role: String) -> String:
	return "gears.svg" if role == "eng" else "energy-shield.svg"

func _speaker_name(who: String) -> String:
	return t("earth") if who == "earth" else t("role_" + who)

## The speaker's live 3D portrait on a rounded tile.
func _portrait(who: String, px: int) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = (SPEAKER_COL[who] as Color).darkened(0.45)
	sb.set_corner_radius_all(px / 6)
	sb.set_border_width_all(4)
	sb.border_color = SPEAKER_COL[who]
	p.add_theme_stylebox_override("panel", sb)
	p.custom_minimum_size = Vector2(px, px)
	p.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	p.mouse_filter = IGNORE
	var r := TextureRect.new()
	r.texture = portraits[who].vp.get_texture()
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.mouse_filter = IGNORE
	p.add_child(r)
	return p

func _pill(text: String, col: Color, size := 21) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 1
	sb.content_margin_bottom = 3
	p.add_theme_stylebox_override("panel", sb)
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	p.mouse_filter = IGNORE
	p.add_child(UI.title(text, size, UI.INK))
	return p

func _name_tag(who: String) -> PanelContainer:
	var p := _pill(_speaker_name(who), SPEAKER_COL[who])
	p.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	return p

## Types a line out once, and reads it aloud if the voice is on.
func _say(l: Label, who: String, speech := "") -> void:
	var key := state + ":" + str(page) + ":" + lang + ":" + who
	if _spoken == key:
		return
	_spoken = key
	_speak(speech if speech != "" else l.text, who)
	if not world.reduced_motion:
		l.visible_ratio = 0.0
		_typing = l
		_type_tw = l.create_tween()
		_type_tw.tween_property(l, "visible_ratio", 1.0, clampf(l.text.length() / 50.0, 0.4, 2.6))

## A tap or a key finishes the line that is being typed out.
func _finish_typing() -> void:
	if _typing != null and is_instance_valid(_typing) and _typing.visible_ratio < 1.0:
		if _type_tw != null and _type_tw.is_valid():
			_type_tw.kill()
		_typing.visible_ratio = 1.0
	_typing = null

## A box eases in: it fades, rises a little and grows from 96% to full size.
func _pop_in(p: Control, from_bottom: bool) -> void:
	p.modulate.a = 0.0
	p.scale = Vector2(0.96, 0.96)
	p.resized.connect(func(): p.pivot_offset = Vector2(p.size.x * 0.5, p.size.y if from_bottom else p.size.y * 0.5))
	var tw := p.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(p, "modulate:a", 1.0, 0.24)
	tw.tween_property(p, "scale", Vector2.ONE, 0.26)

## A small arrow that drifts sideways next to a "Next" button: there is more to read.
func _next_cue() -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(40, 60)
	c.mouse_filter = IGNORE
	var a := UI.ui_icon("Yellow/Default/arrow_basic_e.png", Color.WHITE, 30)
	a.position = Vector2(2, 15)
	a.size = Vector2(30, 30)
	c.add_child(a)
	if not world.reduced_motion:
		var tw := a.create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(a, "position:x", 6.0, 0.6)
		tw.tween_property(a, "position:x", 2.0, 0.6)
	return c

## A hover tip: after a short pause it fades in and rises beside the thing being pointed at, never on top of it.
func _tip(c: Control, text: String) -> void:
	c.mouse_entered.connect(func(): _tip_show(c, text))
	c.mouse_exited.connect(_tip_hide)

func _tip_show(c: Control, text: String) -> void:
	_tip_for = c
	await get_tree().create_timer(0.3).timeout
	if _tip_for != c or not is_instance_valid(c) or not c.is_inside_tree():
		return
	_tip_drop()
	var p := UI.panel(Color(0.99, 0.96, 0.90, 0.98), 12, 10)
	p.mouse_filter = IGNORE
	p.add_child(UI.label(text, 19, UI.INK, UI.bold_font()))
	p.modulate.a = 0.0
	tips.add_child(p)
	_tip_node = p
	await get_tree().process_frame
	if _tip_node != p or not is_instance_valid(c) or not c.is_inside_tree():
		return
	var r := c.get_global_rect()
	var view := tips.size
	var x: float = clampf(r.position.x + r.size.x * 0.5 - p.size.x * 0.5, 8.0, view.x - p.size.x - 8.0)
	var y: float = r.position.y - p.size.y - 10.0
	if y < 8.0:
		y = r.end.y + 10.0
	if world.reduced_motion:
		p.position = Vector2(x, y)
		p.modulate.a = 1.0
		return
	p.position = Vector2(x, y + 8.0)
	var tw := p.create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)
	tw.tween_property(p, "modulate:a", 1.0, 0.15)
	tw.tween_property(p, "position:y", y, 0.15)

func _tip_drop() -> void:
	if _tip_node != null and is_instance_valid(_tip_node):
		var old := _tip_node
		if world.reduced_motion:
			old.queue_free()
		else:
			var tw := old.create_tween()
			tw.tween_property(old, "modulate:a", 0.0, 0.1)
			tw.tween_callback(old.queue_free)
	_tip_node = null

func _tip_hide() -> void:
	_tip_for = null
	_tip_drop()

## The dialogue box along the bottom: portrait, name and one spoken line. Returns the box to add more to.
func _talk(who: String, text: String, speech := "") -> VBoxContainer:
	var m := _margins(14)
	m.add_theme_constant_override("margin_right", BARS_W + 28)
	_full(m)
	m.set_meta("fx", true)
	var p := UI.panel(BOX, 24, 18)
	p.size_flags_vertical = Control.SIZE_SHRINK_END
	p.gui_input.connect(func(e: InputEvent): if e is InputEventMouseButton and e.pressed: _finish_typing())
	m.add_child(p)
	var h := UI.hbox(18)
	p.add_child(h)
	var face := _portrait(who, 150)
	h.add_child(face)
	var v := UI.vbox(8)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)
	v.add_child(_name_tag(who))
	var lead := UI.label(text, 27, UI.PAPER, null, 1100)
	v.add_child(lead)
	_say(lead, who, speech)
	if _fresh and not world.reduced_motion:
		_pop_in(p, true)
		face.pivot_offset = Vector2(75, 75)
		face.scale = Vector2(0.6, 0.6)
		var tw := p.create_tween().set_parallel(true)
		tw.tween_method(func(val: float): m.add_theme_constant_override("margin_bottom", int(val)), -8.0, 14.0, 0.26).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(face, "scale", Vector2.ONE, 0.34).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return v

## A centred card over a dimmed room, for the moments that need full attention.
func _modal(width := 1100, dim_alpha := 0.72) -> VBoxContainer:
	var dim := ColorRect.new()
	dim.color = Color(0.04, 0.03, 0.08, dim_alpha)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(dim)
	var cc := CenterContainer.new()
	_full(cc)
	cc.set_meta("fx", true)
	var p := UI.panel(UI.NAVY, 26, 28)
	p.custom_minimum_size.x = width
	p.gui_input.connect(func(e: InputEvent): if e is InputEventMouseButton and e.pressed: _finish_typing())
	cc.add_child(p)
	var inner := UI.vbox(14)
	p.add_child(inner)
	if _fresh and not world.reduced_motion:
		_pop_in(p, false)
	return inner

## The narrator speaking at the top of a centred card.
func _modal_head(v: VBoxContainer, who: String, text: String, size := 34, wrap_w := 900, small := "") -> void:
	var h := UI.hbox(18)
	v.add_child(h)
	h.add_child(_portrait(who, 104))
	var tv := UI.vbox(4)
	tv.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(tv)
	var top := UI.hbox(12)
	tv.add_child(top)
	top.add_child(_name_tag(who))
	if small != "":
		top.add_child(UI.label(small, 19, UI.SOFT, UI.bold_font()))
	var l := UI.title(text, size, UI.PAPER, wrap_w)
	tv.add_child(l)
	_say(l, who)

## One line of information. The tag that says where its number comes from shows only if the player asks for it.
func _fact(text: String, kind := "", lead: Control = null, size := 24, wrap_w := 600) -> HBoxContainer:
	var h := UI.hbox(10)
	if lead != null:
		h.add_child(lead)
	else:
		h.add_child(UI.label("•", size, UI.SOFT))
	h.add_child(UI.label(text, size, UI.PAPER, null, wrap_w))
	if kind != "" and show_src:
		h.add_child(UI.chip(t("chip_" + kind), kind))
	return h

## How to move, under the narrator's line.
func _hint(v: VBoxContainer) -> void:
	if level == 2 and (start != "a" or not runs.is_empty()):
		return   # by now the players know how to move
	v.add_child(UI.label(t("keys_%d" % players), 19, UI.SOFT, null, 1100))

func _next_row(v: VBoxContainer) -> void:
	var row := UI.hbox(0)
	v.add_child(row)
	row.add_child(UI.spacer())
	row.add_child(_next_cue())
	row.add_child(UI.button(t("btn_next"), _next_page, "Blue", 26))

func _r_hud() -> void:
	var m := _margins(14)
	_full(m)
	var row := UI.hbox(14)
	row.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	m.add_child(row)
	# What each role has told the crew, until the crew decides.
	var notes := UI.vbox(8)
	row.add_child(notes)
	if not MODAL_STATES.has(state):
		var sol_tag := t("level_bonus") if start == "c" else t("level_sol").format({"n": 31 if start == "b" else 30})
		if state == "harvest":
			sol_tag = t("level_harvest")
		if start == "f":
			sol_tag = t("level_free").format({"n": f.sol})
		var tag := _pill(sol_tag if level == 2 else t("level_1"), UI.PAPER, 18)
		tag.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		notes.add_child(tag)
	if NOTE_STATES.has(state):
		for r in ["eng", "pro"]:
			if reported[r]:
				notes.add_child(_note(r, 400))
	row.add_child(UI.spacer())
	var btns := UI.hbox(8)
	btns.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_child(btns)
	var tipped: Array = [[UI.button(t("btn_data"), _open_data, "Grey", 19), "tip_data"], [UI.button(t("btn_settings"), _open_settings, "Grey", 19), "tip_settings"], [UI.button(t("lang_button"), _toggle_lang, "Yellow", 19), "tip_lang"]]
	for pair in tipped:
		btns.add_child(pair[0])
		_tip(pair[0], t(pair[1]))
	if OS.get_cmdline_user_args().has("--tip"):
		_tip_show(tipped[1][0], t("tip_settings"))   # development: show one tip without a pointer
	if MODAL_STATES.has(state):
		return
	# The two bars float in the bottom-right corner, with no box behind them.
	var bm := _margins(14)
	_full(bm)
	if level == 1:
		# On the Moon the yellow walk-back line runs behind the bars: a faint backing keeps their text readable.
		var back := Panel.new()
		var bs := StyleBoxFlat.new()
		bs.bg_color = Color(0.09, 0.08, 0.15, 0.55)
		bs.set_corner_radius_all(16)
		back.add_theme_stylebox_override("panel", bs)
		back.custom_minimum_size = Vector2(BARS_W + 8, 262)
		back.size_flags_horizontal = Control.SIZE_SHRINK_END
		back.size_flags_vertical = Control.SIZE_SHRINK_END
		back.mouse_filter = IGNORE
		bm.add_child(back)
	var bars := MarginContainer.new()
	bars.size_flags_horizontal = Control.SIZE_SHRINK_END
	bars.size_flags_vertical = Control.SIZE_SHRINK_END
	bars.custom_minimum_size.x = BARS_W
	bars.mouse_filter = IGNORE
	bm.add_child(bars)
	var focus := _brief_focus()
	var stack := UI.vbox(10)
	stack.alignment = BoxContainer.ALIGNMENT_END
	stack.mouse_filter = IGNORE
	bars.add_child(stack)
	if level == 2:
		stack.add_child(_tank_strip(focus == 2))
	var cols := UI.hbox(4)
	cols.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_child(cols)
	var specs := _bar_specs()
	var tip_keys: Array = ["tip_oxygen", "tip_science"] if level == 1 else ["tip_power", "tip_rad"]
	for i in range(2):
		var col := _bar_col(specs[i], i == 1 and level == 2 and state == "act_night" and _storm_msv() > 0.0, focus == i)
		col.mouse_filter = Control.MOUSE_FILTER_STOP   # so the bar can show its tip
		_tip(col, t("tip_rad_f") if (i == 1 and level == 2 and start == "f") else t(tip_keys[i]))
		cols.add_child(col)

## A yellow arrow that bobs above the thing the narrator is naming.
func _point_cue() -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(40, 46)
	c.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	c.mouse_filter = IGNORE
	var a := UI.ui_icon("Yellow/Default/arrow_basic_s.png", Color.WHITE, 36)
	a.position = Vector2(2, 0)
	a.size = Vector2(36, 36)
	c.add_child(a)
	if not world.reduced_motion:
		var tw := a.create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(a, "position:y", 8.0, 0.6)
		tw.tween_property(a, "position:y", 0.0, 0.6)
	return c

## Mars: the base's four oxygen tanks, above the bars. Full ones are lit.
func _tank_strip(pointed: bool) -> VBoxContainer:
	var edge := Color(0.08, 0.06, 0.12)
	var v := UI.vbox(3)
	v.mouse_filter = Control.MOUSE_FILTER_STOP
	_tip(v, t("tip_tanks"))
	if pointed:
		v.add_child(_point_cue())
	var row := UI.hbox(6)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = IGNORE
	v.add_child(row)
	for i in range(TANKS_FULL):
		var cap := Panel.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = COL_O2 if i < tanks_view else Color(0.09, 0.08, 0.15, 0.7)
		sb.set_corner_radius_all(8)
		sb.set_border_width_all(3)
		sb.border_color = Color(0.86, 0.95, 1.0) if i < tanks_view else Color(1, 1, 1, 0.45)
		cap.add_theme_stylebox_override("panel", sb)
		cap.custom_minimum_size = Vector2(22, 36)
		cap.mouse_filter = IGNORE
		row.add_child(cap)
	if start == "f":
		# The mission's rock sample: a star that lights up when it is on board.
		var star := UI.ui_icon("Yellow/Default/star.png", Color.WHITE if f.science else Color(1, 1, 1, 0.25), 34)
		star.mouse_filter = IGNORE
		row.add_child(star)
	var name_l := UI.outlined(_centered(UI.bold(t("tanks_name"), 14)), 6, edge)
	name_l.mouse_filter = IGNORE
	v.add_child(name_l)
	return v

## The two things each level asks the players to balance.
func _bar_specs() -> Array:
	if level == 1:
		return [
			{"icon": "astronaut-helmet.svg", "col": COL_O2, "frac": oxygen / O2_FULL, "val": ("%.1f" % oxygen).trim_suffix(".0") + " h", "of": t("of_oxygen"), "name": t("bar_oxygen"), "tip": t("bar_oxygen_tip_min") if ["m_return", "m_result", "m_auto", "m_drop"].has(state) else t("bar_oxygen_tip")},
			{"icon": "", "col": COL_SCI, "frac": science / SCIENCE_MAX, "val": str(int(round(science))), "of": t("of_science"), "name": t("bar_science"), "tip": " "},
		]
	if start == "f":
		# The free mission: power has no goal of its own (it feeds the oxygen machine); radiation counts the whole mission.
		return [
			{"icon": "power-generator.svg", "col": UI.COL_POWER, "frac": power / 100.0, "val": str(int(round(power))) + "%", "of": " ", "name": t("bar_power"), "tip": " "},
			{"icon": "radiations.svg", "col": UI.COL_RAD, "frac": exposure / RAD_BAR_MAX, "val": _n1(exposure), "of": t("of_exposure_f"), "name": t("bar_exposure_short"), "tip": t("bar_exposure_tip_f"), "goal": F_RAD_GOAL / RAD_BAR_MAX},
		]
	return [
		{"icon": "power-generator.svg", "col": UI.COL_POWER, "frac": power / 100.0, "val": str(int(round(power))) + "%", "of": t("of_power"), "name": t("bar_power"), "tip": " ", "goal": GOAL_POWER / 100.0},
		{"icon": "radiations.svg", "col": UI.COL_RAD, "frac": exposure / RAD_BAR_MAX, "val": _n1(exposure), "of": t("of_exposure"), "name": t("bar_exposure_short"), "tip": t("bar_exposure_tip"), "goal": GOAL_RAD / RAD_BAR_MAX},
	]

## A white line across a bar at its goal.
func _goal_mark(root: Control, frac: float, w: int, h: int) -> void:
	var line := ColorRect.new()
	line.color = Color(1, 1, 1, 0.95)
	line.position = Vector2(-5, h * (1.0 - frac) - 2)
	line.size = Vector2(w + 10, 4)
	line.mouse_filter = IGNORE
	root.add_child(line)

func _bar_icon(spec: Dictionary, px: int) -> TextureRect:
	if spec.icon == "":
		return UI.ui_icon("Yellow/Default/star.png", Color.WHITE, px)
	return UI.icon(spec.icon, spec.col, px)

func _bar_col(spec: Dictionary, show_plus: bool, pointed := false) -> VBoxContainer:
	var col: Color = spec.col
	var edge := Color(0.08, 0.06, 0.12)   # outlined text stays readable over any ground
	var v := UI.vbox(1)
	v.alignment = BoxContainer.ALIGNMENT_END
	v.custom_minimum_size.x = 78
	if pointed:
		v.add_child(_point_cue())
	if show_plus:
		# What the storm adds, shown beside the bar while it climbs.
		v.add_child(UI.outlined(_centered(UI.title("+" + _n1(_x_after(choice) - 1.0), 26, col)), 7, edge))
	var disc := PanelContainer.new()
	var ds := StyleBoxFlat.new()
	ds.bg_color = Color(0.09, 0.08, 0.15, 0.7)
	ds.set_corner_radius_all(19)
	ds.set_content_margin_all(5)
	disc.add_theme_stylebox_override("panel", ds)
	disc.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	disc.mouse_filter = IGNORE
	disc.add_child(_bar_icon(spec, 28))
	v.add_child(disc)
	var bar := UI.vbar(col, 38, 128, true)
	v.add_child(bar.root)
	if spec.has("goal"):
		_goal_mark(bar.root, spec.goal, 38, 128)
	var val := UI.outlined(_centered(UI.title("", 24, col)), 7, edge)
	v.add_child(val)
	v.add_child(UI.outlined(_centered(UI.bold(spec.of, 13)), 5, edge))
	v.add_child(UI.outlined(_centered(UI.bold(spec.name, 14)), 6, edge))
	v.add_child(UI.outlined(_centered(UI.bold(spec.tip, 12)), 5, edge))
	_fills.append(bar.fill)
	_vals.append(val)
	return v

## A pinned note: what one role has told the crew.
func _note(role: String, wrap_w: int) -> PanelContainer:
	var p := UI.panel(UI.NAVY2 if state == "decide" else BOX, 14, 10)
	p.mouse_filter = IGNORE
	var h := UI.hbox(10)
	p.add_child(h)
	h.add_child(UI.badge(_role_icon(role), SPEAKER_COL[role], 40))
	h.add_child(UI.label(t("note_eng" if role == "eng" else "note_pro_" + _storm_size()).format(_sc()), 18, UI.PAPER, null, wrap_w))
	return p

func _corner_buttons() -> void:
	var m := _margins(14)
	_full(m)
	var btns := UI.hbox(8)
	btns.size_flags_horizontal = Control.SIZE_SHRINK_END
	btns.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	m.add_child(btns)
	var vb := UI.button(t("btn_voice_on") if voice_on else t("btn_voice_off"), _toggle_voice, "Grey", 19)
	var lb := UI.button(t("lang_button"), _toggle_lang, "Yellow", 19)
	if state == "select":
		var gb := UI.button(t("btn_logbook"), _open_logbook, "Grey", 19)
		btns.add_child(gb)
		_tip(gb, t("tip_logbook"))
	btns.add_child(vb)
	btns.add_child(lb)
	_tip(vb, t("tip_voice"))
	_tip(lb, t("tip_lang"))

## Title: deep space, Earth drifting in, and one prompt. No box: the text floats over the stars.
func _r_title() -> void:
	_corner_buttons()
	var m := _margins(40)
	_full(m)
	var v := UI.vbox(10)
	m.add_child(v)
	var edge := Color(0.02, 0.02, 0.06)
	v.add_child(UI.outlined(UI.title(t("title"), 68, UI.PAPER, 900), 12, edge))
	v.add_child(UI.outlined(UI.label(t("subtitle"), 30, UI.COL_POWER, null, 900), 8, edge))
	var gap := Control.new()
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	gap.mouse_filter = IGNORE
	v.add_child(gap)
	var go := UI.outlined(UI.title(t("press_any"), 38, UI.PAPER), 10, edge)
	v.add_child(go)
	if not world.reduced_motion:
		# A slow breath, well under one pulse a second.
		var tw := go.create_tween().set_loops()
		tw.tween_property(go, "modulate:a", 0.45, 1.3).set_trans(Tween.TRANS_SINE)
		tw.tween_property(go, "modulate:a", 1.0, 1.3).set_trans(Tween.TRANS_SINE)
	v.add_child(UI.outlined(UI.label(t("ages") + "   ·   " + t("disclaimer"), 17, UI.SOFT), 6, edge))

## On the Moon: solo or co-op? The pictures show who moves with which keys.
func _r_players() -> void:
	_corner_buttons()
	var v := _modal(1120, 0.35)
	_modal_head(v, "cmd", t("players_title"), 38, 900)
	var row := UI.hbox(16)
	v.add_child(row)
	for n in [1, 2]:
		var p := UI.panel(UI.NAVY2, 20, 16)
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(p)
		var pv := UI.vbox(10)
		p.add_child(pv)
		var faces := UI.hbox(26)
		faces.alignment = BoxContainer.ALIGNMENT_CENTER
		pv.add_child(faces)
		for r in ["eng", "pro"]:
			var one := UI.vbox(6)
			faces.add_child(one)
			one.add_child(_portrait(r, 92))
			if n == 2:
				one.add_child(_pill(t("keys_wasd") if r == "eng" else t("keys_arrows"), SPEAKER_COL[r], 18))
		if n == 1:
			pv.add_child(_pill(t("keys_solo"), UI.PAPER, 18))
		pv.add_child(UI.button(t("players_%d" % n), func(): _set_players(n), "Green", 34))
	v.add_child(_centered(UI.label(t("players_touch"), 19, UI.SOFT, null, 1060)))

## Mission select: the Moon first, Mars once the Moon is done, and worlds still to come.
func _r_select() -> void:
	_corner_buttons()
	var edge := Color(0.02, 0.02, 0.06)
	var m := _margins(0)
	m.add_theme_constant_override("margin_top", 34)
	m.add_theme_constant_override("margin_bottom", 70)
	_full(m)
	var v := UI.vbox(8)
	m.add_child(v)
	v.add_child(_centered(UI.outlined(UI.title(t("select_title"), 52), 10, edge)))
	var hint := t("sel_unlocked") if (moon_done and not mars_done) else ("" if moon_done else t("sel_hint"))
	v.add_child(_centered(UI.outlined(UI.label(hint if hint != "" else " ", 26, UI.COL_GOOD if moon_done else UI.SOFT), 8, edge)))
	var gap := Control.new()
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	gap.mouse_filter = IGNORE
	v.add_child(gap)
	var row := UI.hbox(0)
	v.add_child(row)
	var cols: Array = [
		{"id": "moon", "name": t("moon"), "tag": t("sel_done") if moon_done else t("sel_level_1"), "open": true, "done": moon_done},
		{"id": "mars", "name": t("mars"), "tag": (t("sel_done") if mars_done else t("sel_level_2")) if moon_done else t("sel_locked"), "open": moon_done, "done": mars_done},
		{"id": "asteroid", "name": t("sel_asteroid"), "tag": t("sel_soon"), "open": false, "done": false},
		{"id": "more", "name": t("sel_more"), "tag": t("sel_soon"), "open": false, "done": false},
	]
	for c in cols:
		var col := UI.vbox(8)
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(col)
		col.add_child(_centered(UI.outlined(UI.title(c.name, 36, UI.PAPER if c.open else UI.SOFT), 9, edge)))
		col.add_child(_pill(c.tag, (UI.COL_GOOD if c.done else UI.COL_POWER) if c.open else UI.SOFT, 18))
		if c.open:
			var id: String = c.id
			col.add_child(UI.button(t("btn_replay") if c.done else t("btn_play"), func(): _on_tapped(id), "Blue" if c.done else "Green", 30))
			if id == "mars":
				var fb := UI.button(t("btn_free"), _start_free, "Yellow", 22)
				fb.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
				col.add_child(fb)
		else:
			var pad := Control.new()
			pad.custom_minimum_size = Vector2(0, 60 if c.id != "mars" else 112)
			pad.mouse_filter = IGNORE
			col.add_child(pad)

func _photo(tex: Texture2D, w := 96, h := 60) -> TextureRect:
	var r := TextureRect.new()
	r.texture = tex
	r.custom_minimum_size = Vector2(w, h)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	r.clip_contents = true
	r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r.mouse_filter = IGNORE
	return r

## A message dot that crosses the line at real speed.
func _track(left: String, right: String, secs: float, col: Color, w := 300) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(w + 150, 34)
	c.mouse_filter = IGNORE
	var l := UI.bold(left, 18)
	l.position = Vector2(0, 4)
	c.add_child(l)
	var line := ColorRect.new()
	line.color = Color(1, 1, 1, 0.35)
	line.position = Vector2(66, 15)
	line.size = Vector2(w, 4)
	c.add_child(line)
	var r := UI.bold(right, 18)
	r.position = Vector2(w + 78, 4)
	c.add_child(r)
	var dot := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(10)
	dot.add_theme_stylebox_override("panel", sb)
	dot.size = Vector2(20, 20)
	dot.position = Vector2(66, 7)
	c.add_child(dot)
	if world.reduced_motion:
		dot.position.x = 66 + w * 0.5
	else:
		var tw := dot.create_tween().set_loops()
		tw.tween_property(dot, "position:x", 46.0 + w, secs).from(66.0)
		tw.tween_interval(0.8)
	return c

## Level 1 opens with a real mission card.
func _r_m_card() -> void:
	var v := _modal(1060, 0.55)
	var tag := _pill(t("level_1"), COL_O2, 22)
	tag.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	v.add_child(tag)
	v.add_child(UI.title(t("m_card_title"), 42, UI.PAPER, 1000))
	v.add_child(UI.label(t("m_card_body"), 27, UI.PAPER, null, 1000))
	v.add_child(UI.label(t("m_card_credit"), 16, UI.SOFT, null, 1000))
	var row := UI.hbox(16)
	v.add_child(row)
	row.add_child(UI.spacer())
	row.add_child(UI.button(t("btn_open_term"), func(): _go("m_term"), "Green", 32))

## Curiosity's real camera image of the storm. The players tap the streaks and specks they find.
func _speck_photo(tex: Texture2D) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(500, 250)
	c.clip_contents = true
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var pic := TextureRect.new()
	pic.texture = tex
	pic.size = Vector2(500, 250)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_SCALE
	pic.mouse_filter = IGNORE
	c.add_child(pic)
	for at in picks.get("specks", []):
		var ring := Panel.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0)
		sb.set_corner_radius_all(18)
		sb.set_border_width_all(4)
		sb.border_color = UI.COL_POWER
		ring.add_theme_stylebox_override("panel", sb)
		ring.size = Vector2(36, 36)
		ring.position = (at as Vector2) - Vector2(18, 18)
		ring.mouse_filter = IGNORE
		c.add_child(ring)
	c.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.pressed:
			var marks: Array = picks.get("specks", [])
			if marks.size() < 8:
				marks.append(e.position)
				picks["specks"] = marks
				_render())
	return c

func _term_line(v: VBoxContainer, text: String, col: Color = TERM_GREEN) -> void:
	v.add_child(UI.label("> " + text, 22, col, UI.bold_font(), 1040))

func _iso_date(iso: String) -> String:
	return Strings.date(int(iso.substr(0, 4)), int(iso.substr(5, 2)), int(iso.substr(8, 2)), lang)

## The NASA terminal: the player asks NASA for real data, sees the request happen, and reads what came back.
func _r_terminal(kind: String) -> void:
	var v := _modal(1120, 0.86)
	var sb := UI.panel_box(Color(0.02, 0.06, 0.05, 0.98), 18, 26)
	sb.set_border_width_all(3)
	sb.border_color = TERM_GREEN.darkened(0.35)
	(v.get_parent() as PanelContainer).add_theme_stylebox_override("panel", sb)
	var st: Dictionary = term.get(kind, {"step": 0})
	var head := UI.hbox(12)
	v.add_child(head)
	var title := _pill(t("term_title"), TERM_GREEN, 20)
	title.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	head.add_child(title)
	head.add_child(UI.label(t("level_%d" % level), 18, UI.SOFT, UI.bold_font()))
	if st.step == 0:
		_term_line(v, t("term_ready"))
		var intro := UI.label(t("term_%s_intro" % kind), 26, UI.PAPER, null, 1040)
		v.add_child(intro)
		_say(intro, "cmd")
		var row0 := UI.hbox(0)
		v.add_child(row0)
		row0.add_child(UI.spacer())
		row0.add_child(UI.button(t("term_%s_btn" % kind), func(): _term_run(kind), "Green", 32))
		return
	if st.step == 1:
		_term_line(v, t("term_l1"))
		_term_line(v, t("term_%s_l2" % kind))
		_term_line(v, t("term_l3"))
		var track := Control.new()
		track.custom_minimum_size = Vector2(1040, 22)
		track.mouse_filter = IGNORE
		v.add_child(track)
		var bg := ColorRect.new()
		bg.color = Color(1, 1, 1, 0.12)
		bg.size = Vector2(1040, 14)
		track.add_child(bg)
		var fill := ColorRect.new()
		fill.color = TERM_GREEN
		fill.size = Vector2(1040 * 0.9 if world.reduced_motion else 10.0, 14)
		track.add_child(fill)
		if not world.reduced_motion:
			fill.create_tween().tween_property(fill, "size:x", 1040 * 0.92, 2.6).set_trans(Tween.TRANS_SINE)
		return
	if st.ok:
		_term_line(v, t("term_ok_" + kind).format({"n": st.get("records", 1)}))
		_term_line(v, t("term_live_at" if st.get("cached", false) else "term_live").format({"time": st.get("at", "")}), UI.COL_GOOD)
	else:
		_term_line(v, t("term_fail"), UI.COL_POWER)
		_term_line(v, t("term_arch"), UI.SOFT)
	var box := UI.panel(UI.NAVY2, 16, 16)
	v.add_child(box)
	var h := UI.hbox(18)
	box.add_child(h)
	if kind == "mars" and st.has("tex") and start == "a":
		h.add_child(_speck_photo(st.tex))
	if kind == "moon" and st.ok:
		var pic := TextureRect.new()
		pic.texture = st.tex
		pic.custom_minimum_size = Vector2(330, 330)
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.mouse_filter = IGNORE
		h.add_child(pic)
	var bv := UI.vbox(8)
	bv.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(bv)
	var top := UI.hbox(10)
	bv.add_child(top)
	top.add_child(UI.bold(t("rec_title"), 22, TERM_GREEN))
	top.add_child(_pill((t("tag_session") if st.get("cached", false) else t("tag_live")) if st.ok else t("tag_arch"), UI.COL_GOOD if st.ok else UI.SOFT, 16))
	var with_pic: bool = st.ok and (kind == "moon" or (st.has("tex") and start == "a"))
	var wrap_w := (660 if kind == "moon" else 500) if with_pic else 1000
	var text := ""
	if kind == "moon":
		text = t("rec_moon").format({"date": _iso_date(st.date)}) if st.ok else t("rec_moon_off")
	elif not st.ok:
		text = t("sun_arch") if start == "c" else t("rec_mars_off")
	elif st.days > 0:
		text = t("rec_mars_some").format({"n": st.days, "date": _iso_date(st.latest)})
	else:
		text = t("rec_mars_none")
	var body := UI.label(text, 25, UI.PAPER, null, wrap_w)
	bv.add_child(body)
	_say(body, "cmd")
	if kind == "moon" and st.ok:
		bv.add_child(UI.label(t("rec_caption") + ("\n“" + st.title + "”" if st.title != "" else ""), 15, UI.SOFT, null, wrap_w))
	if kind == "mars":
		var arch := UI.hbox(10)
		bv.add_child(arch)
		if with_pic:
			var marks: Array = picks.get("specks", [])
			bv.add_child(UI.label(t("storm_pic_ok") if marks.size() >= 3 else t("storm_pic"), 21, UI.COL_GOOD if marks.size() >= 3 else UI.COL_POWER, UI.bold_font(), wrap_w))
			bv.add_child(UI.label(t("storm_pic_credit"), 13, UI.SOFT, null, wrap_w))
		if start == "c":
			# The bonus sol: what the live answer means for today, by the game's rule.
			if sun.live:
				arch.add_child(UI.label(_sun_line(), 21, UI.COL_POWER, UI.bold_font(), wrap_w))
		else:
			arch.add_child(UI.label(t("rec_train") + " " + _storm_line(), 17 if with_pic else 19, UI.SOFT, null, wrap_w - 120))
			arch.add_child(_pill(t("tag_arch"), UI.SOFT, 16))
	var row := UI.hbox(0)
	v.add_child(row)
	row.add_child(UI.spacer())
	if kind == "moon":
		row.add_child(UI.button(t("btn_drive"), func(): _go("m_deploy"), "Green", 32))
	else:
		row.add_child(UI.button(t("btn_use_report"), func(): _go("role_pro"), "Green", 32))

## Driving on the Moon. Mission Control is the guide here, because Earth is close enough to answer.
func _r_m_drive() -> void:
	if not m_briefed:
		# Before driving, Mission Control names the two things to watch. An arrow points at each bar.
		var b := _talk("mc", t("m_brief_o2") if page == 0 else t("m_brief_sci"))
		var brow := UI.hbox(0)
		b.add_child(brow)
		brow.add_child(UI.spacer())
		brow.add_child(_next_cue())
		brow.add_child(UI.button(t("btn_next"), _m_brief_next, "Blue", 26))
		return
	var v := _talk("mc", t("mc_limit") if m_limit else t("mc_drive"))
	var row := UI.hbox(16)
	v.add_child(row)
	row.add_child(UI.label(t("m_keys"), 19, UI.SOFT))
	row.add_child(UI.spacer())
	var ask := UI.button(t("btn_ask_mc"), _m_ask, "Blue", 26)
	_tip(ask, t("tip_ask"))
	row.add_child(ask)

## Asking Earth from the Moon: the answer is back in 2.6 seconds, in real time.
func _r_m_ask() -> void:
	if page == 0:
		var c := _talk("eng", t("m_calling"))
		c.add_child(_track(t("moon"), t("earth"), 1.3, Color(0.85, 0.88, 0.95), 420))
		c.add_child(UI.label(t("m_calling_note"), 19, UI.SOFT))
		return
	var v := _talk("mc", t("mc_answer"))
	var row := UI.hbox(16)
	v.add_child(row)
	row.add_child(UI.bold(t("m_answer_note"), 23, UI.COL_GOOD))
	row.add_child(UI.spacer())
	row.add_child(UI.button(t("btn_ok"), func(): _go("m_drive"), "Green", 28))

## Lowering the rover: two switches, one for each astronaut. Keys are held; taps switch them on and off.
func _r_m_deploy() -> void:
	var v := _talk("mc", t("mc_deploy"))
	var row := UI.hbox(16)
	v.add_child(row)
	var a_on: bool = _dep_seen[0]
	var b_on: bool = _dep_seen[1]
	row.add_child(UI.badge("gears.svg", SPEAKER_COL.eng, 56, Callable(), a_on))
	row.add_child(UI.button(t("dep_a"), func(): _dep_toggle("a"), "Yellow" if a_on else "Grey", 24))
	row.add_child(UI.spacer())
	row.add_child(UI.badge("energy-shield.svg", SPEAKER_COL.pro, 56, Callable(), b_on))
	row.add_child(UI.button(t("dep_b"), func(): _dep_toggle("b"), "Yellow" if b_on else "Grey", 24))
	v.add_child(UI.label(t("dep_hint"), 18, UI.SOFT))

## The last experiment on the Moon: predict, let go, then compare with Earth's air.
func _r_m_drop() -> void:
	if drop_guess == "":
		var q := _talk("mc", t("mc_drop_q"))
		var row := UI.hbox(14)
		q.add_child(row)
		row.add_child(UI.spacer())
		for g in ["hammer", "feather", "same"]:
			row.add_child(UI.button(t("drop_" + g), func(): _drop_predict(g), "Blue", 26))
		return
	if not drop_done.moon:
		var w := _talk("mc", t("mc_drop_go").format({"g": t("drop_" + drop_guess)}))
		var row2 := UI.hbox(0)
		w.add_child(row2)
		row2.add_child(UI.spacer())
		row2.add_child(UI.button(t("btn_drop"), func(): _drop("moon"), "Green", 30))
		return
	var lead := (t("predict_right") if drop_guess == "same" else t("predict_wrong")) + " " + t("mc_drop_moon")
	if drop_done.air:
		lead = t("mc_drop_air")
	var v := _talk("mc", lead)
	var row3 := UI.hbox(14)
	v.add_child(row3)
	row3.add_child(UI.button(t("btn_drop_air"), func(): _drop("air"), "Blue", 24))
	row3.add_child(UI.button(t("btn_drop"), func(): _drop("moon"), "Blue", 24))
	row3.add_child(UI.spacer())
	row3.add_child(UI.button(t("btn_missions"), _moon_complete, "Green", 28))

## Picking rocks: no arrows to follow. The players look at the rocks and choose.
func _r_m_collect() -> void:
	if m_pending >= 0:
		# The rare rock: photograph it where it lies, then bag it.
		var pv := _talk("mc", t("mc_photo_ok") if m_photo != null else t("mc_photo"))
		var prow := UI.hbox(16)
		pv.add_child(prow)
		if m_photo != null:
			var pic := TextureRect.new()
			pic.texture = m_photo
			pic.custom_minimum_size = Vector2(210, 140)
			pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			pic.clip_contents = true
			pic.mouse_filter = IGNORE
			prow.add_child(pic)
		prow.add_child(UI.spacer())
		var pb: Button
		if m_photo == null:
			pb = UI.button(t("btn_photo"), _m_take_photo, "Green", 30)
		else:
			var which := m_pending
			pb = UI.button(t("btn_bag"), func(): _m_dig(which), "Green", 30)
		pb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		prow.add_child(pb)
		return
	var v := _talk("mc", t("mc_collect"))
	var row := UI.hbox(16)
	v.add_child(row)
	row.add_child(UI.bold(t("rocks_left").format({"n": 3 - m_dug.size()}), 23, COL_SCI))
	row.add_child(UI.spacer())
	if not m_dug.is_empty():
		row.add_child(UI.button(t("btn_rocks_done"), _m_leave, "Blue", 26))

func _m_kept_lost(run: Dictionary, size: int, wrap_w: int) -> VBoxContainer:
	var hours := ("%.1f" % run.oxygen).trim_suffix(".0")
	var f := {"o": t("hour_1" if hours == "1" else "hour_n").format({"n": hours}), "s": int(run.science)}
	var got_rare: bool = run.science >= 4.0
	var v := UI.vbox(6)
	if run.site == "near":
		v.add_child(_fact(t("m_near_keep").format(f), "c", _tick(true, size + 6), size, wrap_w))
		v.add_child(_fact(t("m_near_lost").format(f), "r", _tick(false, size + 6), size, wrap_w))
	else:
		v.add_child(_fact(t("m_far_keep" if got_rare else "m_far_miss").format(f), "r", _tick(got_rare, size + 6), size, wrap_w))
		v.add_child(_fact(t("m_far_lost").format(f), "c", _tick(false, size + 6), size, wrap_w))
	return v

func _r_m_result() -> void:
	var first: bool = m_runs.size() == 1
	var v := _talk("mc", t("mc_result") if first else t("mc_result2"))
	v.add_child(_m_kept_lost(m_runs[-1], 23, 900))
	var row := UI.hbox(16)
	v.add_child(row)
	if first:
		row.add_child(UI.bold(t("m_result_q"), 23, UI.COL_POWER, 540))
	row.add_child(UI.spacer())
	if first:
		row.add_child(UI.button(t("btn_skip_replay"), _skip_m_retry, "Grey", 20))
		row.add_child(UI.button(t("btn_other_site"), _m_retry, "Blue", 28))
	else:
		row.add_child(UI.button(t("btn_m_compare"), func(): _go("m_compare"), "Green", 28))

## Both Moon trips side by side. The crew taps the one it would pick: there is no wrong pick.
func _r_m_compare() -> void:
	var v := _modal(1420, 0.85)
	_modal_head(v, "mc", t("mc_compare"), 30, 1150)
	var row := UI.hbox(16)
	v.add_child(row)
	var chosen: String = picks.get("m_plan", "")
	for run in m_runs:
		var mine: bool = chosen == run.site
		var p := PanelContainer.new()
		var sb := UI.panel_box(UI.NAVY2, 20, 16)
		sb.set_border_width_all(4)
		sb.border_color = UI.COL_POWER if mine else Color(1, 1, 1, 0.1)
		p.add_theme_stylebox_override("panel", sb)
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(p)
		var pv := UI.vbox(8)
		p.add_child(pv)
		var head := UI.hbox(10)
		pv.add_child(head)
		head.add_child(UI.title(t("site_" + run.site), 28))
		head.add_child(UI.spacer())
		if mine:
			head.add_child(_pill(t("picked"), UI.COL_POWER, 18))
		if run.shot != null:
			var pic := TextureRect.new()
			pic.texture = run.shot
			pic.custom_minimum_size = Vector2(640, 170)
			pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			pic.clip_contents = true
			pic.mouse_filter = IGNORE
			pv.add_child(pic)
		var low := UI.hbox(8)
		pv.add_child(low)
		low.add_child(_mini(UI.icon("astronaut-helmet.svg", COL_O2, 28), COL_O2, run.oxygen / O2_FULL, ("%.1f" % run.oxygen).trim_suffix(".0") + " h", t("of_oxygen")))
		low.add_child(_mini(UI.ui_icon("Yellow/Default/star.png", Color.WHITE, 28), COL_SCI, run.science / SCIENCE_MAX, str(int(round(run.science))), t("of_science")))
		var kl := _m_kept_lost(run, 19, 330)
		kl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		low.add_child(kl)
		var site: String = run.site
		pv.add_child(UI.button(t("btn_pick"), func(): _pick("m_plan", site), "Yellow" if mine else "Blue", 24))
	var foot := UI.hbox(16)
	v.add_child(foot)
	foot.add_child(UI.bold(t("pick_fb") if chosen != "" else t("m_compare_note"), 23, UI.COL_GOOD if chosen != "" else UI.PAPER, 1000))
	foot.add_child(UI.spacer())
	foot.add_child(UI.button(t("btn_next_mars"), func(): moon.set_drop(true); _go("m_drop"), "Green", 28))

## Between the levels: the same question, with Earth too far away to answer in time.
func _r_to_moon() -> void:
	# The rocket leaves Earth for the Moon while Mission Control tells the real story behind the level.
	var v := _talk("mc", t("m_card_title") + ". " + t("m_card_body"))
	var row := UI.hbox(16)
	v.add_child(row)
	row.add_child(_pill(t("level_1"), COL_O2, 20))
	row.add_child(UI.label(t("m_card_credit") + " " + t("to_scale"), 15, UI.SOFT, null, 640))
	row.add_child(UI.spacer())
	row.add_child(UI.button(t("btn_land_moon"), _land_moon, "Green", 30))

func _r_to_mars() -> void:
	# No card over the scene: the rocket leaves the Moon for Mars while the Commander gives the brief.
	var v := _talk("cmd", t("to_mars_title") + ". " + t("to_mars_body"))
	var row := UI.hbox(16)
	v.add_child(row)
	var tag := _pill(t("level_2"), UI.COL_POWER, 20)
	row.add_child(tag)
	row.add_child(UI.label(t("to_mars_scale"), 16, UI.SOFT, null, 620))
	row.add_child(UI.spacer())
	row.add_child(UI.button(t("btn_land_mars"), _start_mars, "Green", 30))

## The commander welcomes the crew and sends each role to its console.
func _r_meet() -> void:
	var first: bool = not (reported.eng or reported.pro)
	if first and start == "b":
		_talk("cmd", t("cmd_b_intro") + " " + t("carry_" + carried))
	elif first and start == "c":
		_talk("cmd", t("cmd_c_intro"))
	elif first and page < 4:
		# The welcome, then the three things to manage, one line each. An arrow points at each one.
		_next_row(_talk("cmd", t(["cmd_meet1", "brief_power", "brief_o2", "brief_rad"][page])))
	else:
		_hint(_talk("cmd", t("cmd_meet2") if first else t("cmd_meet3")))

## What one role's console shows. The player says it out loud, then pins it for the crew.
func _r_role(role: String) -> void:
	var facts: Array = []
	if role == "eng":
		facts = [t("eng_f1_%d" % _offline()), t("eng_f2"), t("eng_f3")]
	else:
		facts = [t("pro_f1_" + _storm_size()), t("pro_f2_none") if _storm_size() == "none" else t("pro_f2"), t("pro_f3")]
	for i in range(3):
		facts[i] = (facts[i] as String).format(_sc())
	var v := _talk(role, t(role + "_lead"), t(role + "_lead") + " " + " ".join(facts))
	var cols := UI.hbox(22)
	v.add_child(cols)
	var left := UI.vbox(6)
	cols.add_child(left)
	var kinds: Array = ["r", "c", "r"]   # the fault and the goals are game rules; the middle line is our calculation
	for i in range(3):
		left.add_child(_fact(facts[i], kinds[i], null, 24, 620))
	if role == "pro":
		left.add_child(UI.label(_storm_line(), 16, UI.COL_PRO, UI.bold_font(), 760))
		if _storm_size() != "none":
			left.add_child(UI.label(t("model_note"), 15, UI.SOFT, null, 760))
	var right := UI.vbox(8)
	right.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cols.add_child(right)
	if role == "pro":
		right.add_child(UI.label(t("msv"), 16, UI.SOFT, null, 290))
	right.add_child(UI.button(t("tell"), func(): _tell(role), "Green", 28))
	right.add_child(_centered(UI.label(t("tell_hint"), 16, UI.SOFT, null, 290)))

## At the antenna: how far away is help? Two dots travel at real speed.
func _r_far() -> void:
	var v := _talk("cmd", t("cmd_far"), t("cmd_far") + " " + t("far_moon") + " " + t("far_mars"))
	var cols := UI.hbox(24)
	v.add_child(cols)
	var at := AtlasTexture.new()
	at.atlas = load("res://assets/nasa/PIA24264.jpg")
	at.region = Rect2(250, 15, 1000, 520)
	var rows: Array = [
		[load("res://assets/nasa/apollo11_AS11-40-5878.jpg"), t("far_moon"), t("moon"), 1.3, Color(0.85, 0.88, 0.95)],
		[at, t("far_mars"), t("mars"), 182.0, Color(1.0, 0.55, 0.35)],
	]
	for r in rows:
		var one := UI.hbox(10)
		cols.add_child(one)
		one.add_child(_photo(r[0]))
		var ov := UI.vbox(2)
		one.add_child(ov)
		ov.add_child(UI.label(r[1], 22))
		ov.add_child(_track(r[2], t("earth"), r[3], r[4]))
	var foot := UI.hbox(10)
	v.add_child(foot)
	var fv := UI.vbox(0)
	foot.add_child(fv)
	fv.add_child(UI.label(t("delay_real"), 17, UI.SOFT))
	fv.add_child(UI.label(t("delay_credit") + (" · " + t("delay_src") if show_src else ""), 12, UI.SOFT))
	foot.add_child(UI.spacer())
	foot.add_child(_next_cue())
	foot.add_child(UI.button(t("btn_next"), _next_page, "Blue", 26))

## A picture of the sum: the answer comes back at 40 minutes, the storm arrives at 30.
func _timeline() -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(900, 76)
	c.mouse_filter = IGNORE
	var x0 := 30.0
	var per_min := 16.0
	var out := ColorRect.new()   # 20 minutes to reach Earth
	out.color = Color(0.62, 0.72, 1.0)
	out.position = Vector2(x0, 36)
	out.size = Vector2(20 * per_min, 6)
	c.add_child(out)
	var back := ColorRect.new()  # 20 minutes for the answer to come back
	back.color = Color(0.42, 0.82, 1.0, 0.55)
	back.position = Vector2(x0 + 20 * per_min, 36)
	back.size = Vector2(20 * per_min, 6)
	c.add_child(back)
	for m in [0, 10, 20, 30, 40]:
		var tick := ColorRect.new()
		tick.color = Color(1, 1, 1, 0.7)
		tick.position = Vector2(x0 + m * per_min - 1, 30)
		tick.size = Vector2(2, 18)
		c.add_child(tick)
		var n := UI.label(str(m), 15, UI.SOFT)
		n.position = Vector2(x0 + m * per_min - 8, 50)
		c.add_child(n)
	var marks: Array = [[0, t("tl_now"), UI.PAPER], [30, t("tl_storm"), UI.COL_RAD], [40, t("tl_answer"), SPEAKER_COL.earth]]
	for mk in marks:
		var dot := Panel.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = mk[2]
		sb.set_corner_radius_all(9)
		dot.add_theme_stylebox_override("panel", sb)
		dot.size = Vector2(18, 18)
		dot.position = Vector2(x0 + mk[0] * per_min - 9, 30)
		c.add_child(dot)
		var l := UI.bold(mk[1], 19, mk[2])
		l.position = Vector2(x0 + mk[0] * per_min - (10 if mk[0] == 0 else (150 if mk[0] == 30 else -18)), 2 if mk[0] != 40 else 27)
		c.add_child(l)
	return c

## Asking Earth: a small sum shows the answer cannot arrive in time.
func _r_earth() -> void:
	var v := _talk("cmd", t("cmd_earth"), t("cmd_earth") + " " + t("earth_math2") + " " + t("earth_q"))
	v.add_child(_timeline())
	if earth_guess == "":
		var row := UI.hbox(16)
		v.add_child(row)
		row.add_child(UI.bold(t("earth_q"), 26, UI.COL_POWER, 700))
		row.add_child(UI.spacer())
		row.add_child(UI.button(t("yes"), func(): _guess("yes"), "Blue", 28))
		row.add_child(UI.button(t("no"), func(): _guess("no"), "Blue", 28))
	else:
		v.add_child(UI.bold(t("earth_right") if earth_guess == "no" else t("earth_wrong"), 24, UI.COL_GOOD if earth_guess == "no" else UI.COL_POWER, 1080))
		var row2 := UI.hbox(16)
		v.add_child(row2)
		row2.add_child(UI.label(t("cmd_earth_then"), 24, UI.PAPER, null, 800))
		row2.add_child(UI.spacer())
		row2.add_child(UI.button(t("btn_decide"), func(): _go("decide"), "Green", 28))

func _choice_panel(id: String) -> PanelContainer:
	var both: bool = votes.eng == id and votes.pro == id
	var p := PanelContainer.new()
	var sb := UI.panel_box(UI.NAVY2, 20, 18)
	sb.set_border_width_all(4)
	sb.border_color = UI.PAPER if both else Color(1, 1, 1, 0.12)
	p.add_theme_stylebox_override("panel", sb)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := UI.vbox(10)
	p.add_child(v)
	var head := UI.hbox(12)
	v.add_child(head)
	head.add_child(UI.icon("energy-shield.svg" if id == "a" else "power-generator.svg", UI.COL_PRO if id == "a" else UI.COL_POWER, 46))
	head.add_child(UI.title(t("choice_" + id), 32))
	var calm: bool = _storm_size() == "none"
	v.add_child(_fact(t("a_gain_none" if (calm and id == "a") else id + "_gain").format(_sc()), "c", UI.ui_icon("Green/Default/icon_checkmark.png", Color.WHITE, 30), 24, 470))
	v.add_child(_fact(t("b_cost_none" if (calm and id == "b") else id + "_cost").format(_sc()), "c" if id == "b" else "r", UI.ui_icon("Red/Default/icon_cross.png", Color.WHITE, 30), 24, 470))
	var bv := UI.hbox(22)
	bv.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(bv)
	for r in ["eng", "pro"]:
		var one := UI.vbox(2)
		bv.add_child(one)
		var b := UI.badge(_role_icon(r), SPEAKER_COL[r], 78, func(): _vote(r, id), votes[r] == id)
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_tip(b, t("tip_vote").format({"role": t("role_" + r)}))
		one.add_child(b)
		one.add_child(_centered(UI.label(t("role_" + r), 17, SPEAKER_COL[r])))
	return p

## The decision: what the crew knows, the two jobs, and a vote that needs both roles.
func _r_decide() -> void:
	var v := _modal(1320, 0.78)
	_modal_head(v, "cmd", t("cmd_decide"), 36, 1100)
	v.add_child(UI.label(t("both_needed"), 20, UI.SOFT, null, 1260))
	var notes := UI.hbox(14)
	v.add_child(notes)
	for r in ["eng", "pro"]:
		var n := _note(r, 540)
		n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		notes.add_child(n)
	var row := UI.hbox(16)
	v.add_child(row)
	row.add_child(_choice_panel("a"))
	row.add_child(_choice_panel("b"))
	var agree: bool = votes.eng != "" and votes.eng == votes.pro
	var split: bool = votes.eng != "" and votes.pro != "" and not agree
	var foot := UI.hbox(16)
	v.add_child(foot)
	var msg := t("vote_hint_1") if players == 1 else t("vote_hint")
	if agree:
		msg = t("vote_ok")
	elif split:
		msg = t("vote_split")
	elif votes.eng != "" or votes.pro != "":
		var done := "eng" if votes.eng != "" else "pro"
		msg = t("vote_wait").format({"role": t("role_" + done), "other": t("role_" + ("pro" if done == "eng" else "eng"))})
	foot.add_child(UI.bold(msg, 23, UI.COL_POWER if split else UI.PAPER, 900))
	foot.add_child(UI.spacer())
	var go := UI.button(t("btn_go"), func(): _start_job(votes.eng), "Green", 32)
	go.disabled = not agree
	foot.add_child(go)

## During the storm: Earth's answer arrives, too late to help.
func _r_storm() -> void:
	if runs.is_empty() and start == "a" and page == 0:
		var e := _talk("earth", t("earth_late_a"), t("earth_late_title") + ". " + t("earth_late_a") + " " + t("earth_late_note"))
		var note := UI.hbox(0)
		e.add_child(note)
		note.add_child(UI.bold(t("earth_late_note"), 22, UI.COL_POWER))
		note.add_child(UI.spacer())
		note.add_child(_next_cue())
		note.add_child(UI.button(t("btn_next"), _next_page, "Blue", 26))
		return
	var v := _talk("cmd", t("cmd_storm") if (runs.is_empty() and start == "a") else t("cmd_storm2"))
	var row := UI.hbox(12)
	v.add_child(row)
	row.add_child(UI.label(_storm_line(), 15, UI.SOFT, null, 760))
	row.add_child(UI.spacer())
	row.add_child(UI.button(t("btn_advance"), _advance, "Green", 30))

func _tick(ok: bool, px: int) -> TextureRect:
	return UI.ui_icon("Green/Default/icon_checkmark.png" if ok else "Red/Default/icon_cross.png", Color.WHITE, px)

func _verdict(run: Dictionary, size := 20) -> PanelContainer:
	var met := _goal_met(run.power, run.exposure)
	return _pill(t("goal_met") if met else t("goal_not"), UI.COL_GOOD if met else UI.COL_POWER, size)

## Did the plan meet each goal, and what did it cost? No "safe" or "in danger": only met or not met.
func _goal_lines(run: Dictionary, size: int, wrap_w: int) -> VBoxContainer:
	var v := UI.vbox(6)
	# One star for each goal met.
	v.add_child(_fact(t("goal_power").format({"p": int(run.power)}), "r", _star(run.power >= GOAL_POWER, size + 8), size, wrap_w))
	v.add_child(_fact(t("goal_rad").format({"x": _n1(run.exposure)}), "c", _star(snappedf(run.exposure, 0.1) <= GOAL_RAD, size + 8), size, wrap_w))
	# Oxygen is not a goal: it is what last night's power left for tomorrow.
	var o2 := t("goal_tanks").format({"m": run.made, "n": run.tanks}) if wrap_w >= 600 else t("tanks_short").format({"n": run.tanks})
	v.add_child(_fact(o2, "r", UI.icon("astronaut-helmet.svg", COL_O2, size + 6), size, wrap_w))
	if not (start == "c" and _storm_msv() <= 0.0):
		v.add_child(UI.label(t("cost_" + run.choice), size - 2, UI.SOFT, null, wrap_w + 40))
	return v

## The plan's consequences, shown as two scenes: the night (lights and lamp), then the next morning
## (the plants and the Radiation bar). Then the narrator asks what the players would do differently.
func _r_result() -> void:
	var c: String = runs[-1].choice
	var first: bool = runs.size() == 1
	if page == 0:
		var n := _talk("cmd", t("night_full") if runs[-1].power >= 100.0 else t("night_low").format({"p": int(runs[-1].power), "m": runs[-1].made}))
		var nrow := UI.hbox(0)
		n.add_child(nrow)
		nrow.add_child(UI.spacer())
		nrow.add_child(UI.button(t("btn_morning"), _to_morning, "Blue", 28))
		return
	var lead := t("cmd_result_c") if start == "c" else t("cmd_result")
	if not first:
		var truth := "more" if runs[1].exposure > runs[0].exposure else "less"
		lead = t("cmd_result2")
		if picks.get("predict", "") != "":
			lead = (t("predict_right") if picks["predict"] == truth else t("predict_wrong")) + " " + lead
	var v := _talk("cmd", lead, lead + " " + t("goal_met" if _goal_met(runs[-1].power, runs[-1].exposure) else "goal_not") + ". " + t("cost_" + c))
	var vr := UI.hbox(14)
	v.add_child(vr)
	vr.add_child(_verdict(runs[-1], 24))
	v.add_child(_goal_lines(runs[-1], 23, 860))
	if start == "c":
		# The bonus sol ends here: what today's real Sun changed.
		var end_line := t("sun_calm_" + c)
		if not sun.live:
			end_line = t("sun_arch_done")
		elif _storm_msv() > 0.0:
			end_line = t("sun_storm_done")
		v.add_child(UI.bold(end_line, 23, UI.COL_POWER, 1100))
		var crow := UI.hbox(16)
		v.add_child(crow)
		crow.add_child(UI.label(_sun_line(), 15, UI.SOFT, null, 860))
		crow.add_child(UI.spacer())
		crow.add_child(UI.button(t("btn_finish"), _finish, "Green", 28))
		return
	if first:
		v.add_child(UI.bold(t("cmd_result_q"), 23, UI.COL_POWER, 1100))
	var row := UI.hbox(16)
	v.add_child(row)
	row.add_child(UI.spacer())
	if first:
		row.add_child(UI.button(t("btn_skip_replay"), _skip_retry, "Grey", 20))
		row.add_child(UI.button(t("btn_retry"), _retry, "Blue", 28))
	else:
		row.add_child(UI.button(t("btn_compare"), func(): _go("compare"), "Green", 28))

## Before the retry, the players predict what will happen: a small experiment.
func _r_retry() -> void:
	var v := _talk("cmd", t("cmd_retry").format({"choice": t("choice_" + _other_choice())}))
	var row := UI.hbox(16)
	v.add_child(row)
	var guess: String = picks.get("predict", "")
	if guess == "":
		row.add_child(UI.bold(t("predict_q"), 24, UI.COL_POWER, 720))
		row.add_child(UI.spacer())
		row.add_child(UI.button(t("more"), func(): _pick("predict", "more"), "Blue", 28))
		row.add_child(UI.button(t("less"), func(): _pick("predict", "less"), "Blue", 28))
	else:
		row.add_child(UI.bold(t("predict_go").format({"p": t(guess)}), 24, UI.COL_POWER, 720))
		row.add_child(UI.spacer())
		row.add_child(UI.button(t("btn_go"), func(): _start_job(_other_choice()), "Green", 30))

## A small standing bar with its value, for the comparisons.
func _mini(icon: Control, col: Color, frac: float, value: String, of: String) -> VBoxContainer:
	var v := UI.vbox(2)
	v.custom_minimum_size.x = 110
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(icon)
	var bar := UI.vbar(col, 44, 96)
	UI.vbar_set(bar.fill, frac)
	v.add_child(bar.root)
	v.add_child(_centered(UI.title(value, 24, col)))
	v.add_child(_centered(UI.label(of, 14, UI.SOFT)))
	return v

func _mini_bar(is_power: bool, value: float) -> VBoxContainer:
	var col: Color = UI.COL_POWER if is_power else UI.COL_RAD
	return _mini(UI.icon("power-generator.svg" if is_power else "radiations.svg", col, 28), col, value / (100.0 if is_power else RAD_BAR_MAX), (str(int(round(value))) + "%") if is_power else _n1(value), t("of_power") if is_power else t("of_exposure"))

## Both plans from the same start, side by side. The crew taps the one it would pick: there is no wrong pick.
func _r_compare() -> void:
	var v := _modal(1420, 0.85)
	_modal_head(v, "cmd", t("cmd_compare"), 30, 1150)
	var row := UI.hbox(16)
	v.add_child(row)
	var chosen: String = picks.get("plan", "")
	for run in runs:
		var mine: bool = chosen == run.choice
		var p := PanelContainer.new()
		var sb := UI.panel_box(UI.NAVY2, 20, 16)
		sb.set_border_width_all(4)
		sb.border_color = UI.COL_POWER if mine else Color(1, 1, 1, 0.1)
		p.add_theme_stylebox_override("panel", sb)
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(p)
		var pv := UI.vbox(8)
		p.add_child(pv)
		var head := UI.hbox(10)
		pv.add_child(head)
		head.add_child(UI.icon("energy-shield.svg" if run.choice == "a" else "power-generator.svg", UI.COL_PRO if run.choice == "a" else UI.COL_POWER, 38))
		head.add_child(UI.title(t("choice_" + run.choice), 28))
		head.add_child(UI.spacer())
		if mine:
			head.add_child(_pill(t("picked"), UI.COL_POWER, 18))
		head.add_child(_verdict(run, 18))
		if run.shot != null:
			var pic := TextureRect.new()
			pic.texture = run.shot
			pic.custom_minimum_size = Vector2(640, 170)
			pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			pic.clip_contents = true
			pic.mouse_filter = IGNORE
			pv.add_child(pic)
		var low := UI.hbox(8)
		pv.add_child(low)
		low.add_child(_mini_bar(true, run.power))
		low.add_child(_mini_bar(false, run.exposure))
		var kl := _goal_lines(run, 19, 320)
		kl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		low.add_child(kl)
		var c: String = run.choice
		pv.add_child(UI.button(t("btn_pick"), func(): _pick("plan", c), "Yellow" if mine else "Blue", 24))
	var foot := UI.hbox(16)
	v.add_child(foot)
	var note := t("compare_note")
	var note_col: Color = UI.PAPER
	if chosen != "":
		var good := false
		for run in runs:
			if run.choice == chosen:
				good = _goal_met(run.power, run.exposure)
		note = t("pick_yes") if good else t("pick_no")
		note_col = UI.COL_GOOD if good else UI.COL_POWER
	if start == "b":
		note = t("lesson_b")
		note_col = UI.COL_GOOD
	foot.add_child(UI.bold(note, 22, note_col, 1000))
	foot.add_child(UI.spacer())
	if start == "a":
		foot.add_child(UI.button(t("btn_debrief"), func(): _log_add("missions"); _go("debrief"), "Green", 28))
	else:
		foot.add_child(UI.button(t("btn_harvest"), _start_harvest, "Green", 28))

func _shape_button(kind: int, col: Color, picked: bool, cb: Callable) -> Button:
	# Four shapes and four colours, so nobody has to tell the plugs apart by colour alone.
	var b := Button.new()
	b.custom_minimum_size = Vector2(54, 54)
	b.size = Vector2(54, 54)
	b.focus_mode = Control.FOCUS_NONE
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = col if kind != 3 else Color(0, 0, 0, 0)
		sb.set_corner_radius_all(27 if (kind == 0 or kind == 3) else 8)
		sb.set_border_width_all(12 if kind == 3 else (6 if picked else 0))
		sb.border_color = col if (kind == 3 and not picked) else Color.WHITE
		b.add_theme_stylebox_override(st, sb)
	if kind == 2:
		b.pivot_offset = Vector2(27, 27)
		b.rotation = PI / 4.0
		b.scale = Vector2(0.82, 0.82)
	else:
		UI.juice(b)
	b.pressed.connect(cb)
	return b

## The power job: match each plug to its socket. Every match brings the unit closer to working.
func _wire_board() -> Control:
	var n: int = job.n
	var cols: Array = [UI.COL_POWER, UI.COL_PRO, Color(1.0, 0.55, 0.75), UI.COL_GOOD]
	var c := Control.new()
	c.custom_minimum_size = Vector2(1000, 64 * n + 4)
	c.mouse_filter = IGNORE
	for i in job.done:
		var wire := Line2D.new()
		wire.points = PackedVector2Array([Vector2(190, 31 + 64 * i), Vector2(480, 31 + 64 * i), Vector2(520, 31 + 64 * job.order.find(i)), Vector2(810, 31 + 64 * job.order.find(i))])
		wire.width = 9.0
		wire.default_color = cols[i]
		wire.joint_mode = Line2D.LINE_JOINT_ROUND
		wire.begin_cap_mode = Line2D.LINE_CAP_ROUND
		wire.end_cap_mode = Line2D.LINE_CAP_ROUND
		c.add_child(wire)
	for i in range(n):
		var plug := _shape_button(i, cols[i], job.sel == i, func(): _wire_pick(i))
		plug.position = Vector2(140, 4 + 64 * i)
		c.add_child(plug)
		var want: int = job.order[i]
		var done: bool = job.done.has(want)
		var socket := _shape_button(want, cols[want] if done else (cols[want] as Color).darkened(0.55), false, func(): _wire_plug(i))
		socket.position = Vector2(806, 4 + 64 * i)
		c.add_child(socket)
	var l := UI.bold(t("wires_done").format({"n": job.done.size(), "m": n}), 22, UI.COL_POWER)
	l.position = Vector2(410, 64 * n - 30)
	c.add_child(l)
	return c

## The shelter job: storm rays head for the bunks; a water bag in a ray's gap stops it.
func _bag_board() -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(1000, 250)
	c.mouse_filter = IGNORE
	c.clip_contents = true   # the rays stop at the edge of the board
	var mid := Vector2(380, 150)
	var gaps: Array = [Vector2(-215, -5), Vector2(-150, -88), Vector2(-52, -112), Vector2(52, -112), Vector2(150, -88), Vector2(215, -5), Vector2(-150, 72), Vector2(150, 72)]
	for r in job.rays:
		var blocked: bool = job.bags.has(r)
		var ray := Line2D.new()
		var dir: Vector2 = (gaps[r] as Vector2).normalized()
		ray.points = PackedVector2Array([mid + dir * 340.0, mid + (gaps[r] as Vector2) if blocked else mid + dir * 46.0])
		ray.width = 6.0
		ray.default_color = Color(1.0, 0.86, 0.45, 0.4 if blocked else 0.95)
		ray.begin_cap_mode = Line2D.LINE_CAP_ROUND
		ray.end_cap_mode = Line2D.LINE_CAP_ROUND
		c.add_child(ray)
	var bunk := Panel.new()
	var bs := StyleBoxFlat.new()
	bs.bg_color = Color(0.30, 0.52, 0.78)
	bs.set_corner_radius_all(12)
	bunk.add_theme_stylebox_override("panel", bs)
	bunk.size = Vector2(170, 84)
	bunk.position = mid - Vector2(85, 42)
	bunk.mouse_filter = IGNORE
	c.add_child(bunk)
	for bx in [-70.0, 12.0]:
		var bed := ColorRect.new()
		bed.color = UI.PAPER
		bed.size = Vector2(58, 56)
		bed.position = mid + Vector2(bx, -28)
		bed.mouse_filter = IGNORE
		c.add_child(bed)
	for i in range(job.slots):
		var has: bool = job.bags.has(i)
		var b := Button.new()
		b.size = Vector2(72, 46)
		b.position = mid + (gaps[i] as Vector2) - Vector2(36, 23)
		b.focus_mode = Control.FOCUS_NONE
		for st in ["normal", "hover", "pressed", "focus", "disabled"]:
			var sb := StyleBoxFlat.new()
			sb.bg_color = Color(0.36, 0.62, 1.0) if has else Color(1, 1, 1, 0.07)
			sb.set_corner_radius_all(14)
			sb.set_border_width_all(3)
			sb.border_color = Color(0.85, 0.93, 1.0) if has else Color(1, 1, 1, 0.55)
			b.add_theme_stylebox_override(st, sb)
		UI.juice(b)
		b.pressed.connect(func(): _bag_tap(i))
		c.add_child(b)
	var through := int(round(100.0 - 70.0 * _rays_blocked() / float(job.rays.size())))
	var side := UI.vbox(2)
	side.position = Vector2(700, 40)
	c.add_child(side)
	side.add_child(UI.bold(t("storm_through"), 22))
	side.add_child(UI.title(str(through) + "%", 60, UI.COL_RAD))
	side.add_child(UI.bold(t("bags_left").format({"n": job.stock - job.bags.size()}), 22, UI.COL_PRO))
	return c

func _r_job() -> void:
	var v := _talk("cmd", t("cmd_do_a2") if (choice == "a" and start == "b") else t("cmd_do_" + choice))
	v.add_child(_wire_board() if choice == "b" else _bag_board())

## Which idea the typed answer is about. Plain word matching, on this device: no AI and nothing is sent anywhere.
func _why_kind(txt: String) -> String:
	var low := txt.to_lower()
	var groups: Array = [
		["team", ["together", "both", "team", "talk", "each other", "juntos", "equipo", "los dos", "platic", "hablar"]],
		["rad", ["radia", "storm", "shelter", "sols", "sun", "ray", "torment", "refugio", "soles", "rayo"]],
		["power", ["power", "energy", "light", "lamp", "oxygen", "plant", "unit", "energ", "luz", "luces", "oxíg", "oxig", "planta", "unidad"]],
	]
	for g in groups:
		for word in g[1]:
			if low.contains(word):
				return g[0]
	return "other"

func _why(txt: String) -> void:
	picks["why"] = txt.strip_edges().left(140)
	picks["why_kind"] = _why_kind(txt)
	_next_page()

## Crew debrief: the Commander asks why, the players type an answer, and the Commander replies to what they said.
func _r_debrief() -> void:
	var v := _modal(1100, 0.85)
	if page == 0:
		_modal_head(v, "cmd", t("why_q_met"), 30, 900, t("debrief_title"))
		var le := LineEdit.new()
		le.custom_minimum_size = Vector2(1040, 66)
		le.max_length = 140
		le.placeholder_text = t("why_hint")
		le.add_theme_font_override("font", UI.body_font())
		le.add_theme_font_size_override("font_size", 27)
		le.text_submitted.connect(_why)
		v.add_child(le)
		le.grab_focus.call_deferred()
		var row := UI.hbox(16)
		v.add_child(row)
		row.add_child(UI.button(t("btn_skip"), func(): _why(""), "Grey", 22))
		row.add_child(UI.spacer())
		row.add_child(UI.button(t("btn_send"), func(): _why(le.text), "Green", 30))
		v.add_child(UI.label(t("why_note"), 15, UI.SOFT, null, 1040))
		return
	_modal_head(v, "cmd", t("why_" + picks.get("why_kind", "other")), 26, 900, t("debrief_title"))
	if picks.get("why", "") != "":
		v.add_child(UI.label("“" + picks["why"] + "”", 21, UI.SOFT, null, 1040))
	v.add_child(UI.label(t("lesson_a"), 23, UI.PAPER, null, 1040))
	v.add_child(UI.bold(t("lesson_q"), 26, UI.COL_POWER, 1040))
	var foot := UI.hbox(16)
	v.add_child(foot)
	foot.add_child(UI.button(t("btn_data"), _finish, "Grey", 24))
	foot.add_child(UI.spacer())
	foot.add_child(UI.button(t("btn_other_storm"), _start_b, "Green", 30))

## One lettuce on the harvest board, drawn with shapes: tall and green, small and pale, or picked.
func _hv_plant(i: int, kind: String) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(124, 124)
	b.focus_mode = Control.FOCUS_NONE
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(1, 1, 1, 0.12 if st == "hover" else 0.05)
		sb.set_corner_radius_all(16)
		b.add_theme_stylebox_override(st, sb)
	var leaves: Array = []   # [x, y, size, colour]
	if kind == "ready":
		var g1 := Color(0.24, 0.74, 0.30)
		var g2 := Color(0.42, 0.88, 0.40)
		leaves = [[14, 34, 50, g1], [60, 34, 50, g1], [36, 14, 52, g2], [24, 50, 40, g2], [60, 52, 40, g2], [40, 40, 44, Color(0.62, 0.95, 0.50)]]
	elif kind == "small":
		var y1 := Color(0.66, 0.64, 0.30)
		leaves = [[42, 66, 22, y1], [60, 68, 20, y1.lightened(0.15)]]
	for lf in leaves:
		var dot := Panel.new()
		var ds := StyleBoxFlat.new()
		ds.bg_color = lf[3]
		ds.set_corner_radius_all(int(lf[2] / 2))
		dot.add_theme_stylebox_override("panel", ds)
		dot.position = Vector2(lf[0], lf[1])
		dot.size = Vector2(lf[2], lf[2])
		dot.mouse_filter = IGNORE
		b.add_child(dot)
	var pot := Panel.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.42, 0.28, 0.18)
	ps.set_corner_radius_all(8)
	pot.add_theme_stylebox_override("panel", ps)
	pot.position = Vector2(22, 88)
	pot.size = Vector2(80, 26)
	pot.mouse_filter = IGNORE
	b.add_child(pot)
	if kind == "gone":
		var ok := _tick(true, 44)
		ok.position = Vector2(40, 34)
		ok.size = Vector2(44, 44)
		ok.mouse_filter = IGNORE
		b.add_child(ok)
	else:
		UI.juice(b)
	b.pressed.connect(func(): _hv_tap(i))
	return b

## Harvest day: six plants, as in NASA's Veggie garden. The players pick the ones that got their light.
func _r_harvest() -> void:
	var done: bool = hv.picked.size() >= hv.ready
	var lead := t("hv_intro")
	if done:
		lead = t("hv_done_6") if hv.dark == 0 else t("hv_done_n").format({"n": hv.ready, "d": hv.dark})
	var v := _talk("cmd", lead)
	var row := UI.hbox(12)
	v.add_child(row)
	var states := _hv_states()
	for i in range(6):
		row.add_child(_hv_plant(i, states[i]))
	var side := UI.vbox(4)
	side.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(side)
	side.add_child(UI.title(t("hv_count").format({"n": hv.picked.size()}), 28, UI.COL_GOOD))
	if hv.msg == "small" and not done:
		side.add_child(UI.bold(t("hv_small"), 19, UI.COL_POWER, 250))
	if done:
		var foot := UI.hbox(16)
		v.add_child(foot)
		foot.add_child(UI.label(t("hv_fact"), 17, UI.SOFT, null, 520))
		foot.add_child(UI.spacer())
		foot.add_child(UI.button(t("btn_bonus"), _start_c, "Blue", 24))
		foot.add_child(UI.button(t("btn_finish"), _finish, "Green", 28))

## The free mission opens with its three goals, one line each.
func _r_f_hint() -> void:
	var v := _talk("cmd", t("f_hint_offer") if page == 0 else t("f_hint"))
	var row := UI.hbox(14)
	v.add_child(row)
	row.add_child(UI.spacer())
	if page == 0:
		row.add_child(UI.button(t("btn_hint_no"), func(): _f_hint_pick(false), "Grey", 24))
		row.add_child(UI.button(t("btn_hint_yes"), func(): _f_hint_pick(true), "Green", 28))
	else:
		row.add_child(UI.button(t("btn_ok"), func(): _go("f_intro"), "Green", 28))

func _r_f_intro() -> void:
	var again: bool = logb.free > 0   # the crew has heard the long version before
	var v := _talk("cmd", t("f_again") if again else t("f_intro%d" % (page + 1)))
	var row := UI.hbox(0)
	v.add_child(row)
	row.add_child(UI.spacer())
	if page < 2 and not again:
		row.add_child(_next_cue())
		row.add_child(UI.button(t("btn_next"), _next_page, "Blue", 26))
	else:
		row.add_child(UI.button(t("btn_start_mission"), func(): _go("f_decide"), "Green", 30))

func _f_note(role: String, text: String, small := "") -> PanelContainer:
	if not f.read[role]:
		# The report is closed until someone taps it: reading both before choosing is the crew's job.
		var c := PanelContainer.new()
		var loud: bool = _scaffold_tier() >= 2   # after hard missions the closed reports stand out
		var cs := UI.panel_box(UI.NAVY2, 14, 10)
		cs.set_border_width_all(6 if loud else 3)
		cs.border_color = UI.COL_POWER if loud else SPEAKER_COL[role]
		c.add_theme_stylebox_override("panel", cs)
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c.mouse_filter = Control.MOUSE_FILTER_STOP
		c.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		c.gui_input.connect(func(e: InputEvent): if e is InputEventMouseButton and e.pressed: _f_read(role))
		var ch := UI.hbox(10)
		ch.mouse_filter = IGNORE
		c.add_child(ch)
		var cb := UI.badge(_role_icon(role), SPEAKER_COL[role], 40)
		cb.mouse_filter = IGNORE
		ch.add_child(cb)
		var cl := UI.bold(t("f_read_" + role), 21, SPEAKER_COL[role])
		cl.mouse_filter = IGNORE
		ch.add_child(cl)
		if loud:
			var tag := _pill(t("f_read_first"), UI.COL_POWER, 15)
			ch.add_child(UI.spacer())
			ch.add_child(tag)
		return c
	var p := UI.panel(UI.NAVY2, 14, 10)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.mouse_filter = IGNORE
	var h := UI.hbox(10)
	p.add_child(h)
	h.add_child(UI.badge(_role_icon(role), SPEAKER_COL[role], 40))
	var tv := UI.vbox(2)
	h.add_child(tv)
	tv.add_child(UI.label(text, 19, UI.PAPER, null, 560))
	if small != "":
		tv.add_child(UI.label(small, 14, UI.SOFT, null, 560))
	return p

func _f_card(id: String) -> PanelContainer:
	var ok := _f_pick_ok(id)
	var both: bool = votes.eng == id and votes.pro == id
	var p := PanelContainer.new()
	var sb := UI.panel_box(UI.NAVY2, 20, 14)
	sb.set_border_width_all(4)
	sb.border_color = UI.PAPER if both else Color(1, 1, 1, 0.12)
	p.add_theme_stylebox_override("panel", sb)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := UI.vbox(8)
	p.add_child(v)
	var head := UI.hbox(10)
	v.add_child(head)
	if id == "s":
		head.add_child(UI.ui_icon("Yellow/Default/star.png", Color.WHITE, 38))
	else:
		head.add_child(UI.icon("energy-shield.svg" if id == "a" else "power-generator.svg", UI.COL_PRO if id == "a" else UI.COL_POWER, 38))
	head.add_child(UI.title(t("choice_" + id), 26, UI.PAPER, 330))
	if not ok:
		p.modulate.a = 0.6
		v.add_child(UI.label(t("f_b_none" if id == "b" else "f_s_done"), 21, UI.SOFT, null, 360))
		return p
	v.add_child(_fact(t("f_%s_gain" % id), "r", _tick(true, 26), 21, 320))
	v.add_child(_fact(t("f_%s_cost" % id), "r", _tick(false, 26), 21, 320))
	var bv := UI.hbox(18)
	bv.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(bv)
	for r in ["eng", "pro"]:
		var one := UI.vbox(2)
		bv.add_child(one)
		var b := UI.badge(_role_icon(r), SPEAKER_COL[r], 64, func(): _vote(r, id), votes[r] == id)
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_tip(b, t("tip_vote").format({"role": t("role_" + r)}))
		one.add_child(b)
		one.add_child(_centered(UI.label(t("role_" + r), 15, SPEAKER_COL[r])))
	return p

## The free mission's morning: both reports, where the mission stands, and three jobs to choose from.
func _r_f_decide() -> void:
	var v := _modal(1400, 0.78)
	_modal_head(v, "cmd", t("f_decide").format({"n": f.sol}), 34, 1100)
	v.add_child(UI.bold(t("f_status").format({"x": _n1(f.expo), "t": f.tanks, "s": t("f_sample_yes" if f.science else "f_sample_no")}), 20, UI.COL_GOOD, 1340))
	var notes := UI.hbox(14)
	v.add_child(notes)
	var made: int = _tanks_made(100.0 - 25.0 * f.offline)
	var eng_text := t("f_eng_ok") if f.offline == 0 else t("f_eng_off").format({"n": f.offline, "m": made, "m1": _tanks_made(100.0 - 25.0 * (f.offline - 1))})
	if f.fault:
		eng_text = t("f_fault") + " " + eng_text
	notes.add_child(_f_note("eng", eng_text))
	var pro_text := t("f_pro_none")
	var card := ""
	if f.storm != "none":
		var st: float = SUN_MSV[f.storm] / BG_MSV
		pro_text = t("f_pro_storm").format({"xt": _n1(st), "xs": _n1(st * SHELTER_K)})
		card = t("donki_a") if f.storm == "big" else t("f_card").format({"date": Strings.date(f.card[0], f.card[1], f.card[2], lang)})
	notes.add_child(_f_note("pro", pro_text, card))
	var row := UI.hbox(14)
	v.add_child(row)
	for id in ["a", "b", "s"]:
		row.add_child(_f_card(id))
	var agree: bool = votes.eng != "" and votes.eng == votes.pro
	var split: bool = votes.eng != "" and votes.pro != "" and not agree
	var foot := UI.hbox(16)
	v.add_child(foot)
	var msg := t("vote_hint_1") if players == 1 else t("vote_hint")
	if agree:
		msg = t("vote_ok")
	elif split:
		msg = t("vote_split")
	var fv := UI.vbox(4)
	foot.add_child(fv)
	if agree:
		# Predict before acting: how many tanks at dawn? The answer arrives the next morning.
		var prow := UI.hbox(8)
		fv.add_child(prow)
		prow.add_child(UI.bold(t("f_predict_q"), 21, UI.COL_POWER, 640))
		for n in range(TANKS_FULL + 1):
			prow.add_child(UI.button(str(n), func(): _f_guess(n), "Yellow" if f.guess == n else "Grey", 22))
		if _scaffold_tier() >= 1 and not (f.read.eng and f.read.pro):
			fv.add_child(UI.label(t("f_read_nudge"), 18, UI.COL_GOOD, null, 1000))
	else:
		fv.add_child(UI.bold(msg, 22, UI.COL_POWER if split else UI.PAPER, 900))
	if f.hint:
		fv.add_child(UI.label(t("f_hint_line"), 18, UI.COL_GOOD, null, 900))
	foot.add_child(UI.spacer())
	var go := UI.button(t("btn_go"), func(): _f_do(votes.eng), "Green", 32)
	go.disabled = not agree or f.guess < 0
	foot.add_child(go)

## The free mission's next morning: what today's job left.
func _r_f_result() -> void:
	var last: Dictionary = f.log[-1]
	var v := _talk("cmd", t("f_result").format({"n": f.sol}))
	v.add_child(_fact(t("f_r_rad").format({"a": _n1(last.add), "t": _n1(f.expo)}), "c", _tick(snappedf(f.expo, 0.1) <= F_RAD_GOAL, 29), 23, 900))
	v.add_child(_fact(t("f_r_o2_low" if last.low else "f_r_o2").format({"u": last.used, "m": last.made, "n": last.tanks}), "r", _tick(not last.low, 29), 23, 900))
	var lead: Control = _tick(true, 29) if f.science else (_tick(false, 29) if f.sol >= F_SOLS else null)
	v.add_child(_fact(t("f_r_sample_yes" if f.science else "f_r_sample_no"), "r", lead, 23, 900))
	if last.idle:
		v.add_child(UI.label(t("f_r_idle"), 21, UI.COL_POWER, null, 900))
	if last.storm != "none":
		# Earth answered too late, as on sol 30: the delay belongs to the free mission too.
		v.add_child(_fact(t("f_earth_late"), "r", UI.icon("sun.svg", SPEAKER_COL.earth, 28), 20, 1000))
	if int(last.get("guess", -1)) >= 0:
		var right: bool = int(last.guess) == int(last.tanks)
		v.add_child(UI.bold((t("predict_right") if right else t("predict_wrong")) + " " + t("f_pred_line").format({"g": int(last.guess), "n": int(last.tanks)}), 21, UI.COL_GOOD if right else UI.COL_POWER, 1000))
	var row := UI.hbox(0)
	v.add_child(row)
	row.add_child(UI.spacer())
	row.add_child(UI.button(t("btn_report") if f.sol >= F_SOLS else t("btn_next_sol"), _f_next, "Green", 28))

## The free mission's report: three goals, what decided it, and another mission one tap away.
func _r_f_end() -> void:
	var v := _modal(1180, 0.85)
	_modal_head(v, "cmd", t("f_end_title"), 32, 900)
	var met := _f_met()
	var rad_ok: bool = snappedf(f.expo, 0.1) <= F_RAD_GOAL
	var top := UI.hbox(12)
	v.add_child(top)
	top.add_child(_pill(t("f_end_ok") if met else t("f_end_no"), UI.COL_GOOD if met else UI.COL_POWER, 24))
	for e in f.log:
		top.add_child(_pill(t("f_log").format({"n": e.sol, "storm": t("f_st_" + e.storm), "job": t("f_job_" + e.job)}), UI.PAPER, 15))
	var stars := _f_stars()
	if stars > 0:
		# One star beside each goal that was met. With no star earned, only the tip is shown.
		top.add_child(_pill(t("f_stars").format({"n": stars}), COL_SCI, 18))
		v.add_child(_fact(t("f_r_sample_yes" if f.science else "f_g_sample_no"), "r", _star(f.science, 34), 24, 1000))
		v.add_child(_fact(t("f_g_rad").format({"t": _n1(f.expo)}), "c", _star(rad_ok, 34), 24, 1000))
		v.add_child(_fact(t("f_g_o2_no" if f.low else "f_g_o2_yes"), "r", _star(not f.low, 34), 24, 1000))
	var tip := t("f_tip_ok")
	if not met and f.blind > 0:
		tip = t("f_tip_read").format({"n": f.blind})
	elif not rad_ok:
		tip = t("f_tip_rad")
	elif f.low:
		tip = t("f_tip_o2")
	elif not f.science:
		tip = t("f_tip_sample")
	v.add_child(UI.bold(tip, 24, UI.COL_GOOD if met else UI.COL_POWER, 1120))
	if not met:
		v.add_child(UI.label(t("f_end_note"), 20, UI.PAPER, null, 1120))
	v.add_child(UI.label(t("osdr_fact"), 17, UI.SOFT, null, 1120))
	v.add_child(UI.label(t("f_deck_note"), 15, UI.SOFT, null, 1120))
	var foot := UI.hbox(14)
	v.add_child(foot)
	foot.add_child(UI.button(t("btn_data"), _open_data, "Grey", 22))
	foot.add_child(UI.button(t("btn_logbook"), _open_logbook, "Grey", 22))
	foot.add_child(UI.spacer())
	foot.add_child(UI.button(t("btn_again"), _play_again, "Blue", 24))
	foot.add_child(UI.button(t("btn_new_mission"), _start_free, "Green", 30))

func _lb_tile(value: String, label: String) -> PanelContainer:
	var p := UI.panel(UI.NAVY2, 16, 14)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.mouse_filter = IGNORE
	var v := UI.vbox(2)
	p.add_child(v)
	v.add_child(_centered(UI.title(value, 40, UI.COL_POWER)))
	v.add_child(_centered(UI.label(label, 16, UI.PAPER, null, 190)))
	return p

## The crew logbook: what this crew has done so far. It lives on the device and nowhere else.
func _r_logbook() -> void:
	var v := _modal(1180, 0.88)
	v.add_child(UI.title(t("lb_title"), 38))
	var tiles := UI.hbox(12)
	v.add_child(tiles)
	tiles.add_child(_lb_tile(str(logb.missions), t("lb_missions")))
	tiles.add_child(_lb_tile(t("lb_of").format({"n": logb.free_met, "m": logb.free}), t("lb_free")))
	tiles.add_child(_lb_tile(t("lb_of").format({"n": logb.pred_right, "m": logb.pred}), t("lb_pred")))
	tiles.add_child(_lb_tile(t("lb_of").format({"n": logb.both, "m": logb.sols}), t("lb_read")))
	tiles.add_child(_lb_tile(str(logb.stars), t("lb_stars")))
	if logb.missions == 0 and logb.pred == 0:
		v.add_child(UI.label(t("lb_empty"), 24, UI.PAPER, null, 1100))
	var recent: Array = logb.last
	if recent.size() >= 2:
		var a := 0
		for e in recent:
			a += 1 if e.met else 0
		var line := t("lb_recent").format({"a": a, "b": recent.size()})
		if logb.free > recent.size():
			line += " " + t("lb_before").format({"c": logb.free_met - a, "d": logb.free - recent.size()})
		v.add_child(UI.bold(line, 24, UI.COL_GOOD, 1100))
	if not recent.is_empty():
		v.add_child(UI.bold(t("lb_last"), 20, UI.SOFT))
		for i in range(recent.size() - 1, -1, -1):
			var e: Dictionary = recent[i]
			var row := UI.hbox(10)
			v.add_child(row)
			row.add_child(_tick(true, 24) if e.met else UI.label("•", 22, UI.COL_POWER))
			row.add_child(UI.label(_log_line(e), 18, UI.PAPER, null, 1080))
	if logb.free > 0:
		v.add_child(UI.label(t("lb_best").format({"n": logb.best}), 20, UI.PAPER, null, 1100))
	if not logb.sun.is_empty():
		v.add_child(UI.label(_log_sun_line(), 20, UI.PAPER, null, 1100))
	v.add_child(UI.label(t("lb_private"), 18, UI.SOFT, UI.bold_font(), 1100))
	var foot := UI.hbox(14)
	v.add_child(foot)
	foot.add_child(UI.button(t("btn_clear"), _log_clear, "Grey", 20))
	foot.add_child(UI.button(t("btn_copy"), _log_copy, "Grey", 20))
	if log_note != "":
		foot.add_child(UI.bold(log_note, 20, UI.COL_GOOD))
	foot.add_child(UI.spacer())
	foot.add_child(UI.button(t("btn_close"), _close_logbook, "Blue", 26))

## Development: a still picture for the last slide. The crew waves from Mars, a rocket stands behind the base,
## and the Commander leans out of the dialogue box. Built from the game's own models and shapes.
## Raises one of a model's own arms (the models have separate arm parts hinged at the shoulder).
func _dev_wave(model: Node, left: bool) -> void:
	var arm := model.find_child("armLeft" if left else "armRight", true, false)
	if arm is Node3D:
		(arm as Node3D).rotation.z = deg_to_rad(-150.0 if left else 150.0)

func _dev_poster() -> void:
	moon_done = true
	_start_mars()
	state = "poster"
	world.reset_scene()
	world.set_units_online(4)
	world.set_room_power(1.0, false)
	world.set_tanks(4)
	world.set_tappable([], [])
	world.set_goals([])
	world.set_controls({})
	var spots := {"eng": Vector3(1.55, 0, 2.55), "pro": Vector3(-0.35, 0, 2.55)}
	for r in ["eng", "pro"]:
		var n: Node3D = world.crew[r].node
		n.position = spots[r]
		n.scale = Vector3.ONE * 1.9
		for c in n.find_children("*", "Sprite3D", true, false):
			(c as Sprite3D).pixel_size *= 0.5   # the role badges stay, but small
		for c in n.get_children():
			if c != world.crew[r].body:
				(c as Node3D).visible = false   # no badges or floor rings in the picture
		_dev_wave(world.crew[r].body, r == "eng")   # each astronaut raises the arm on the outer side
	# The rocket, standing behind the base.
	var rk := Node3D.new()
	rk.position = Vector3(3.6, 0, -9.5)
	rk.scale = Vector3.ONE * 0.6
	world.add_child(rk)
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(0.95, 0.95, 0.98)
	var red := StandardMaterial3D.new()
	red.albedo_color = Color(0.92, 0.30, 0.22)
	var body := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.62
	cyl.bottom_radius = 0.62
	cyl.height = 3.4
	body.mesh = cyl
	body.material_override = white
	body.position.y = 2.3
	rk.add_child(body)
	var nose := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.62
	cone.height = 1.4
	nose.mesh = cone
	nose.material_override = red
	nose.position.y = 4.7
	rk.add_child(nose)
	for i in range(3):
		var a := TAU * float(i) / 3.0 + 0.5
		var fin: MeshInstance3D = world._box(Vector3(0.16, 1.3, 1.0), Vector3(sin(a) * 0.85, 0.75, cos(a) * 0.85), Color(0.92, 0.30, 0.22), rk)
		fin.rotation.y = a
	var win := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.26
	sm.height = 0.52
	win.mesh = sm
	var blue := StandardMaterial3D.new()
	blue.albedo_color = Color(0.35, 0.75, 1.0)
	win.material_override = blue
	win.position = Vector3(0.1, 3.1, 0.58)
	rk.add_child(win)
	# The Commander waves from the portrait.
	_dev_wave(portraits.cmd.holder, true)
	for c in (portraits.cmd.vp as SubViewport).get_children():
		if c is Camera3D:
			(c as Camera3D).look_at_from_position(Vector3(0.12, 0.60, 1.6), Vector3(-0.03, 0.52, 0), Vector3.UP)   # a wider frame, so the raised arm fits
	_render()

func _r_poster() -> void:
	# The Commander's own model rises from behind the dialogue box: it is drawn first, and the box covers its lower part.
	var face := TextureRect.new()
	face.texture = portraits.cmd.vp.get_texture()
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	face.mouse_filter = IGNORE
	ui.add_child(face)
	face.size = Vector2(360, 360)
	face.position = Vector2(ui.size.x - 430, ui.size.y - 18 - 215 - 255)
	var m := _margins(18)
	_full(m)
	var p := UI.panel(Color(0.09, 0.08, 0.15, 1.0), 30, 24)
	p.size_flags_vertical = Control.SIZE_SHRINK_END
	m.add_child(p)
	var v := UI.vbox(2)
	p.add_child(v)
	v.add_child(_name_tag("cmd"))
	v.add_child(UI.title("Play the game here!", 84, UI.PAPER))
	v.add_child(UI.bold("royito06.github.io/NasaSpaceApps2026/play", 36, UI.COL_POWER))

## Development: a cover picture for a slide. The title screen's deep space, with the two steps drawn:
## Earth to the Moon, then the Moon to Mars. Built from the game's own shapes.
func _dev_cover() -> void:
	_set_level(0)
	state = "cover"
	space.set_mode("", [], [])
	space.mode = "cover"
	# The Moon fills the foreground; Earth is small and far behind; Mars waits ahead.
	space.earth.scale = Vector3.ONE * 0.16
	space.earth.position = Vector3(1.5, -2.35, 0.0)
	var moon_n: Node3D = space.worlds.moon.node
	var mars_n: Node3D = space.worlds.mars.node
	for n in [moon_n, mars_n]:
		n.visible = true
	moon_n.rotation = Vector3(0.25, 0.9, 0.0)
	moon_n.scale = Vector3.ONE * 2.55
	moon_n.position = Vector3(-4.7, -2.0, 0.0)
	mars_n.rotation = Vector3(0.2, 0.6, 0.0)
	mars_n.scale = Vector3.ONE * 0.95
	mars_n.position = Vector3(4.75, 1.15, 0.0)
	# The two steps, as dotted arcs: Earth to the Moon, then the Moon to Mars.
	var dot_mat: StandardMaterial3D = space._mat(Color(1.0, 0.86, 0.45), true)
	var legs: Array = [[Vector3(0.95, -2.2, 0.3), Vector3(-2.0, -1.35, 0.3), 0.55, 7, -1.0], [Vector3(-2.35, 0.05, 0.3), Vector3(3.55, 0.85, 0.3), 0.3, 14, 0.78]]
	for leg in legs:
		var n_dots: int = leg[3]
		for i in range(1, n_dots):
			var k: float = float(i) / float(n_dots)
			if absf(k - float(leg[4])) < 0.11:
				continue   # the rocket sits here
			var dot: MeshInstance3D = space._ball(0.05, dot_mat, space)
			dot.position = (leg[0] as Vector3).lerp(leg[1], k) + Vector3(0, sin(PI * k) * float(leg[2]), 0)
	# The rocket, on its way from the Moon to Mars.
	var rk: float = 0.78
	space.rocket.visible = true
	space.rocket.scale = Vector3.ONE * 1.45
	space.rocket.position = (legs[1][0] as Vector3).lerp(legs[1][1], rk) + Vector3(0, sin(PI * rk) * 0.3, 0.3)
	space.rocket.rotation = Vector3(0, 0, deg_to_rad(-84.0))
	space.flame.visible = true
	space.flame.scale = Vector3.ONE
	_render()

func _r_cover() -> void:
	var edge := Color(0.02, 0.02, 0.06)
	var m := _margins(64)
	m.add_theme_constant_override("margin_top", 52)
	_full(m)
	var v := UI.vbox(6)
	m.add_child(v)
	v.add_child(UI.outlined(UI.title("Two Small Steps", 128, UI.PAPER), 16, edge))
	v.add_child(UI.outlined(UI.label(t("subtitle"), 40, UI.COL_POWER, null, 1100), 10, edge))
	var gap := Control.new()
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	gap.mouse_filter = IGNORE
	v.add_child(gap)
	var foot := UI.hbox(0)
	v.add_child(foot)
	foot.add_child(UI.spacer())
	var fv := UI.vbox(0)
	foot.add_child(fv)
	var l1 := UI.outlined(UI.bold("A game for ages 7 to 12", 30, UI.PAPER), 8, edge)
	l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	fv.add_child(l1)
	var l2 := UI.outlined(UI.label("Challenge: Build a Junior Astronaut Mission Trainer", 24, UI.SOFT), 6, edge)
	l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	fv.add_child(l2)

## Development: the rule a child can say out loud, used to test the free mission.
func _f_rule() -> String:
	var can_go: bool = f.tanks - 1 + _tanks_made(100.0 - 25.0 * f.offline) - TANKS_USED >= 1
	if f.storm == "big":
		return "a"
	if not f.science and can_go and (f.offline == 0 or f.sol == F_SOLS):
		return "s"
	if f.offline > 0:
		return "b"
	if not f.science and can_go:
		return "s"
	return "a"

## Development: plays the job's little game the way a player would.
func _job_solve() -> void:
	if choice == "b":
		for i in range(job.n):
			_wire_pick(i)
			await _wire_plug(job.order.find(i))
	else:
		for r in (job.rays as Array).duplicate():
			await _bag_tap(r)

## Settings: voice, motion, and the tags that say where each number comes from.
func _r_settings() -> void:
	var v := _modal(980, 0.8)
	v.add_child(UI.title(t("settings_title"), 38))
	var rows: Array = [
		[t("btn_voice_on") if voice_on else t("btn_voice_off"), _toggle_voice, voice_on, t("set_voice_hint")],
		[t("btn_motion_off") if world.reduced_motion else t("btn_motion_on"), _toggle_motion, world.reduced_motion, t("set_motion_hint")],
		[t("set_sources_on") if show_src else t("set_sources_off"), _toggle_sources, show_src, t("set_sources_hint")],
	]
	for r in rows:
		var row := UI.hbox(18)
		v.add_child(row)
		var b := UI.button(r[0], r[1], "Yellow" if r[2] else "Grey", 24)
		b.custom_minimum_size.x = 400
		row.add_child(b)
		row.add_child(UI.label(r[3], 20, UI.SOFT, null, 480))
	var foot := UI.hbox(0)
	foot.alignment = BoxContainer.ALIGNMENT_END
	v.add_child(foot)
	foot.add_child(UI.button(t("btn_close"), _close_settings, "Blue", 26))

## "NASA data used": every number, its label and its source.
func _r_data() -> void:
	var v := _modal(1380, 0.88)
	v.add_child(UI.title(t("data_title"), 38))
	var legend := UI.hbox(10)
	v.add_child(legend)
	for k in ["m", "c", "r"]:
		legend.add_child(UI.chip(t("chip_" + k), k))
		legend.add_child(UI.label(t("data_legend_" + k) + "   ", 18, UI.SOFT))
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(1320, 500)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(sc)
	var list := UI.vbox(12)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(list)
	for row in Strings.DATA_ROWS:
		var h := UI.hbox(12)
		list.add_child(h)
		var slot := Control.new()
		slot.custom_minimum_size = Vector2(150, 26)
		slot.mouse_filter = IGNORE
		h.add_child(slot)
		slot.add_child(UI.chip(t("chip_" + row[0]), row[0]))
		var tv := UI.vbox(0)
		h.add_child(tv)
		tv.add_child(UI.label(row[2] if lang == "es" else row[1], 20, UI.PAPER, null, 1120))
		if row[3] != "":
			tv.add_child(UI.label(row[3], 16, UI.SOFT, null, 1120))
	list.add_child(UI.bold(t("credits_title"), 22, UI.COL_POWER))
	list.add_child(UI.label(t("credits"), 17, UI.SOFT, null, 1280))
	var foot := UI.hbox(16)
	foot.alignment = BoxContainer.ALIGNMENT_END
	v.add_child(foot)
	if state == "end":
		foot.add_child(UI.button(t("lang_button"), _toggle_lang, "Yellow", 22))
		foot.add_child(UI.button(t("btn_again"), _play_again, "Green", 28))
	else:
		foot.add_child(UI.button(t("btn_close"), _close_data, "Blue", 26))

# ---------------------------------------------------------------- development helpers

# `-- --shot=/abs/file.png [--wait=2] [--demo=name] [--es] [--p2] [--src]` jumps to a screen, saves one screenshot and quits.
# `-- --demo=auto [--slow]` plays the whole game and prints AUTO OK; `-- --demo=keys` tests keyboard steering.
func _dev_hooks() -> void:
	var shot := ""
	var wait := 2.0
	var demo := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shot="):
			shot = a.trim_prefix("--shot=")
		elif a.begins_with("--wait="):
			wait = float(a.trim_prefix("--wait="))
		elif a.begins_with("--demo="):
			demo = a.trim_prefix("--demo=")
		elif a == "--es":
			lang = "es"
		elif a == "--p2":
			players = 2
		elif a == "--src":
			show_src = true
	if demo == "logwrite":
		# development: prove the logbook survives a restart (run logwrite, then logread)
		logb = _log_blank()
		logb.missions = 3
		logb.last = [{"met": true, "sols": [["none", "b"], ["small", "s"], ["big", "a"]]}]
		_log_save()
		print("LOG written")
		get_tree().quit()
		return
	if demo == "logread":
		print("LOG read: missions=%d last=%s" % [logb.missions, str(logb.last)])
		_log_clear()
		get_tree().quit()
		return
	if demo != "":
		log_keep = false
		logb = _log_blank()
	if demo == "keys":
		await _dev_keys()
	elif demo != "":
		await _dev_demo(demo)
	if OS.get_cmdline_user_args().has("--quit"):
		get_tree().quit()
		return
	if shot != "":
		await get_tree().create_timer(wait).timeout
		get_viewport().get_texture().get_image().save_png(shot)
		get_tree().quit()

func _dev_key(code: Key, down: bool) -> void:
	var e := InputEventKey.new()
	e.physical_keycode = code
	e.keycode = code
	e.pressed = down
	Input.parse_input_event(e)

## Smoke test for keyboard steering: prints what happened so a headless run can check it.
func _dev_keys() -> void:
	_start_mars()
	page = 4   # past the narrator's briefing, which holds the crew still
	_render()
	await _dev_step()
	var p0: Vector3 = world.crew.pro.node.position
	_dev_key(KEY_A, true)
	await get_tree().create_timer(3.0).timeout
	_dev_key(KEY_A, false)
	print("KEYS 1P: eng walked left to x=%.2f (wall stops it near -3.2); pro untouched=%s" % [world.crew.eng.node.position.x, str(world.crew.pro.node.position == p0)])
	_dev_key(KEY_SPACE, true)
	_dev_key(KEY_SPACE, false)
	await _dev_step()
	print("KEYS 1P: after Space active=", active)
	_dev_key(KEY_UP, true)
	await get_tree().create_timer(1.2).timeout
	_dev_key(KEY_UP, false)
	await _dev_step()
	print("KEYS 1P: pro walked up with arrows, state=", state, " (p_term = Protection reached its console, the NASA terminal)")
	players = 2
	_start_mars()
	page = 4
	_render()
	await _dev_step()
	_dev_key(KEY_W, true)
	_dev_key(KEY_LEFT, true)
	await get_tree().create_timer(0.5).timeout
	_dev_key(KEY_W, false)
	_dev_key(KEY_LEFT, false)
	print("KEYS 2P: eng z=%.2f (W moves it up from 0.45), pro x=%.2f (Left moves it from -0.50)" % [world.crew.eng.node.position.z, world.crew.pro.node.position.x])
	get_tree().quit()

func _dev_step() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _dev_demo(demo: String) -> void:
	world.reduced_motion = not OS.get_cmdline_user_args().has("--slow")
	live_off = not OS.get_cmdline_user_args().has("--live")
	var order := ["m_card", "m_term", "m_deploy", "m_drive", "m_drive2", "m_ask", "m_collect", "m_return", "m_result", "m_retry", "m_compare", "m_drop", "to_mars", "meet", "brief", "meet2", "role_eng", "p_term", "role_pro", "ask_earth", "earth_far", "earth_q", "earth_fb", "decide", "decide_voted", "go_job", "do_job", "storm_a", "storm_a2", "night_a", "result_a", "retry", "retry_pred", "storm_b", "night_b", "result_b", "compare", "debrief", "start_b", "b_decide", "b_result", "b_compare", "harvest", "harvest_done", "c_meet", "c_term", "c_role", "c_decide", "c_result", "f_intro", "f_decide", "f_result", "f_end", "data"]
	var upto := order.find(demo)
	var auto := demo == "auto"
	if auto:
		upto = order.size() - 1
	if demo == "m_photo":
		upto = order.find("m_collect")
	if demo == "f_predict" or demo == "f_nudge":
		upto = order.find("f_decide")
	if demo == "settings":
		_start_mars()
		_open_settings()
	elif demo == "wire" or demo == "bags2":
		# development: jump straight to a job's little game
		moon_done = true
		_start_mars()
		if demo == "bags2":
			start = "b"
			_reset_run()
		reported = {"eng": true, "pro": true}
		choice = "b" if demo == "wire" else "a"
		await _arrive_job()
		if demo == "wire":
			_wire_pick(0)
			await _wire_plug(job.order.find(0))
			_wire_pick(1)
		else:
			await _bag_tap(1)
			await _bag_tap(0)
	elif demo == "cover":
		_dev_cover()
		world.reduced_motion = false
		return
	elif demo == "poster":
		_dev_poster()
		world.reduced_motion = false
		return
	elif demo == "f_sim":
		# development: play many free missions with the rule a child can say, and count how many meet the goals
		var met := 0
		var fail_seed := -1
		for n in range(300):
			seed(1000 + n)
			_start_free()
			while true:
				f.read = {"eng": true, "pro": true}
				await _f_do(_f_rule())
				if f.sol >= F_SOLS:
					break
				_f_next()
			if _f_met():
				met += 1
			elif fail_seed < 0:
				fail_seed = 1000 + n
		print("FSIM met=%d of 300, first failing seed=%d" % [met, fail_seed])
		get_tree().quit()
		return
	elif demo == "hint" or demo == "hint2" or demo == "logbook":
		# development: free missions played badly (always the shelter, reports unread) or well (the child's rule)
		moon_done = true
		for n in range(2 if demo != "logbook" else 4):
			seed(40 + n)
			_start_free()
			while true:
				if demo == "logbook" and n != 1:
					f.read = {"eng": true, "pro": true}
				await _f_do(_f_rule() if (demo == "logbook" and n != 1) else "a")
				if f.sol >= F_SOLS:
					break
				_f_next()
			_f_next()
		if demo == "logbook":
			_go("select")
			_open_logbook()
		else:
			seed(42)
			_start_free()
			if demo == "hint2":
				_f_hint_pick(true)
	elif demo == "players":
		_go("players")
	elif demo == "select":
		_go("select")
	elif demo == "select2":
		moon_done = true
		_go("select")
	for i in range(upto + 1):
		match order[i]:
			"m_card":
				_start_moon()
			"m_term":
				_land_moon()
				await _dev_step()
				await _term_run("moon")
				if OS.get_cmdline_user_args().has("--live"):
					print("LIVE moon: ok=", term.moon.ok, " title=", term.moon.get("title", ""), " date=", term.moon.get("date", ""))
			"m_deploy":
				_go("m_deploy")
				await _dev_step()
				m_dep = 0.5
				dep_a = true
			"m_drive":
				_deploy_done()
			"m_drive2":
				m_briefed = true
				page = 2
				_render()
			"m_ask":
				await _m_ask()
			"m_collect":
				_go("m_drive")
				await _dev_step()
				await _m_arrive("far", true)
			"m_return":
				await _m_dig(2)
				await _dev_step()
				await _m_take_photo()
				for rock in [2, 0, 1]:
					await _m_dig(rock)
			"m_result":
				await _m_home(true)
			"m_retry":
				await _m_retry()
			"m_compare":
				_go("m_compare")
			"m_drop":
				_pick("m_plan", "near")
				await _dev_step()
				moon.set_drop(true)
				_go("m_drop")
				await _dev_step()
				_drop_predict("same")
				await _drop("moon")
			"to_mars":
				_moon_complete()
				await _dev_step()
				_on_tapped("mars")
			"meet":
				moon_done = true
				_start_mars()
			"brief":
				page = 2
				_render()
			"meet2":
				page = 4
				_render()
			"role_eng":
				await _open_role("eng")
			"p_term":
				_tell("eng")
				await _dev_step()
				await _open_role("pro")
				await _term_run("mars")
				if OS.get_cmdline_user_args().has("--live"):
					print("LIVE mars: ", term.mars)
			"role_pro":
				_go("role_pro")
			"ask_earth":
				_tell("pro")
			"earth_far":
				await _send_message("eng")
			"earth_q":
				_next_page()
			"earth_fb":
				_guess("no")
			"decide":
				_go("decide")
			"decide_voted":
				_vote("eng", "a")
				_vote("pro", "a")
			"go_job":
				_start_job("a")
			"do_job":
				await _arrive_job()
			"storm_a":
				await _job_solve()
			"storm_a2":
				_next_page()
			"night_a":
				await _advance()
			"result_a":
				_to_morning()
			"retry":
				_retry()
			"retry_pred":
				_pick("predict", "more")
			"storm_b":
				choice = "b"
				job = {}
				await _auto_job()
			"night_b":
				await _advance()
			"result_b":
				_to_morning()
			"compare":
				_go("compare")
			"debrief":
				_pick("plan", "a")
				await _dev_step()
				_go("debrief")
			"start_b":
				_why("because of the storm")
				await _dev_step()
				_start_b()
			"b_decide":
				_tell("eng")
				_tell("pro")
			"b_result":
				_vote("eng", "b")
				_vote("pro", "b")
				_start_job("b")
				await _dev_step()
				await _arrive_job()
				await _job_solve()
				await _advance()
				_to_morning()
			"b_compare":
				await _skip_retry()
				_go("compare")
			"harvest":
				_pick("plan", "b")
				await _dev_step()
				_start_harvest()
			"harvest_done":
				_hv_tap(5)
				for plant in range(hv.ready):
					_hv_tap(plant)
			"c_meet":
				var args := OS.get_cmdline_user_args()
				if args.has("--calm"):
					_live["mars"] = {"ok": true, "records": 0, "days": 0, "latest": "", "at": "09:00"}
				elif args.has("--sunstorm"):
					_live["mars"] = {"ok": true, "records": 1, "days": 1, "latest": Time.get_date_string_from_system() + "T02:00Z", "at": "09:00"}
				_start_c()
			"c_term":
				await _open_role("eng")
				_tell("eng")
				await _dev_step()
				await _open_role("pro")
				await _term_run("mars")
			"c_role":
				_go("role_pro")
			"c_decide":
				_tell("pro")
			"c_result":
				_vote("eng", "b")
				_vote("pro", "b")
				_start_job("b")
				await _dev_step()
				await _arrive_job()
				await _job_solve()
				if state == "storm":
					await _advance()
				_to_morning()
			"f_intro":
				var fseed := 7
				for a in OS.get_cmdline_user_args():
					if a.begins_with("--seed="):
						fseed = int(a.trim_prefix("--seed="))
				seed(fseed)
				_start_free()
			"f_decide":
				_go("f_decide")
			"f_result":
				_f_read("eng")
				_f_read("pro")
				_vote("eng", _f_rule())
				await _dev_step()
				_f_guess(3)
				await _dev_step()
				await _f_do(votes.eng)
			"f_end":
				while f.sol < F_SOLS:
					_f_next()
					await _dev_step()
					f.read = {"eng": true, "pro": true}
					await _f_do(_f_rule())
				_f_next()
			"data":
				_finish()
		await _dev_step()
	if demo == "f_predict":
		_f_read("eng")
		_f_read("pro")
		_vote("eng", "a")
		_f_guess(2)
	if demo == "f_nudge":
		logb.streak = 2
		_vote("eng", "b")
	if demo == "m_photo":
		await _m_dig(2)
		await _dev_step()
		await _m_take_photo()
	world.reduced_motion = false
	space.reduced_motion = false
	if state == "to_mars" or state == "to_moon":
		space.restart_travel()   # the demo ran without motion: start the trip again so it can be seen
	live_off = false
	_spoken = ""
	_drawn = ""
	_render()
	if auto:
		await _dev_step()
		_toggle_lang()
		await _dev_step()
		print("AUTO OK")
		get_tree().quit()
