extends Node

var actions = {
	"rapid_fire" : rapid_fire,
	"rapid_fire2" : rapid_fire2,
	"backpack_increase" : backpack_increase,
	"speed_increase" : speed_increase,
	"fire_bullet" : fire_bullet,
	"bullet_immunity": bullet_immunity,
	"respawn_faster": respawn_faster
}

func rapid_fire():
	var player = Game.get_current_player()
	player.shooting_wait_time = 0.35
	player.update_fire_rate.rpc(0.35)

func rapid_fire2():
	var player = Game.get_current_player()
	player.shooting_wait_time = 0.25
	player.update_fire_rate.rpc(0.25)

func backpack_increase():
	var player = Game.get_current_player()
	player.backpack_max_size += 5

func speed_increase():
	var player = Game.get_current_player()
	player.speed = 150
	player.update_speed.rpc(150)
	
func fire_bullet():
	var player = Game.get_current_player()
	player.player_damage = 3
	player.update_damage.rpc(3)

func bullet_immunity():
	var player = Game.get_current_player()
	player.bullet_immunity()

func respawn_faster():
	var player = Game.get_current_player()
	player.update_respawn_time.rpc(5)

func get_action(action : String) -> Callable:
	return actions[action]
