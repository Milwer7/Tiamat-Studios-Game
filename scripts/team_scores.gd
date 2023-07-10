extends VBoxContainer

var id_list = Game.players

func update_tables():
	var j = 0
	var label_team1 = $Team1
	var label_team2 = $Team2
	var puntos_team1 = 0
	var puntos_team2 = 0
	for player in Game.players:
		if player.team == 1:
			puntos_team1 += player.node.points
		else:
			puntos_team2 += player.node.points 
		#var label = self.get_child(j)
		#label.text = (player.name + " Points: " + str(player.node.points))
		j += 1
		#puntos_team1 += 1
		#puntos_team2 += 1
		label_team1.text = ("Team 1 Points = " + str(puntos_team1))
		label_team2.text = ("Team 2 Points = " + str(puntos_team2))
	
