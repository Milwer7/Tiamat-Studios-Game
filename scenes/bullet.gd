extends Area2D

var SPEED = 310



func _ready():
	if is_multiplayer_authority():
		body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += SPEED * transform.x * delta
	
func _on_body_entered(body: Node):
	if body.is_in_group("Player"):
		body.on_hit.rpc()
	self.destroy.rpc()
	
@rpc("call_local", "reliable")
func destroy():
	queue_free()
