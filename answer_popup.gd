extends CanvasLayer
class_name AnswerPopup

@onready var wordle_grid := $Panel/VBoxContainer/FillContainer/WordleGrid

var max_attempts := 5
var current_row := 0
var current_col := 0
var boxes := []


@onready var message: Label = $Panel/VBoxContainer/MessageLabel
@onready var submit: Button = $Panel/VBoxContainer/SubmitButton
@onready var close_button: Button = $Panel/CloseButton

@onready var victory_sound: AudioStreamPlayer = $VictorySound
@onready var gameover_sound: AudioStreamPlayer = $GameOverSound


# EXISTING OPTION BUTTONS (NO DYNAMIC CREATION)
@onready var option_buttons: Array[Button] = [
	$Panel/VBoxContainer/OptionsContainer/OptionA,
	$Panel/VBoxContainer/OptionsContainer/OptionB,
	$Panel/VBoxContainer/OptionsContainer/OptionC,
	$Panel/VBoxContainer/OptionsContainer/OptionD
]

@onready var fill_container: VBoxContainer = $Panel/VBoxContainer/FillContainer
@onready var answer_input: LineEdit = $Panel/VBoxContainer/FillContainer/AnswerInput


var correct_answer := ""
var selected_answer := ""
var popup_type: Global.QuestionType
var hearts: HeartSystem
var map_ref

func _hide_all_popups():
	# Hide MCQ
	for btn in option_buttons:
		btn.visible = false

	# Hide fill in blank
	fill_container.visible = false
	answer_input.text = ""


# =============================
func _ready():
	visible = false
	submit.pressed.connect(_on_submit)
	close_button.pressed.connect(close)

# =============================
# OPEN POPUP WITH MCQs
# =============================
func open(solution: String, options: Array, heart_system: HeartSystem, map):
	if solution.is_empty():
		push_error("❌ Empty correct answer")
		return

	visible = true
	hearts = heart_system
	map_ref = map
	correct_answer = solution.to_lower()
	selected_answer = ""

	_hide_all_popups()

	# RANDOM POPUP TYPE
	
	popup_type = Global.current_question_type


	match Global.current_question_type:
		Global.QuestionType.MCQ:
			_open_mcq(options)
		Global.QuestionType.FILL_BLANK:
			_open_fill_blank()
		Global.QuestionType.WORDLE:
			_open_wordle()

func _build_wordle_grid():
	boxes.clear()
	current_row = 0
	current_col = 0

	for row in wordle_grid.get_children():
		row.queue_free()

	for r in range(max_attempts):
		var row := HBoxContainer.new()
		wordle_grid.add_child(row)

		var row_boxes := []
		for i in correct_answer.length():
			var lbl := Label.new()
			lbl.text = ""
			lbl.custom_minimum_size = Vector2(50, 50)
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.add_theme_color_override("font_color", Color.WHITE)
			lbl.add_theme_color_override("background_color", Color.DIM_GRAY)
			row.add_child(lbl)
			row_boxes.append(lbl)

		boxes.append(row_boxes)


func _open_mcq(options: Array):
	message.text = "Choose the correct answer"

	# RESET & FILL EXISTING BUTTONS
	for i in option_buttons.size():
		var btn := option_buttons[i]

		btn.modulate = Color.WHITE
		btn.disabled = false
		btn.visible = false

		# Disconnect old signals safely
		for c in btn.pressed.get_connections():
			btn.pressed.disconnect(c.callable)

		if i < options.size():
			btn.text = options[i]
			btn.visible = true
			btn.pressed.connect(_on_option_selected.bind(btn, options[i]))

func _open_fill_blank():
	message.text = "Fill in the correct answer"
	fill_container.visible = true
	answer_input.grab_focus()


# =============================
# OPTION SELECT
# =============================
func _on_option_selected(btn: Button, option_text: String):
	selected_answer = option_text.to_lower()

	# Reset all buttons
	for b in option_buttons:
		b.modulate = Color.WHITE

	# Highlight selected
	btn.modulate = Color(0.6, 1.0, 0.6)

# =============================
# SUBMIT ANSWER
# =============================
func _on_submit():
	var user_answer := ""

	match popup_type:
		Global.QuestionType.MCQ:
			user_answer = selected_answer
		Global.QuestionType.FILL_BLANK:
			user_answer = answer_input.text.strip_edges().to_lower()

	if user_answer == "":
		message.text = "⚠ Answer required"
		return

	if user_answer == correct_answer:
	
	
		$"../DifficultyRL".give_feedback(true, Global.current_hint_count)
		Global.end_game(true)

		spawn_confetti()
		message.text = "🎉 VICTORY!"
		victory_sound.play()


		Global.add_score(30)
		Global.next_level()

		await get_tree().create_timer(1.5).timeout
		close()
		get_tree().change_scene_to_file("res://HomeScreen.tscn")
	else:
		$"../DifficultyRL".give_feedback(false, Global.current_hint_count)
		message.text = "❌ Wrong Answer"
		gameover_sound.play()

		Global.add_score(-10)
		hearts.damage(2)
		await get_tree().create_timer(1.0).timeout
		close()

# =============================
func close():
	_hide_all_popups()
	visible = false
	selected_answer = ""
	message.text = ""

	for btn in option_buttons:
		btn.modulate = Color.WHITE
		btn.disabled = false

# =============================
# CONFETTI (UNCHANGED)
# =============================
func spawn_confetti():
	var viewport_size := get_viewport().get_visible_rect().size

	var colors := [
		Color.RED,
		Color.YELLOW,
		Color.GREEN,
		Color.CYAN,
		Color.MAGENTA,
		Color.ORANGE
	]

	var shapes := ["circle", "square", "rectangle", "triangle", "parallelogram"]

	for c in colors:
		var particles := CPUParticles2D.new()
		add_child(particles)

		particles.position = viewport_size * 0.5 + Vector2(0, -200)
		particles.amount = 80
		particles.explosiveness = 1.0
		particles.lifetime = 2.0
		particles.one_shot = true
		particles.direction = Vector2(0, -1)
		particles.spread = 180
		particles.gravity = Vector2(0, 1200)
		particles.initial_velocity_min = 400
		particles.initial_velocity_max = 900
		particles.angular_velocity_min = 100
		particles.angular_velocity_max = 400
		particles.scale_amount_min = 0.6
		particles.scale_amount_max = 1.2
		particles.modulate = c

		var shape: Variant = shapes.pick_random()
		particles.texture = _make_shape_texture(shape, 16)

		particles.emitting = true
		get_tree().create_timer(3.0).timeout.connect(particles.queue_free)

func _make_shape_texture(shape: String, size := 16) -> Texture2D:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	var c := Color.WHITE

	match shape:
		"circle":
			for x in size:
				for y in size:
					if Vector2(x, y).distance_to(Vector2(size / 2.0, size / 2.0)) <= size / 2.0:
						img.set_pixel(x, y, c)
		"square":
			img.fill(c)
		"rectangle":
			for x in size:
				for y in int(size * 0.6):
					img.set_pixel(x, y + int(size * 0.2), c)
		"triangle":
			for y in size:
				for x in int((y / float(size)) * size):
					img.set_pixel(x + (size - x) / 2, y, c)
		"parallelogram":
			for y in size:
				for x in int(size * 0.7):
					img.set_pixel(x + int(y * 0.2), y, c)

	return ImageTexture.create_from_image(img)

func _open_wordle():
	message.text = "Guess the word"
	fill_container.visible = true
	answer_input.visible = false
	_build_wordle_grid()

func _unhandled_input(event):
	if not visible or Global.current_question_type != Global.QuestionType.WORDLE:
		return
	if current_row >= max_attempts:
		return  # ⛔ stop input after last attempt

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BACKSPACE and current_col > 0:
			current_col -= 1
			boxes[current_row][current_col].text = ""

		elif event.keycode == KEY_ENTER:
			if current_col == correct_answer.length():
				_evaluate_word()

		elif event.unicode >= 65 and event.unicode <= 122:
			if current_col < correct_answer.length():
				boxes[current_row][current_col].text = char(event.unicode).to_upper()
				current_col += 1
				
func _evaluate_word():
	var guess := ""
	for b in boxes[current_row]:
		guess += b.text.to_lower()

	# Logic for coloring boxes
	for i in guess.length():
		var box = boxes[current_row][i]
		var c = guess[i]

		if not correct_answer.contains(c):
			box.modulate = Color.GRAY
		elif correct_answer[i] == c:
			box.modulate = Color.GREEN
		else:
			box.modulate = Color.YELLOW

	# Check for Win
	if guess == correct_answer:
		_wordle_victory()
		return
	else:
		Global.add_score(-5)
		hearts.damage(1)
		

	# Move to next row
	current_row += 1
	current_col = 0

	# Check for Loss (No attempts left)
	if current_row >= max_attempts:
		_wordle_defeat()
		
func _wordle_defeat():
	message.text = "❌ Out of attempts!"
	gameover_sound.play()

	
	# Optional: Give feedback to your RL system if applicable
	if has_node("../DifficultyRL"):
		get_node("../DifficultyRL").give_feedback(false, Global.current_hint_count)

	# Wait a moment so the player can see their last row, then close
	await get_tree().create_timer(1.5).timeout
	close()
		
func _wordle_victory():
	spawn_confetti()
	victory_sound.play()
	message.text = "🎉 VICTORY!"

	Global.end_game(true)
	Global.add_score(30)
	Global.next_level()

	await get_tree().create_timer(1.5).timeout
	close()
	get_tree().change_scene_to_file("res://HomeScreen.tscn")
