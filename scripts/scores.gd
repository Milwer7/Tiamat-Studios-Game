extends VBoxContainer

var id_list = Game.players

func update_tables():
	var j = 0
	var _label_team1 = $Player5Points5
	var _label_team2 = $Player5Points6
	var _puntos_team1 = 0
	var _puntos_team2 = 0
	for player in Game.players:
		if player.team == 1:
			_puntos_team1 += player.node.points
			
		else:
			_puntos_team2 += player.node.points 
		var label = self.get_child(j)
		label.text = (player.name + " Points: " + str(player.node.points))
		j += 1
	Game.teamwinner = 1 if _puntos_team1 > _puntos_team2 else 2	
	
