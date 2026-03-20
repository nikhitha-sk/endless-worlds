extends CanvasLayer
class_name AgenticBot

# ============================================================
# AgenticBot – a 5×5 spritesheet bot displayed at the bottom-right
# of the screen. When a hint bulb is collected it "speaks" the hint
# text inside a speech cloud using a smooth typewriter animation.
# ============================================================

const COLS        := 5
const ROWS        := 5
const BOT_SCALE   := Vector2(0.6, 0.6)   # display size
const MARGIN      := Vector2(14, 14)      # padding from screen edges
const BUBBLE_W    := 220.0
const BUBBLE_H    := 110.0
const CHAR_DELAY  := 0.045               # seconds per character
const DONE_WAIT   := 5.0                 # seconds bubble stays after typing
const FONT_PATH   := "res://Jersey10-Regular.ttf"

enum _State { IDLE, SPEAKING, DONE }

# ---- nodes ----
var _bot: AnimatedSprite2D
var _bubble: Panel
var _label: Label

# ---- state ----
var _state: _State = _State.IDLE
var _full_text := ""
var _chars_shown := 0
var _elapsed := 0.0
var _done_timer := 0.0
var _frame_w := 0.0
var _frame_h := 0.0


# ==============================================================
func _ready() -> void:
	layer = 20   # above all game UI

	var bot_tex: Texture2D = load("res://assets/agentic_bot.png")
	# Use float division for accurate per-frame boundaries
	var fw := bot_tex.get_width()  / float(COLS)
	var fh := bot_tex.get_height() / float(ROWS)
	_frame_w = fw
	_frame_h = fh

	_build_sprite(bot_tex, fw, fh)
	_build_bubble()

	# position once viewport is ready
	await get_tree().process_frame
	_layout()


# ==============================================================
# Public API – call this to make the bot say something
# ==============================================================
func speak(text: String) -> void:
	_full_text   = text
	_chars_shown = 0
	_elapsed     = 0.0
	_done_timer  = 0.0
	_state       = _State.SPEAKING

	_label.text       = ""
	_bubble.modulate.a = 0.0
	_bubble.visible   = true

	var tw := create_tween()
	tw.tween_property(_bubble, "modulate:a", 1.0, 0.3)

	if _bot.sprite_frames.has_animation("speak"):
		_bot.play("speak")


# ==============================================================
func _process(delta: float) -> void:
	match _state:
		_State.SPEAKING:
			_elapsed += delta
			var target := int(_elapsed / CHAR_DELAY)
			target = min(target, _full_text.length())
			if target != _chars_shown:
				_chars_shown = target
				_label.text  = _full_text.substr(0, _chars_shown)
			if _chars_shown >= _full_text.length():
				_state = _State.DONE
				if _bot.sprite_frames.has_animation("idle"):
					_bot.play("idle")

		_State.DONE:
			_done_timer += delta
			if _done_timer >= DONE_WAIT:
				_hide_bubble()


# ==============================================================
# Internals
# ==============================================================
func _hide_bubble() -> void:
	_state = _State.IDLE
	var tw := create_tween()
	tw.tween_property(_bubble, "modulate:a", 0.0, 0.4)
	tw.tween_callback(func(): _bubble.visible = false)


func _layout() -> void:
	var vp := get_viewport().get_visible_rect().size
	var bw := _frame_w * BOT_SCALE.x
	var bh := _frame_h * BOT_SCALE.y

	# Bot sits in the bottom-right corner
	_bot.position = Vector2(
		vp.x - MARGIN.x - bw * 0.5,
		vp.y - MARGIN.y - bh * 0.5
	)

	# Bubble is above and to the left of the bot
	_bubble.size     = Vector2(BUBBLE_W, BUBBLE_H)
	_bubble.position = Vector2(
		_bot.position.x - BUBBLE_W + bw * 0.5,
		_bot.position.y - bh * 0.5 - BUBBLE_H - 8
	)


func _build_sprite(bot_tex: Texture2D, fw: float, fh: float) -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")

	# Row 0 → "idle"
	frames.add_animation("idle")
	frames.set_animation_speed("idle", 5.0)
	frames.set_animation_loop("idle", true)
	for col in range(COLS):
		var at := AtlasTexture.new()
		at.atlas  = bot_tex
		at.region = Rect2(col * fw, 0, fw, fh)
		frames.add_frame("idle", at)

	# Row 1 → "speak"
	frames.add_animation("speak")
	frames.set_animation_speed("speak", 9.0)
	frames.set_animation_loop("speak", true)
	for col in range(COLS):
		var at := AtlasTexture.new()
		at.atlas  = bot_tex
		at.region = Rect2(col * fw, fh, fw, fh)
		frames.add_frame("speak", at)

	# Row 2 → "wave" (played once when hint is first collected, then returns)
	frames.add_animation("wave")
	frames.set_animation_speed("wave", 7.0)
	frames.set_animation_loop("wave", false)
	for col in range(COLS):
		var at := AtlasTexture.new()
		at.atlas  = bot_tex
		at.region = Rect2(col * fw, 2 * fh, fw, fh)
		frames.add_frame("wave", at)

	_bot = AnimatedSprite2D.new()
	_bot.sprite_frames = frames
	_bot.scale         = BOT_SCALE
	_bot.play("idle")
	_bot.animation_finished.connect(_on_animation_finished)
	add_child(_bot)


func _build_bubble() -> void:
	# Panel styling – white speech cloud
	var style := StyleBoxFlat.new()
	style.bg_color                   = Color(1.0, 1.0, 1.0, 0.93)
	style.corner_radius_top_left     = 12
	style.corner_radius_top_right    = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left  = 4
	style.border_width_left          = 2
	style.border_width_top           = 2
	style.border_width_right         = 2
	style.border_width_bottom        = 2
	style.border_color               = Color(0.35, 0.45, 0.9, 1.0)

	_bubble = Panel.new()
	_bubble.add_theme_stylebox_override("panel", style)
	_bubble.visible   = false
	_bubble.modulate.a = 0.0
	add_child(_bubble)

	_label = Label.new()
	_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_label.offset_left   = 10
	_label.offset_top    = 10
	_label.offset_right  = -10
	_label.offset_bottom = -10
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_override("font", load(FONT_PATH))
	_label.add_theme_font_size_override("font_size", 17)
	_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.35))
	_bubble.add_child(_label)


func _on_animation_finished() -> void:
	# "wave" is a one-shot – return to the right looping anim
	if _bot.animation == "wave":
		if _state == _State.SPEAKING:
			_bot.play("speak")
		else:
			_bot.play("idle")
