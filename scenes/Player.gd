extends CharacterBody2D


@export var speed = 300
@export var acceleration = 4000

func move_character(delta):
	# Moves the character based on the input on both axis
	var move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	velocity.x = move_toward(velocity.x, move_input.x * speed, acceleration * delta)
	velocity.y = move_toward(velocity.y, move_input.y * speed, acceleration * delta)
	move_and_slide()

func _physics_process(delta):
	move_character(delta) # Moving the character
