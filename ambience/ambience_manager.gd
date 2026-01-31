extends Node

@export var ambience_folder := "res://assets/audio/ambience/"
@onready var ambience_player: AudioStreamPlayer = $"../AmbiencePlayer"

var ambience_files: Array[String] = []

func _ready():
	_load_ambience_files()
	_play_random_ambience()

func _load_ambience_files():
	ambience_files.clear()

	var dir := DirAccess.open(ambience_folder)
	if dir == null:
		push_error("Ambience folder not found: " + ambience_folder)
		return

	dir.list_dir_begin()
	while true:
		var file := dir.get_next()
		if file == "":
			break

		if not dir.current_is_dir() and (file.ends_with(".mp3") or file.ends_with(".ogg") or file.ends_with(".wav")):
			ambience_files.append(ambience_folder + file)

	dir.list_dir_end()

func _play_random_ambience():
	if ambience_files.is_empty():
		push_warning("No ambience files found.")
		return

	var chosen_path: String = ambience_files.pick_random()
	var stream: AudioStream = load(chosen_path)

	ambience_player.stream = stream
	ambience_player.volume_db = -10
	ambience_player.play()

	# ✅ ensure looping
	if ambience_player.stream is AudioStreamMP3:
		(ambience_player.stream as AudioStreamMP3).loop = true
	elif ambience_player.stream is AudioStreamOggVorbis:
		(ambience_player.stream as AudioStreamOggVorbis).loop = true
	elif ambience_player.stream is AudioStreamWAV:
		(ambience_player.stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
