extends VBoxContainer

var id_list = Game.players

func update_tables():
	var players_size = id_list.size()
	var j = 0
	for i in id_list:
		var player = Game.player_nodes[i]
		var label = self.get_child(j+1)
		label.text = (Game.names[j] + " Points: " + str(player.points))
		j += 1
