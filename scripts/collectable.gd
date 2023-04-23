class_name Collectable
extends Area2D

@export var value = 1

@rpc("call_local", "reliable")
func destroy():
	queue_free()
