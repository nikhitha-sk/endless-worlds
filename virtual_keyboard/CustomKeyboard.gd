extends PanelContainer
class_name CustomKeyboard

signal key_pressed(character: String)
signal backspace_pressed
signal enter_pressed

@onready var main_vbox = VBoxContainer.new()
# Update this path if you move the file within your Godot project res:// folder
const FONT_PATH = "res://Jersey10-Regular.ttf" 

const ALPHA_ROWS = [
	["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
	["A", "S", "D", "F", "G", "H", "J", "K", "L"],
	["SHIFT", "Z", "X", "C", "V", "B", "N", "M", "BKSP"],
	["SPACE", "ENTER"]
]

func _ready():
	# Tray Background
	var tray_style = StyleBoxFlat.new()
	tray_style.bg_color = Color(0, 0, 0, 0.2)
	add_theme_stylebox_override("panel", tray_style)
	
	main_vbox.add_theme_constant_override("separation", 3)
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(main_vbox)
	
	_build_number_row()
	_build_alpha_rows()

func _build_number_row():
	var num_grid = GridContainer.new()
	num_grid.columns = 10
	num_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	num_grid.add_theme_constant_override("h_separation", 3)
	main_vbox.add_child(num_grid)
	
	for n in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]:
		num_grid.add_child(_create_key_button(n))

func _build_alpha_rows():
	for row_data in ALPHA_ROWS:
		var row_hbox = HBoxContainer.new()
		row_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_hbox.add_theme_constant_override("separation", 3)
		main_vbox.add_child(row_hbox)
		
		for key_text in row_data:
			var btn = _create_key_button(key_text)
			if key_text in ["SPACE", "ENTER", "SHIFT", "BKSP"]:
				btn.size_flags_stretch_ratio = 1.5
			row_hbox.add_child(btn)

func _create_key_button(txt: String) -> Button:
	var btn = Button.new()
	btn.text = txt
	
	# --- DISABLE WASD/ARROW NAVIGATION ---
	btn.focus_mode = Control.FOCUS_NONE
	
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size.y = 40
	
	# Font Setup
	if FileAccess.file_exists(FONT_PATH):
		var dynamic_font = load(FONT_PATH)
		btn.add_theme_font_override("font", dynamic_font)
	
	# Translucent Style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.15)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.border_width_bottom = 2
	style.border_color = Color(1, 1, 1, 0.05)
	
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style) # Keep same look on hover
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_font_size_override("font_size", 20)
	
	btn.pressed.connect(_on_key_down.bind(txt))
	return btn

func _on_key_down(key: String):
	match key:
		"BKSP": backspace_pressed.emit()
		"ENTER": enter_pressed.emit()
		"SPACE": key_pressed.emit(" ")
		_: key_pressed.emit(key)
