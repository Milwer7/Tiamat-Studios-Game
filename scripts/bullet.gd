extends Area2D

var SPEED = 400
var shooter_team
var bullet_damage = 1

func _ready():
	var player = Game.get_current_player()
	bullet_damage = player.player_damage
	#print("position incial = " , position)
	if is_multiplayer_authority():
		body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += SPEED * transform.x * delta 


func _on_body_entered(body: Node):
	if body.is_in_group("Player"):
		body.on_hit.rpc(shooter_team, bullet_damage)
	self.destroy.rpc()
	
@rpc("call_local", "reliable")
func destroy():
	queue_free()
