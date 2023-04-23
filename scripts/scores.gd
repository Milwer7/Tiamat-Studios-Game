extends VBoxContainer

var id_list = Game.players

func update_tables():
	var players_size = id_list.size()
	var j = 0
	for i in id_list:
		var player = "player i?"
		var label = self.get_child(j)
		label.text = player.points
		j += 1
