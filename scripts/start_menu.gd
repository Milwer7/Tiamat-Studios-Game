extends Control

func _ready():
	MusicaFondo.pause_game_music()

func _process(_delta):
	if Input.is_physical_key_pressed(KEY_ENTER):
		get_tree().change_scene_to_file("res://scenes/lobby.tscn")
	if Input.is_physical_key_pressed(KEY_TAB):
		get_tree().change_scene_to_file("res://scenes/Credits.tscn")
