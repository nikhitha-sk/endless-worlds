# CourseSetup.gd
# Popup that lets the player configure and start a Course (sequence of 5 games).
# Built entirely in code — no .tscn file required.

extends CanvasLayer
class_name CourseSetup

const FONT_PATH   := "res://Jersey10-Regular.ttf"
const LAYER_IDX   := 25

const BG_COLOR    := Color(0.08, 0.05, 0.18, 0.95)
const ACCENT      := Color(0.72, 0.40, 0.10, 1.0)
const GOLD        := Color(1.0, 0.85, 0.3, 1.0)
const BTN_NORMAL  := Color(0.20, 0.10, 0.35, 1.0)
const BTN_HOVER   := Color(0.32, 0.18, 0.52, 1.0)
const BTN_SEL     := Color(0.55, 0.28, 0.08, 1.0)

const PANEL_W := 560.0
const PANEL_H := 440.0

const PREDEFINED_TOPICS := [
	"programming",
	"mathematics",
	"science",
	"history",
	"geography",
]

var _overlay: ColorRect
var _panel: Panel
var _topic_buttons: Array = []
var _selected_topic_idx: int = 0
var _custom_input: LineEdit
var _submit_btn: Button

# ─── Public API ───────────────────────────────────────────────────────────────
func open() -> void:
	await _build_ui()
	_animate_open()


func close() -> void:
	_animate_close()


# ─── Build UI ─────────────────────────────────────────────────────────────────
func _build_ui() -> void:
	layer = LAYER_IDX

	# Dim overlay
	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)

	# Main panel
	_panel = Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = BG_COLOR
	sb.corner_radius_top_left     = 16
	sb.corner_radius_top_right    = 16
	sb.corner_radius_bottom_left  = 16
	sb.corner_radius_bottom_right = 16
	sb.border_width_left   = 2
	sb.border_width_top    = 2
	sb.border_width_right  = 2
	sb.border_width_bottom = 2
	sb.border_color = ACCENT
	_panel.add_theme_stylebox_override("panel", sb)
	_panel.custom_minimum_size = Vector2(PANEL_W, PANEL_H)
	_panel.size = Vector2(PANEL_W, PANEL_H)
	_panel.pivot_offset = Vector2(PANEL_W * 0.5, PANEL_H * 0.5)
	_panel.modulate.a = 0.0
	add_child(_panel)

	# Centre panel in viewport
	await get_tree().process_frame
	var vp := get_viewport().get_visible_rect().size
	_panel.position = Vector2((vp.x - PANEL_W) * 0.5, (vp.y - PANEL_H) * 0.5)

	var y := 20.0

	# Title
	var title := _make_label("🎓 Course Mode", 32, GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.position = Vector2(0, y)
	title.custom_minimum_size = Vector2(PANEL_W, 44)
	_panel.add_child(title)
	y += 52.0

	# Subtitle
	var sub := _make_label("Choose a topic (or enter your own):", 18, Color(0.85, 0.85, 0.85))
	sub.position = Vector2(20, y)
	sub.custom_minimum_size = Vector2(PANEL_W - 40, 28)
	_panel.add_child(sub)
	y += 34.0

	# Predefined topic buttons (2 per row)
	const BTN_W := 240.0
	const BTN_H := 38.0
	const BTN_GAP := 16.0
	var row_x := (PANEL_W - 2 * BTN_W - BTN_GAP) * 0.5
	for i in range(PREDEFINED_TOPICS.size()):
		var col := i % 2
		var row := i / 2
		var bx := row_x + col * (BTN_W + BTN_GAP)
		var by := y + row * (BTN_H + 8.0)
		var btn := _make_topic_btn(PREDEFINED_TOPICS[i].capitalize(), i)
		btn.position = Vector2(bx, by)
		btn.custom_minimum_size = Vector2(BTN_W, BTN_H)
		btn.size = Vector2(BTN_W, BTN_H)
		_panel.add_child(btn)
		_topic_buttons.append(btn)

	var topic_rows := ceili(PREDEFINED_TOPICS.size() / 2.0)
	y += topic_rows * (BTN_H + 8.0) + 12.0

	_update_topic_button_styles()

	# Separator
	var sep := ColorRect.new()
	sep.color = ACCENT
	sep.custom_minimum_size = Vector2(PANEL_W - 40, 1)
	sep.size = Vector2(PANEL_W - 40, 1)
	sep.position = Vector2(20, y)
	_panel.add_child(sep)
	y += 12.0

	# Custom topic label
	var custom_lbl := _make_label("Or type a custom topic:", 17, Color(0.75, 0.75, 0.75))
	custom_lbl.position = Vector2(20, y)
	_panel.add_child(custom_lbl)
	y += 28.0

	# Custom topic input
	_custom_input = LineEdit.new()
	_custom_input.placeholder_text = "e.g. space exploration"
	_custom_input.add_theme_font_override("font", load(FONT_PATH))
	_custom_input.add_theme_font_size_override("font_size", 20)
	_custom_input.add_theme_color_override("font_color", Color(1, 1, 1))
	_custom_input.add_theme_color_override("font_placeholder_color", Color(0.55, 0.55, 0.55))
	var input_sb := StyleBoxFlat.new()
	input_sb.bg_color = Color(0.15, 0.08, 0.28, 1.0)
	input_sb.corner_radius_top_left     = 8
	input_sb.corner_radius_top_right    = 8
	input_sb.corner_radius_bottom_left  = 8
	input_sb.corner_radius_bottom_right = 8
	input_sb.border_width_left   = 2
	input_sb.border_width_top    = 2
	input_sb.border_width_right  = 2
	input_sb.border_width_bottom = 2
	input_sb.border_color = ACCENT
	input_sb.content_margin_left   = 10
	input_sb.content_margin_right  = 10
	input_sb.content_margin_top    = 6
	input_sb.content_margin_bottom = 6
	_custom_input.add_theme_stylebox_override("normal", input_sb)
	_custom_input.add_theme_stylebox_override("focus", input_sb)
	_custom_input.custom_minimum_size = Vector2(PANEL_W - 40, 40)
	_custom_input.size = Vector2(PANEL_W - 40, 40)
	_custom_input.position = Vector2(20, y)
	_custom_input.text_changed.connect(func(_t): _selected_topic_idx = -1; _update_topic_button_styles())
	_panel.add_child(_custom_input)
	y += 52.0

	# Submit button
	_submit_btn = _make_action_btn("▶ Start Course (5 Games)")
	_submit_btn.custom_minimum_size = Vector2(PANEL_W - 40, 46)
	_submit_btn.size = Vector2(PANEL_W - 40, 46)
	_submit_btn.position = Vector2(20, y)
	_submit_btn.pressed.connect(_on_submit)
	_panel.add_child(_submit_btn)

	# Close button (top-right corner)
	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.add_theme_font_override("font", load(FONT_PATH))
	close_btn.add_theme_font_size_override("font_size", 24)
	close_btn.add_theme_color_override("font_color", ACCENT)
	close_btn.add_theme_stylebox_override("normal", _flat_sb(Color(0, 0, 0, 0), 0))
	close_btn.add_theme_stylebox_override("hover", _flat_sb(Color(1, 1, 1, 0.15), 4))
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.custom_minimum_size = Vector2(36, 36)
	close_btn.position = Vector2(PANEL_W - 44, 8)
	close_btn.pressed.connect(close)
	_panel.add_child(close_btn)


# ─── Topic Button Factory ──────────────────────────────────────────────────────
func _make_topic_btn(label_text: String, idx: int) -> Button:
	var btn := Button.new()
	btn.text = label_text
	btn.add_theme_font_override("font", load(FONT_PATH))
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(func():
		_selected_topic_idx = idx
		_custom_input.text = ""
		_update_topic_button_styles()
	)
	return btn


func _update_topic_button_styles() -> void:
	for i in range(_topic_buttons.size()):
		var btn: Button = _topic_buttons[i]
		var is_sel := (i == _selected_topic_idx)
		var bg := BTN_SEL if is_sel else BTN_NORMAL
		btn.add_theme_stylebox_override("normal", _flat_sb(bg, 8))
		btn.add_theme_stylebox_override("hover", _flat_sb(BTN_HOVER, 8))
		btn.add_theme_stylebox_override("pressed", _flat_sb(BTN_SEL, 8))
		btn.add_theme_color_override("font_color", GOLD if is_sel else Color(1, 1, 1))


# ─── Submit ────────────────────────────────────────────────────────────────────
func _on_submit() -> void:
	var topic := _custom_input.text.strip_edges()
	if topic.is_empty() and _selected_topic_idx >= 0 and _selected_topic_idx < PREDEFINED_TOPICS.size():
		topic = PREDEFINED_TOPICS[_selected_topic_idx]
	if topic.is_empty():
		topic = "programming"

	Global.start_course(topic)
	queue_free()
	get_tree().change_scene_to_file("res://map/map.tscn")


# ─── Animations ───────────────────────────────────────────────────────────────
func _animate_open() -> void:
	_panel.scale = Vector2(0.6, 0.6)
	_panel.modulate.a = 0.0
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_panel, "scale", Vector2(1.0, 1.0), 0.35)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(_panel, "modulate:a", 1.0, 0.3)
	tw.tween_property(_overlay, "color:a", 0.55, 0.3)


func _animate_close() -> void:
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_panel, "scale", Vector2(0.6, 0.6), 0.25)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tw.tween_property(_panel, "modulate:a", 0.0, 0.2)
	tw.tween_property(_overlay, "color:a", 0.0, 0.2)
	tw.chain().tween_callback(queue_free)


# ─── Helpers ──────────────────────────────────────────────────────────────────
func _make_label(text: String, size: int, color: Color) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_override("font", load(FONT_PATH))
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return lbl


func _make_action_btn(label_text: String) -> Button:
	var btn := Button.new()
	btn.text = label_text
	btn.add_theme_font_override("font", load(FONT_PATH))
	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_color_override("font_color", Color(0.1, 0.05, 0.2))
	btn.add_theme_stylebox_override("normal", _flat_sb(GOLD, 10))
	btn.add_theme_stylebox_override("hover", _flat_sb(GOLD.lightened(0.15), 10))
	btn.add_theme_stylebox_override("pressed", _flat_sb(GOLD.darkened(0.15), 10))
	btn.focus_mode = Control.FOCUS_NONE
	return btn


func _flat_sb(color: Color, corner: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left     = corner
	sb.corner_radius_top_right    = corner
	sb.corner_radius_bottom_left  = corner
	sb.corner_radius_bottom_right = corner
	return sb
