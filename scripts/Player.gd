class_name Player
extends CharacterBody2D


@export var speed = 300
@export var acceleration = 4000

var move_input = 0

func init(id):
	set_multiplayer_authority(id)
	name = str(id)

func move_character(delta) -> void:
	if is_multiplayer_authority():
		# Moves the character based on the input on both axis
		move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")

		velocity.x = move_toward(velocity.x, move_input.x * speed, acceleration * delta)
		velocity.y = move_toward(velocity.y, move_input.y * speed, acceleration * delta)
		move_and_slide()
		
		rpc("send_data")

func _physics_process(delta) -> void:
	move_character(delta) # Moving the character

@rpc("unreliable_ordered")
func send_data(pos: Vector2, vel: Vector2, mi: float) -> void:
	global_position = lerp(global_position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)
	move_input = mi
