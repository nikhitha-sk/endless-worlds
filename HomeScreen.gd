extends Control

@onready var score_label := $PlayerPanel/StatsVBox/ScoreLabel
@onready var high_score_label := $PlayerPanel/StatsVBox/HighScoreLabel
@onready var level_label := $PlayerPanel/StatsVBox/LevelLabel
@onready var start_button := $StartButton

func _ready():
	score_label.text = "⭐ Score: %d" % Global.score
	high_score_label.text = "🏆 High Score: %d" % Global.high_score
	level_label.text = "🧭 Level: %d" % Global.level

	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://map.tscn")
