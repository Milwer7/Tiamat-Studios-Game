class_name Player
extends CharacterBody2D


@export var speed = 300
@export var acceleration = 4000
@export var backpack_max_size = 10
@export var backpack_size = 0
@export var points = 0
@onready var label = $Label

var tried_to_pick = false
var on_pickable_area = false
var move_input = 0
var collectables : Array = []


signal bla(a, b)

func init(id):
	set_multiplayer_authority(id)
	name = str(id)
	

func move_character(delta) -> void:
		# Moves the character based on the input on both axis
		move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")

		velocity.x = move_toward(velocity.x, move_input.x * speed, acceleration * delta)
		velocity.y = move_toward(velocity.y, move_input.y * speed, acceleration * delta)
		move_and_slide()
		
		rpc("send_data", global_position, velocity, move_input)

func _physics_process(delta) -> void:
	if is_multiplayer_authority():
		move_character(delta) # Moving the character
		
		if Input.is_action_just_pressed("pick"):
			bla.emit(1, 2)
			if collectables.size() > 0:
				var first_collectable = collectables.pop_front()
				points += first_collectable.value
				send_points.rpc(points)
				backpack_size += 1
				first_collectable.destroy.rpc()

@rpc("call_local", "reliable")
func send_points(value):
	points = value
	label.text = str(points)

@rpc("unreliable_ordered")
func send_data(pos: Vector2, vel: Vector2, mi: Vector2) -> void:
	global_position = lerp(global_position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)
	move_input = mi

@rpc("reliable", "call_local")
func add_to_backpack(value):
	if is_multiplayer_authority():
		points += value # temporal
		backpack_size += 1
		tried_to_pick = false



func _on_collection_area_area_entered(body):
	if body is Collectable:
		var collectable = body as Collectable
		collectables.append(collectable)



func _on_collection_area_area_exited(body):
	if body is Collectable:
		var collectable = body as Collectable
		collectables.erase(collectable)
