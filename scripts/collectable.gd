class_name Collectable
extends Area2D
@onready var collectable = $"."

@export var value = 1
@onready var sprite_2d = $Sprite2D
@onready var sprite_2d_2 = $Sprite2D2
@onready var sprite_2d_3 = $Sprite2D3

func _ready():
	actualizar_sprite()
	
func actualizar_sprite():
	if value == 1:
		sprite_2d.show()
	elif value == 5:
		sprite_2d_2.show()
	else:
		sprite_2d_3.show()
		
@rpc("call_local", "reliable", "any_peer")
func destroy():
	collectable.hide()
	monitorable = false
	await get_tree().create_timer(8).timeout
	collectable.show()
	monitorable = true
