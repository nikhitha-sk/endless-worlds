# CourseGameSummary.gd
# Shown between course games and after the final game.
# Displays the concepts and facts learned in the just-completed game.
# Built entirely in code — no .tscn file required.

extends CanvasLayer
class_name CourseGameSummary

const FONT_PATH := "res://Jersey10-Regular.ttf"
const LAYER_IDX := 35   # above everything else

const BG_COLOR    := Color(0.05, 0.08, 0.22, 0.97)
const GOLD        := Color(1.0, 0.85, 0.3, 1.0)
const ACCENT      := Color(0.72, 0.40, 0.10, 1.0)
const TEXT_WHITE  := Color(1.0, 1.0, 1.0, 1.0)
const TEXT_DIM    := Color(0.80, 0.80, 0.85, 1.0)
const CARD_BG     := Color(0.12, 0.15, 0.35, 1.0)

const PANEL_W := 680.0
const PANEL_H := 500.0

var _overlay: ColorRect
var _panel: Panel
var _is_final: bool = false   # true when all course games are finished
var _concepts: Array = []
var _facts: Array = []

# ─── Public API ───────────────────────────────────────────────────────────────

# Call this right before adding the node to the tree and BEFORE course_advance().
# Pass the concepts and facts arrays from the just-completed game.
func setup(concepts: Array, facts: Array) -> void:
	_concepts = concepts
	_facts = facts


func open() -> void:
	await _build_ui()
	_animate_open()


# ─── Build UI ─────────────────────────────────────────────────────────────────
func _build_ui() -> void:
	layer = LAYER_IDX

	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)

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
	sb.border_color = GOLD
	_panel.add_theme_stylebox_override("panel", sb)
	_panel.custom_minimum_size = Vector2(PANEL_W, PANEL_H)
	_panel.size = Vector2(PANEL_W, PANEL_H)
	_panel.pivot_offset = Vector2(PANEL_W * 0.5, PANEL_H * 0.5)
	_panel.modulate.a = 0.0
	add_child(_panel)

	await get_tree().process_frame
	var vp := get_viewport().get_visible_rect().size
	_panel.position = Vector2((vp.x - PANEL_W) * 0.5, (vp.y - PANEL_H) * 0.5)

	# ── determine whether this is the last game ──────────────────────────────
	# course_advance() has NOT been called yet at this point; current_game is
	# still the index of the game just finished (0-based).
	var games_done := Global.course_current_game + 1
	_is_final = (games_done >= Global.course_games_total)

	var y := 18.0

	# Header
	var header_text: String
	if _is_final:
		header_text = "🏆 Course Complete!"
	else:
		header_text = "Game %d of %d — What You Learned" % [games_done, Global.course_games_total]

	var header := _label(header_text, 30, GOLD)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.custom_minimum_size = Vector2(PANEL_W - 40, 44)
	header.position = Vector2(20, y)
	_panel.add_child(header)
	y += 50.0

	# Progress dots
	var dots_hbox := HBoxContainer.new()
	dots_hbox.add_theme_constant_override("separation", 8)
	dots_hbox.position = Vector2(20, y)
	dots_hbox.custom_minimum_size = Vector2(PANEL_W - 40, 20)
	for i in range(Global.course_games_total):
		var dot := Label.new()
		dot.text = "●" if i < games_done else "○"
		dot.add_theme_font_size_override("font_size", 20)
		dot.add_theme_color_override("font_color", GOLD if i < games_done else TEXT_DIM)
		dots_hbox.add_child(dot)
	_panel.add_child(dots_hbox)
	y += 32.0

	# Scrollable content area
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(PANEL_W - 40, PANEL_H - y - 72.0)
	scroll.size = Vector2(PANEL_W - 40, PANEL_H - y - 72.0)
	scroll.position = Vector2(20, y)
	_panel.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	# ── Concepts section ─────────────────────────────────────────────────────
	if not _concepts.is_empty():
		var sec_lbl := _label("💡 Concepts Learned", 22, GOLD)
		vbox.add_child(sec_lbl)
		for entry in _concepts:
			var name_str: String = entry.get("name", "")
			var def_str: String  = entry.get("definition", name_str)
			_add_card(vbox, "💡 " + name_str, def_str)
	else:
		var empty_c := _label("No concepts were captured this game.", 18, TEXT_DIM)
		vbox.add_child(empty_c)

	# ── Facts section ────────────────────────────────────────────────────────
	var sep := ColorRect.new()
	sep.color = Color(GOLD.r, GOLD.g, GOLD.b, 0.35)
	sep.custom_minimum_size = Vector2(0, 1)
	sep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(sep)

	if not _facts.is_empty():
		var facts_lbl := _label("✨ Fun Facts Shared", 22, GOLD)
		vbox.add_child(facts_lbl)
		for entry in _facts:
			var fact_text: String = entry.get("text", "")
			_add_card(vbox, "✨", fact_text)
	else:
		var empty_f := _label("No fun facts were shared this game.", 18, TEXT_DIM)
		vbox.add_child(empty_f)

	# ── Final score (only on last game) ──────────────────────────────────────
	if _is_final:
		var score_sep := ColorRect.new()
		score_sep.color = Color(GOLD.r, GOLD.g, GOLD.b, 0.35)
		score_sep.custom_minimum_size = Vector2(0, 1)
		score_sep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(score_sep)

		# Total score = accumulated previous games + current game score
		var final_score := Global.course_total_score + Global.score
		var score_lbl := _label("🏅 Final Score: %d" % final_score, 28, GOLD)
		score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		score_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(score_lbl)

	y = PANEL_H - 60.0

	# ── Action button ─────────────────────────────────────────────────────────
	var action_btn := Button.new()
	action_btn.add_theme_font_override("font", load(FONT_PATH))
	action_btn.add_theme_font_size_override("font_size", 24)
	action_btn.add_theme_color_override("font_color", Color(0.05, 0.05, 0.15))
	var btn_sb := StyleBoxFlat.new()
	btn_sb.bg_color = GOLD
	btn_sb.corner_radius_top_left     = 10
	btn_sb.corner_radius_top_right    = 10
	btn_sb.corner_radius_bottom_left  = 10
	btn_sb.corner_radius_bottom_right = 10
	var btn_hover_sb := StyleBoxFlat.new()
	btn_hover_sb.bg_color = GOLD.lightened(0.15)
	btn_hover_sb.corner_radius_top_left     = 10
	btn_hover_sb.corner_radius_top_right    = 10
	btn_hover_sb.corner_radius_bottom_left  = 10
	btn_hover_sb.corner_radius_bottom_right = 10
	action_btn.add_theme_stylebox_override("normal", btn_sb)
	action_btn.add_theme_stylebox_override("hover", btn_hover_sb)
	action_btn.add_theme_stylebox_override("pressed", btn_sb)
	action_btn.focus_mode = Control.FOCUS_NONE
	action_btn.custom_minimum_size = Vector2(PANEL_W - 40, 46)
	action_btn.size = Vector2(PANEL_W - 40, 46)
	action_btn.position = Vector2(20, y)

	if _is_final:
		action_btn.text = "🏠 Return to Home"
		action_btn.pressed.connect(_go_home)
	else:
		action_btn.text = "▶ Continue to Next Game"
		action_btn.pressed.connect(_next_game)

	_panel.add_child(action_btn)


# ─── Navigation ───────────────────────────────────────────────────────────────
func _next_game() -> void:
	Global.course_advance()
	_animate_close_then(func():
		get_tree().change_scene_to_file("res://map/map.tscn")
	)


func _go_home() -> void:
	Global.course_advance()   # Finalises stats even for the last game
	_animate_close_then(func():
		get_tree().change_scene_to_file("res://HomeScreen.tscn")
	)


# ─── Entry Card ───────────────────────────────────────────────────────────────
func _add_card(vbox: VBoxContainer, heading: String, body: String) -> void:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var card_sb := StyleBoxFlat.new()
	card_sb.bg_color = CARD_BG
	card_sb.corner_radius_top_left     = 8
	card_sb.corner_radius_top_right    = 8
	card_sb.corner_radius_bottom_left  = 8
	card_sb.corner_radius_bottom_right = 8
	card_sb.content_margin_left   = 10
	card_sb.content_margin_top    = 6
	card_sb.content_margin_right  = 10
	card_sb.content_margin_bottom = 6
	card.add_theme_stylebox_override("panel", card_sb)
	vbox.add_child(card)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 4)
	card.add_child(inner)

	var h := _label(heading, 19, GOLD)
	h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_child(h)

	if not body.is_empty() and body != heading:
		var b := _label(body, 16, TEXT_WHITE)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		inner.add_child(b)


# ─── Animations ───────────────────────────────────────────────────────────────
func _animate_open() -> void:
	_panel.scale = Vector2(0.7, 0.7)
	_panel.modulate.a = 0.0
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_panel, "scale", Vector2(1.0, 1.0), 0.4)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(_panel, "modulate:a", 1.0, 0.35)
	tw.tween_property(_overlay, "color:a", 0.65, 0.35)


func _animate_close_then(callback: Callable) -> void:
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_panel, "scale", Vector2(0.7, 0.7), 0.25)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tw.tween_property(_panel, "modulate:a", 0.0, 0.20)
	tw.tween_property(_overlay, "color:a", 0.0, 0.20)
	tw.chain().tween_callback(callback)


# ─── Helpers ──────────────────────────────────────────────────────────────────
func _label(text: String, size: int, color: Color) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_override("font", load(FONT_PATH))
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	return lbl
