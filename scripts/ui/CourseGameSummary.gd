# CourseGameSummary.gd
# Shown after each course round.  Displays:
#   - Current round: question, answer, explanation
#   - Previous rounds: compact history list
#   - Final screen (round 5): glitch animation + dark BG + total score
# Built entirely in code - no .tscn file required.

extends CanvasLayer
class_name CourseGameSummary

const FONT_PATH  := "res://Jersey10-Regular.ttf"
const LAYER_IDX  := 35   # above everything else

# Palette
const GOLD       := Color(1.0,  0.85, 0.30, 1.0)
const GOLD_DIM   := Color(0.85, 0.72, 0.25, 1.0)
const TEXT_WHITE := Color(1.0,  1.0,  1.0,  1.0)
const TEXT_DIM   := Color(0.75, 0.75, 0.82, 1.0)
const GREEN      := Color(0.35, 0.95, 0.55, 1.0)
const RED        := Color(1.0,  0.35, 0.35, 1.0)
const CARD_BG    := Color(0.12, 0.15, 0.32, 1.0)
const CARD_CUR   := Color(0.08, 0.18, 0.40, 1.0)
const PANEL_BG   := Color(0.05, 0.08, 0.22, 0.97)
const FINAL_BG   := Color(0.02, 0.02, 0.06, 0.97)

const PANEL_W    := 700.0
const PANEL_H    := 530.0

var _overlay: ColorRect
var _panel:   Panel
var _is_final: bool = false

# ==========================================================================
# Public API
# ==========================================================================

# Legacy shim - params no longer needed; data is read from Global.course_round_history
func setup(_concepts: Array = [], _facts: Array = []) -> void:
	pass

func open() -> void:
	await _build_ui()
	_animate_open()


# ==========================================================================
# Build UI
# ==========================================================================
func _build_ui() -> void:
	layer = LAYER_IDX

	# Dim overlay
	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)

	var history     := Global.course_round_history
	var games_done  := Global.course_current_game + 1
	_is_final       = (games_done >= Global.course_games_total)

	var current_entry: Dictionary = history[-1] if not history.is_empty() else {}
	var prev_entries: Array = history.slice(0, history.size() - 1) if history.size() > 1 else []

	var bg_col := FINAL_BG if _is_final else PANEL_BG
	_panel = _make_panel(bg_col, GOLD)
	_panel.custom_minimum_size = Vector2(PANEL_W, PANEL_H)
	_panel.size                = Vector2(PANEL_W, PANEL_H)
	_panel.pivot_offset        = Vector2(PANEL_W * 0.5, PANEL_H * 0.5)
	_panel.modulate.a          = 0.0
	add_child(_panel)

	await get_tree().process_frame
	var vp := get_viewport().get_visible_rect().size
	_panel.position = Vector2((vp.x - PANEL_W) * 0.5, (vp.y - PANEL_H) * 0.5)

	var y := 16.0

	# Header
	var header_text: String
	if _is_final:
		header_text = "🏆 Course Complete!"
	else:
		header_text = "Round %d of %d — What You Learned" % [games_done, Global.course_games_total]

	var header := _lbl(header_text, 30, GOLD)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.custom_minimum_size  = Vector2(PANEL_W - 40, 44)
	header.position             = Vector2(20, y)
	_panel.add_child(header)
	y += 50.0

	# Progress dots
	var dots_hbox := HBoxContainer.new()
	dots_hbox.add_theme_constant_override("separation", 10)
	dots_hbox.position = Vector2(20, y)
	for i in range(Global.course_games_total):
		var dot := _lbl("●" if i < games_done else "○", 22, GOLD if i < games_done else TEXT_DIM)
		dots_hbox.add_child(dot)
	_panel.add_child(dots_hbox)
	y += 34.0

	# Scrollable content
	var scroll_h := PANEL_H - y - 66.0
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size    = Vector2(PANEL_W - 40, scroll_h)
	scroll.size                   = Vector2(PANEL_W - 40, scroll_h)
	scroll.position               = Vector2(20, y)
	_panel.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	# Current round card
	if not current_entry.is_empty():
		var sec_lbl := _lbl("📋 This Round", 21, GOLD)
		vbox.add_child(sec_lbl)
		_add_round_card(vbox, current_entry, true)

	# Previous rounds
	if not prev_entries.is_empty():
		_add_separator(vbox)
		var hist_lbl := _lbl("🕓 Previous Rounds", 21, GOLD_DIM)
		vbox.add_child(hist_lbl)
		var reversed_prev := prev_entries.duplicate()
		reversed_prev.reverse()
		for entry in reversed_prev:
			_add_round_card(vbox, entry, false)

	# Final score label (will be glitched)
	var score_label_ref: Label = null
	if _is_final:
		_add_separator(vbox)
		var final_score := Global.course_total_score + Global.score
		var score_lbl := _lbl("🏅 Total Score: %d" % final_score, 34, GOLD)
		score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		score_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(score_lbl)
		score_label_ref = score_lbl

	# Action button
	y = PANEL_H - 60.0
	var action_btn := _make_action_btn(
		"🏠 Return to Home" if _is_final else "▶ Continue to Next Round"
	)
	action_btn.custom_minimum_size = Vector2(PANEL_W - 40, 48)
	action_btn.size                = Vector2(PANEL_W - 40, 48)
	action_btn.position            = Vector2(20, y)
	if _is_final:
		action_btn.pressed.connect(_go_home)
	else:
		action_btn.pressed.connect(_next_game)
	_panel.add_child(action_btn)

	# Trigger glitch animation for final screen after open animation settles
	if _is_final and score_label_ref != null:
		await get_tree().create_timer(0.55).timeout
		_animate_glitch(score_label_ref)


# ==========================================================================
# Navigation
# ==========================================================================
func _next_game() -> void:
	Global.course_advance()
	_animate_close_then(func():
		get_tree().change_scene_to_file("res://map/map.tscn")
	)

func _go_home() -> void:
	Global.course_advance()
	_animate_close_then(func():
		get_tree().change_scene_to_file("res://HomeScreen.tscn")
	)


# ==========================================================================
# Round Card
# ==========================================================================
func _add_round_card(vbox: VBoxContainer, entry: Dictionary, is_current: bool) -> void:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var card_sb := StyleBoxFlat.new()
	card_sb.bg_color = CARD_CUR if is_current else CARD_BG
	if is_current:
		card_sb.border_width_left   = 2
		card_sb.border_width_top    = 2
		card_sb.border_width_right  = 2
		card_sb.border_width_bottom = 2
		card_sb.border_color = GOLD
	card_sb.corner_radius_top_left     = 8
	card_sb.corner_radius_top_right    = 8
	card_sb.corner_radius_bottom_left  = 8
	card_sb.corner_radius_bottom_right = 8
	card_sb.content_margin_left   = 12
	card_sb.content_margin_top    = 8
	card_sb.content_margin_right  = 12
	card_sb.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", card_sb)
	vbox.add_child(card)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 4)
	card.add_child(inner)

	var round_num: int = entry.get("round", 0)
	var question: String = entry.get("question", "")
	var answer: String   = entry.get("answer", "")
	var explanation: String = entry.get("explanation", "")
	var won: bool        = entry.get("win", false)

	var fs_round := 18 if is_current else 16
	var round_lbl := _lbl("Round %d" % round_num, fs_round, GOLD if is_current else GOLD_DIM)
	inner.add_child(round_lbl)

	if not question.is_empty():
		var q_lbl := _lbl("❓ " + question, 17 if is_current else 15, TEXT_WHITE)
		q_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		q_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		inner.add_child(q_lbl)

	if not answer.is_empty():
		var icon  := "✅ " if won else "❌ "
		var label := "Answer: " if won else "Correct answer was: "
		var col   := GREEN if won else RED
		var a_lbl := _lbl(icon + label + answer.capitalize(), 17 if is_current else 15, col)
		a_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		a_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		inner.add_child(a_lbl)

	# Explanation shown only for the current round card
	if is_current and not explanation.is_empty():
		var e_lbl := _lbl("💡 " + explanation, 16, TEXT_DIM)
		e_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		e_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		inner.add_child(e_lbl)


# ==========================================================================
# Animations
# ==========================================================================
func _animate_open() -> void:
	var target_alpha := 0.88 if _is_final else 0.65
	_panel.scale = Vector2(0.7, 0.7)
	_panel.modulate.a = 0.0
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_panel, "scale", Vector2(1.0, 1.0), 0.40)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(_panel, "modulate:a", 1.0, 0.35)
	tw.tween_property(_overlay, "color:a", target_alpha, 0.35)


func _animate_close_then(callback: Callable) -> void:
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_panel, "scale", Vector2(0.7, 0.7), 0.25)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tw.tween_property(_panel, "modulate:a", 0.0, 0.20)
	tw.tween_property(_overlay, "color:a", 0.0, 0.20)
	tw.chain().tween_callback(callback)


# Glitch effect: rapid visibility flickers that resolve to steady-on.
func _animate_glitch(target: Control) -> void:
	var pattern := [false, true, false, false, true, false, true, false, false, true, false, true, false, true, true]
	var idx := 0
	var timer := Timer.new()
	timer.wait_time = 0.09
	timer.timeout.connect(func():
		if idx < pattern.size():
			target.visible = pattern[idx]
			idx += 1
		else:
			target.visible = true
			timer.stop()
			timer.queue_free()
	)
	add_child(timer)
	timer.start()


# ==========================================================================
# Helpers
# ==========================================================================
func _lbl(text: String, size: int, color: Color) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_override("font", load(FONT_PATH))
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	return lbl


func _make_panel(bg: Color, border: Color) -> Panel:
	var p := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.corner_radius_top_left     = 16
	sb.corner_radius_top_right    = 16
	sb.corner_radius_bottom_left  = 16
	sb.corner_radius_bottom_right = 16
	sb.border_width_left   = 2
	sb.border_width_top    = 2
	sb.border_width_right  = 2
	sb.border_width_bottom = 2
	sb.border_color = border
	p.add_theme_stylebox_override("panel", sb)
	return p


func _make_action_btn(label_text: String) -> Button:
	var btn := Button.new()
	btn.text = label_text
	btn.add_theme_font_override("font", load(FONT_PATH))
	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_color_override("font_color", Color(0.05, 0.05, 0.15))
	var sb := StyleBoxFlat.new()
	sb.bg_color = GOLD
	sb.corner_radius_top_left     = 10
	sb.corner_radius_top_right    = 10
	sb.corner_radius_bottom_left  = 10
	sb.corner_radius_bottom_right = 10
	var sb_h := StyleBoxFlat.new()
	sb_h.bg_color = GOLD.lightened(0.15)
	sb_h.corner_radius_top_left     = 10
	sb_h.corner_radius_top_right    = 10
	sb_h.corner_radius_bottom_left  = 10
	sb_h.corner_radius_bottom_right = 10
	btn.add_theme_stylebox_override("normal",  sb)
	btn.add_theme_stylebox_override("hover",   sb_h)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.focus_mode = Control.FOCUS_NONE
	return btn


func _add_separator(vbox: VBoxContainer) -> void:
	var sep := ColorRect.new()
	sep.color = Color(GOLD.r, GOLD.g, GOLD.b, 0.30)
	sep.custom_minimum_size = Vector2(0, 1)
	sep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(sep)
