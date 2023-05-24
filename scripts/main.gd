extends Node2D

@export var player_scene: PackedScene
@onready var players = $Players
@onready var markers = $Markers
@onready var scores = $CanvasLayer/Scores
@onready var game_time = $GameTime
@onready var time_remaining_label = $CanvasLayer/TimeRemainingLabel

func _ready():
	Game.players.sort()

	for i in Game.players.size():
		var id = Game.players[i]
		var player : Player = player_scene.instantiate()
		var marker = markers.get_child(i)
		
		player.name = str(id)
		player.global_position = marker.global_position
		player.scale = Vector2(0.8,0.8)
		players.add_child(player)
		player.scores_updated.connect(on_scores_updated)
		player.init(id)
		
		Game.player_nodes[id] = player
		game_time.start()


func _process(delta):
	var time_remaining = int(game_time.time_left)
	var seconds = time_remaining%60
	var minutes = (time_remaining/60)%60
	time_remaining_label.text = "%02d:%02d" % [minutes, seconds]
	
	# 8 mins time
	if abs(game_time.time_left - 480) <= 0.005:
		print("mgta el fornai") 
	# 5 mins time
	if abs(game_time.time_left - 300) <= 0.005:
		print("no mgta el fornai")
	# 2:30 mins time
	if abs(game_time.time_left - 150) <= 0.005:
		print("no gasten plata en el genshin")

func on_scores_updated():
	scores.update_tables()


func _on_game_time_timeout():
	# TODO: Implement end of the game
	pass
