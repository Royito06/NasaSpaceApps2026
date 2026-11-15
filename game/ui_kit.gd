extends RefCounted
## Small helpers to build the kid-facing UI from the Kenney UI Pack (CC0) and the two fonts (OFL).
## Big tap targets, short text, high contrast.

const PNG := "res://assets/kenney_ui/PNG/"
const INK := Color(0.10, 0.09, 0.16)
const PAPER := Color(0.99, 0.96, 0.90)
const SOFT := Color(0.80, 0.80, 0.90)
const NAVY := Color(0.09, 0.08, 0.15, 0.94)
const NAVY2 := Color(0.17, 0.16, 0.27, 1.0)
const COL_POWER := Color(1.0, 0.78, 0.25)
const COL_RAD := Color(0.76, 0.56, 1.0)
const COL_ENG := Color(1.0, 0.74, 0.22)
const COL_PRO := Color(0.42, 0.82, 1.0)
const COL_GOOD := Color(0.45, 0.92, 0.55)
const COL_COST := Color(1.0, 0.55, 0.45)
const CHIP := {"m": Color(0.55, 0.92, 0.62), "c": Color(0.60, 0.82, 1.0), "r": Color(1.0, 0.85, 0.42)}

static var reduced := false   # "Less motion": every animation here is skipped
static var _title: Font
static var _body: Font
static var _bold: Font

static func title_font() -> Font:
	if _title == null:
		var fv := FontVariation.new()
		fv.base_font = load("res://assets/fonts/Fredoka.ttf")
		fv.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 600}
		_title = fv
	return _title

static func body_font() -> Font:
	if _body == null:
		_body = load("res://assets/fonts/AtkinsonHyperlegible-Regular.ttf")
	return _body

static func bold_font() -> Font:
	if _bold == null:
		_bold = load("res://assets/fonts/AtkinsonHyperlegible-Bold.ttf")
	return _bold

static func _scale_to(c: Control, to: float, dur: float) -> void:
	if not is_instance_valid(c) or not c.is_inside_tree():
		return
	if reduced:
		c.scale = Vector2.ONE
		return
	c.pivot_offset = c.size * 0.5
	c.create_tween().tween_property(c, "scale", Vector2(to, to), dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## Buttons grow a little under the pointer and squash a little when pressed.
static func juice(b: BaseButton) -> void:
	b.mouse_entered.connect(func(): if not b.disabled: _scale_to(b, 1.04, 0.12))
	b.mouse_exited.connect(func(): _scale_to(b, 1.0, 0.12))
	b.button_down.connect(func(): _scale_to(b, 0.97, 0.06))
	b.button_up.connect(func(): _scale_to(b, 1.04 if b.is_hovered() else 1.0, 0.12))

## A text label. wrap_w > 0 wraps the text at that width; -1 wraps and fills the row.
static func label(text: String, size := 24, col := PAPER, font: Font = null, wrap_w := 0) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", font if font != null else body_font())
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if wrap_w != 0:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if wrap_w > 0:
			l.custom_minimum_size.x = wrap_w
		else:
			l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l

static func title(text: String, size := 40, col := PAPER, wrap_w := 0) -> Label:
	return label(text, size, col, title_font(), wrap_w)

static func bold(text: String, size := 24, col := PAPER, wrap_w := 0) -> Label:
	return label(text, size, col, bold_font(), wrap_w)

static func outlined(l: Label, width := 8, col := Color(0.16, 0.08, 0.05)) -> Label:
	l.add_theme_color_override("font_outline_color", col)
	l.add_theme_constant_override("outline_size", width)
	return l

static func hbox(sep := 10) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return h

static func vbox(sep := 10) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return v

static func spacer() -> Control:
	var c := Control.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c

static func panel_box(bg := NAVY, radius := 22, pad := 22) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(pad)
	return sb

static func panel(bg := NAVY, radius := 22, pad := 22) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", panel_box(bg, radius, pad))
	return p

## A big rounded button. colour is one of the Kenney UI Pack folders: Blue, Green, Grey, Red, Yellow.
static func button(text: String, cb: Callable, colour := "Blue", size := 26) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", title_font())
	b.add_theme_font_size_override("font_size", size)
	var tex: Texture2D = load(PNG + colour + "/Default/button_rectangle_depth_flat.png")
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		var sb := StyleBoxTexture.new()
		sb.texture = tex
		sb.texture_margin_left = 16
		sb.texture_margin_right = 16
		sb.texture_margin_top = 12
		sb.texture_margin_bottom = 18
		sb.content_margin_left = 26
		sb.content_margin_right = 26
		sb.content_margin_top = 10
		sb.content_margin_bottom = 16
		if st == "hover":
			sb.modulate_color = Color(1.1, 1.1, 1.1)
		elif st == "pressed":
			sb.modulate_color = Color(0.85, 0.85, 0.85)
		elif st == "disabled":
			sb.modulate_color = Color(0.55, 0.55, 0.6, 0.6)
		b.add_theme_stylebox_override(st, sb)
	var dark: bool = colour == "Yellow" or colour == "Grey"
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(c, INK if dark else Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.55))
	b.custom_minimum_size = Vector2(0, 60)
	b.focus_mode = Control.FOCUS_NONE   # keys steer the astronauts, never the buttons
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.pressed.connect(cb)
	juice(b)
	return b

static func icon(file: String, col: Color, px := 44) -> TextureRect:
	var t := TextureRect.new()
	t.texture = load("res://assets/icons/" + file)
	t.modulate = col
	t.custom_minimum_size = Vector2(px, px)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

static func ui_icon(file: String, col: Color, px := 28) -> TextureRect:
	var t := TextureRect.new()
	t.texture = load(PNG + file)
	t.modulate = col
	t.custom_minimum_size = Vector2(px, px)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

## A round role badge. As a button it is used to vote; `on` draws it selected.
static func badge(icon_file: String, col: Color, px := 64, cb := Callable(), on := true) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(px, px)
	b.icon = load("res://assets/icons/" + icon_file)
	b.expand_icon = true
	b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = col if on else col.darkened(0.6)
		if st == "hover" and not on:
			sb.bg_color = col.darkened(0.4)
		sb.set_corner_radius_all(px / 2)
		sb.set_content_margin_all(px * 0.16)
		if on and cb.is_valid():
			sb.set_border_width_all(5)
			sb.border_color = Color.WHITE
		b.add_theme_stylebox_override(st, sb)
	for c in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color", "icon_disabled_color"]:
		b.add_theme_color_override(c, INK if on else Color(1, 1, 1, 0.75))
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.focus_mode = Control.FOCUS_NONE
	if cb.is_valid():
		b.pressed.connect(cb)
		juice(b)
	else:
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b

## A value bar made from the UI Pack slider track.
static func bar(col: Color, width := 300, height := 24) -> TextureProgressBar:
	var p := TextureProgressBar.new()
	p.texture_under = load(PNG + "Grey/Default/slide_horizontal_grey.png")
	p.texture_progress = load(PNG + "Grey/Default/slide_horizontal_color.png")
	p.tint_under = Color(0.55, 0.55, 0.62)
	p.tint_progress = col
	p.nine_patch_stretch = true
	p.stretch_margin_left = 8
	p.stretch_margin_right = 8
	p.stretch_margin_top = 4
	p.stretch_margin_bottom = 4
	p.custom_minimum_size = Vector2(width, height)
	p.max_value = 100.0
	p.step = 0.1
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p

## A small tag that says where a number comes from. kind: "m" measurement, "c" calculation, "r" game rule.
static func chip(text: String, kind: String) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = CHIP.get(kind, Color.WHITE)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 9
	sb.content_margin_right = 9
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	p.add_theme_stylebox_override("panel", sb)
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	p.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(label(text, 15, INK, bold_font()))
	return p

## A vertical value bar that fills from the bottom. Returns {"root": Control, "fill": Panel}.
static func vbar(col: Color, w := 56, h := 180, floating := false) -> Dictionary:
	var root := Control.new()
	root.custom_minimum_size = Vector2(w, h)
	root.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 0.16)
	if floating:
		# No box behind it: a dark track with a light rim reads on any background.
		sb.bg_color = Color(0.09, 0.08, 0.15, 0.62)
		sb.set_border_width_all(2)
		sb.border_color = Color(1, 1, 1, 0.75)
	sb.set_corner_radius_all(min(14, w / 3))
	bg.add_theme_stylebox_override("panel", sb)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bg)
	var fill := Panel.new()
	var fb := StyleBoxFlat.new()
	fb.bg_color = col
	fb.set_corner_radius_all(min(11, w / 4))
	fill.add_theme_stylebox_override("panel", fb)
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill.anchor_left = 0.0
	fill.anchor_right = 1.0
	fill.anchor_bottom = 1.0
	fill.offset_left = 4
	fill.offset_right = -4
	fill.offset_bottom = -4
	root.add_child(fill)
	vbar_set(fill, 0.0)
	return {"root": root, "fill": fill}

static func vbar_set(fill: Panel, frac: float) -> void:
	fill.anchor_top = 1.0 - clampf(frac, 0.04, 0.97)
	fill.offset_top = 0
