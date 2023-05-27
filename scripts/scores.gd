extends VBoxContainer

var id_list = Game.players

func update_tables():
	var j = 0
	for player in Game.players: 
		var label = self.get_child(j+1)
		label.text = (player.name + " Points: " + str(player.node.points))
		j += 1
