class_name Player
extends CharacterBody2D


const speed = 300
@export var acceleration = 4000
@export var backpack_max_size = 10
@export var backpack_size = 0
@export var points = 0
@onready var label = $Label
@onready var deposit_delay = $depositDelay
@onready var label_2 = $Label2
@onready var character_camera = $CharacterCamera
@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")
@onready var pivot = $Pivot
@onready var bullet_spawn = $Pivot/BulletSpawn

var health = 20
var is_on_deposit_zone = false
var move_input = Vector2(0,0)
var collectables : Array = []
var collected : Array = []

#export(PackedScene) var Bullet
#var Bullet = PackedScene.new()
var Bullet = preload("res://scenes/bullet.tscn")

signal scores_updated

func init(id):
	
	set_multiplayer_authority(id)
	name = str(id)
	if is_multiplayer_authority():
		character_camera.make_current()
	animation_tree.active = true

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
		if Input.is_action_just_pressed("fire"):
			#rpc("_fire")
			self._fire.rpc() 
	#Animation
	move_and_slide()
	if move_input.x != 0:
		pivot.scale.x = sign(move_input.x)
	if abs(velocity.x) >= 10 or abs(velocity.y) >= 10 or move_input != Vector2.ZERO:
		playback.travel("run")
	else:
		playback.travel("idle")

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
	scores_updated.emit() # TODO: Fix scores
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

@rpc("reliable","call_local")
func _fire():
	var bullet = Bullet.instantiate()
	var id = multiplayer.get_remote_sender_id()
	bullet.set_multiplayer_authority(id)
	get_parent().add_child(bullet)
	bullet.global_position = bullet_spawn.global_position
	if pivot.scale.x == -1:
		bullet.rotation = PI
		
@rpc("reliable","any_peer")		
func on_hit():
	health -= 1
	print(health)
	if health <= 0:
		destroy.rpc()
@rpc("call_local", "reliable", "any_peer")
func destroy():
	queue_free()
