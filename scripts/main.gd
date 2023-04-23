extends Node2D

@export var player_scene: PackedScene
@onready var players = $Players
@onready var markers = $Markers

func _ready():
	Game.players.sort()

	for i in Game.players.size():
		var id = Game.players[i]
		var player : Player = player_scene.instantiate()
		var marker = markers.get_child(i)
		
		player.name = str(id)
		player.global_position = marker.global_position
		players.add_child(player)
		player.init(id)
		
		
