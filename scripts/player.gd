class_name Player
extends CharacterBody2D


const speed = 100
@export var acceleration = 4000
@export var backpack_max_size = 10
@export var backpack_size = 0
@export var points = 0
@onready var label = $Label
@onready var deposit_delay = $depositDelay
@onready var character_camera = $CharacterCamera
@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")
@onready var pivot = $Pivot
@onready var bullet_spawn = $Pivot/BulletSpawn
@onready var progress_bar = $Pivot/ProgressBar
@onready var respawn_time = $RespawnTime
@onready var healing_ticks = $HealingTicks


var is_dead = false
var can_fire = 1
var health = 20
var is_on_deposit_zone = false
var move_input = Vector2(0,0)
var collectables : Array = []
var collected : Array = []
var starting_point = Vector2.ZERO
var on_healing_area = false
var team

#export(PackedScene) var Bullet
#var Bullet = PackedScene.new()
var Bullet = preload("res://scenes/bullet.tscn")

signal scores_updated

func init(id):
	
	set_multiplayer_authority(id)
	name = str(id)
	starting_point = global_position
	if is_multiplayer_authority():
		character_camera.make_current()
		progress_bar.visible = true
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
	if is_multiplayer_authority() and not is_dead:
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
			var mouse_position: Vector2 = get_global_mouse_position()
			self._fire.rpc(mouse_position)
		# Obtener la posición global del cursor del mouse
		var mousePosition: Vector2 = get_global_mouse_position()

		# Calcular la dirección hacia el cursor del mouse
		var direction: Vector2 = mousePosition - global_position
		self._reflex.rpc(direction)
		# Comprobar si la dirección está a la derecha o a la izquierda
		#if direction.x > 0:
		#	pivot.scale.x = 1  # No se realiza rotación, el personaje mira hacia la derecha
		#else:
		#	pivot.scale.x = -1  # Se rota 180 grados, el personaje mira hacia la izquierda 
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

@rpc("call_local", "reliable")
func send_backpack(value):
	backpack_size = value
	label.text = "Backpack: " + str(backpack_size)

@rpc("unreliable_ordered")
func send_data(pos: Vector2, vel: Vector2, mi: Vector2) -> void:
	global_position = lerp(global_position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)
	move_input = mi


func _on_collection_area_area_entered(area):
	if area is Collectable:
		var collectable = area as Collectable
		collectables.append(collectable)
	if area is Deposit:
		is_on_deposit_zone = true
	if area is HealingZone:
		var healingZone = area as HealingZone
		on_healing_area = true
		heal_player()

func _on_collection_area_area_exited(body):
	if body is Collectable:
		var collectable = body as Collectable
		collectables.erase(collectable)
	if body is Deposit:
		is_on_deposit_zone = false
	if body is HealingZone:
		on_healing_area = false

@rpc("reliable","call_local")
func _fire(mouse_position):
	if can_fire:
		var bullet = Bullet.instantiate()
		var id = multiplayer.get_remote_sender_id()
		bullet.set_multiplayer_authority(id)
		get_parent().add_child(bullet)
		bullet.global_position = bullet_spawn.global_position
		# Obtener la posición global del cursor del mouse
		#var mouse_position: Vector2 = get_global_mouse_position()
		# Calcular el ángulo entre la posición del objeto y la posición del cursor del mouse
		var object_position: Vector2 = bullet.global_position
		var angle: float = atan2(mouse_position.y - object_position.y, mouse_position.x - object_position.x)
		# Orientar el objeto hacia la posición del cursor del mouse
		bullet.rotation = angle
		can_fire = 0
		var timer = Timer.new()
		timer.connect("timeout",do_this)
		timer.wait_time = 0.5
		timer.one_shot = true
		add_child(timer)
		timer.start()

@rpc("reliable","any_peer")		
func on_hit():
	health -= 1
	progress_bar.value = health * 5
	if health <= 0:
		destroy.rpc()

@rpc("call_local", "reliable", "any_peer")
func destroy():
	respawn_time.start()
	is_dead = true
	self.visible = false

func do_this():
	can_fire = 1
	
func _on_respawn_time_timeout():
	is_dead = false
	position = starting_point
	self.visible = true
	self.health = 20
	progress_bar.value = 100

func heal_player():
	if on_healing_area:
		health = min(20, health + 2)
		progress_bar.value = health * 5
		healing_ticks.start()

func _on_healing_ticks_timeout():
	if on_healing_area:
		heal_player()

@rpc("unreliable","call_local")
func _reflex(direction):
	if direction.x > 0:
			pivot.scale.x = 1  # No se realiza rotación, el personaje mira hacia la derecha
	else:
			pivot.scale.x = -1  # Se rota 180 grados, el personaje mira hacia la izquierda 
