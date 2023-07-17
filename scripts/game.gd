extends Node

# [ {id, name, team, node} ]
var players: Array = []

func get_current_player():
	var id = multiplayer.get_unique_id()
	for player in players:
		if player.id == id:
			return player.node
