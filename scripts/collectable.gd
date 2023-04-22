class_name Collectable
extends Area2D


@export var value = 1
var players_in: Array = []

func _process(_delta) -> void:
	for body in players_in:
		if body.tried_to_pick and body.backpack_size < body.backpack_max_size:
			body.add_to_backpack.rpc(value)
			destroy.rpc()

@rpc("call_local", "reliable")
func destroy():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("Player"):
#		body.bla.connect(on_bla)
		players_in.append(body)
