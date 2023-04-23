extends Node2D

@export var player_scene: PackedScene
@onready var players = $Players
@onready var markers = $Markers
@onready var scores = $CanvasLayer/Scores

func _ready():
	Game.players.sort()

	for i in Game.players.size():
		var id = Game.players[i]
		var player : Player = player_scene.instantiate()
		var marker = markers.get_child(i)
		
		player.name = str(id)
		player.global_position = marker.global_position
		player.scale = Vector2(0.3,0.3)
		players.add_child(player)
		player.scores_updated.connect(on_scores_updated)
		player.init(id)
		
		Game.player_nodes[id] = player
		
func on_scores_updated():
	scores.update_tables()
