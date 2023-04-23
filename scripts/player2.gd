class_name Player
extends CharacterBody2D


@export var speed = 300
@export var acceleration = 4000
@export var backpack_max_size = 10
@export var backpack_size = 0
@export var points = 0
@onready var label = $Label
@onready var deposit_delay = $depositDelay
@onready var label_2 = $Label2
@onready var character_camera = $CharacterCamera
@onready var scores = $CharacterCamera/Scores

var is_on_deposit_zone = false
var move_input = 0
var collectables : Array = []
var collected : Array = []


func init(id):
	set_multiplayer_authority(id)
	name = str(id)
	if is_multiplayer_authority():
		scores.visible = true
		character_camera.make_current()

func _ready_():
	deposit_delay.time_left = 0

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
			if collectables.size() > 0:
				var first_collectable = collectables.pop_front()
				collected.append(first_collectable.value)
				backpack_size += 1
				send_backpack.rpc(backpack_size)
				first_collectable.destroy.rpc()
		
		if is_on_deposit_zone and backpack_size > 0 and deposit_delay.time_left == 0:
			deposit()

func deposit():
	deposit_delay.start()
	var first_collected = collected.pop_front()
	points += first_collected
	backpack_size -= 1
	send_points.rpc(points)
	send_backpack.rpc(backpack_size)

@rpc("call_local", "reliable")
func send_points(value):
	points = value
#	scores.update_tables() # TODO: Fix scores
	label_2.text = "Points: " + str(points)

@rpc("call_local", "reliable")
func send_backpack(value):
	backpack_size = value
	label.text = "Backpack: " + str(backpack_size)

@rpc("unreliable_ordered")
func send_data(pos: Vector2, vel: Vector2, mi: Vector2) -> void:
	global_position = lerp(global_position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)
	move_input = mi


func _on_collection_area_area_entered(body):
	if body is Collectable:
		var collectable = body as Collectable
		collectables.append(collectable)
	if body is Deposit:
		is_on_deposit_zone = true

func _on_collection_area_area_exited(body):
	if body is Collectable:
		var collectable = body as Collectable
		collectables.erase(collectable)
	if body is Deposit:
		is_on_deposit_zone = false
