extends Control


func _process(_delta):
	if Input.is_physical_key_pressed(KEY_ENTER):
		get_tree().change_scene_to_file("res://scenes/lobby.tscn")
