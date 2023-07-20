extends MarginContainer
@onready var label = $mensaje
@onready var label2 = $Label

func _ready():
	if Game.teamwinner != 0:
		var teamwinner = Game.teamwinner
		label.text = "TEAM %d" %teamwinner + " WINS"
		await get_tree().create_timer(5).timeout 
		get_tree().change_scene_to_file("res://scenes/Credits.tscn")
	else:
		label.text  = "DRAW"
		label2.text = ""
		await get_tree().create_timer(5).timeout 
		get_tree().change_scene_to_file("res://scenes/Credits.tscn")
	

