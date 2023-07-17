extends Node

var actions = {
	"rapid_fire" : rapid_fire,
	"rapid_fire2" : rapid_fire2
}

func rapid_fire():
	var player = Game.get_current_player()
	player.shooting_wait_time = 0.2
	
func rapid_fire2():
	var player = Game.get_current_player()
	player.shooting_wait_time = 0.01
	
func get_action(action : String) -> Callable:
	return actions[action]
