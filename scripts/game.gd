extends Node

# [ {id, name, team, node} ]
var players: Array = []
var card_selector
var teamwinner = 0
func get_current_player():
	var id = multiplayer.get_unique_id()
	for player in players:
		if player.id == id:
			return player.node
