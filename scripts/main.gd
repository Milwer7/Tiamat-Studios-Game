extends Node2D

@export var player_scene: PackedScene
@export var first_cards: Array[CardBuff]
@export var second_cards: Array[CardBuff]
@export var third_cards: Array[CardBuff]
@export var card_scene: PackedScene
@onready var players = $Players
@onready var markers = $MarkersTeam1
@onready var markers2 = $MarkersTeam2
@onready var scores = $CanvasLayer/Scores
@onready var scores2 = $CanvasLayer/VBoxContainer
@onready var game_time = $GameTime
@onready var time_remaining_label = $CanvasLayer/TimeRemainingLabel
@onready var card_selector = $CanvasLayer2/CardSelector
@onready var collectable = $Interactive/collectable

func _ready():
	MusicaFondo.pause_menu_music()
	Game.players.sort_custom(func(a, b): return a.id < b.id)	
	for i in Game.players.size():
		var id = Game.players[i].id
		var player : Player = player_scene.instantiate()
		
		var team = Game.players[i].team
		print("team=" , team)
		player.name = str(id)
		player.scale = Vector2(0.8,0.8)
		player.team = Game.players[i].team
		players.add_child(player)
		if(team==1):
			var marker = markers.get_child(i%3)
			player.global_position = marker.global_position
		else:
			var marker = markers2.get_child(i%3)
			player.global_position = marker.global_position			
		player.scores_updated.connect(on_scores_updated)
		player.init(id)
		
		Game.players[i].node = player
		game_time.start()
	
	Game.card_selector = card_selector
	timers()


func _process(_delta):
	var time_remaining = int(game_time.time_left)
	var seconds = time_remaining%60
	var minutes = (time_remaining/60)%60
	time_remaining_label.text = "%02d:%02d" % [minutes, seconds]
	

func on_scores_updated():
	scores.update_tables()
	scores2.update_tables()



func timers():
	# First buff spawn 1 mins
	await get_tree().create_timer(60).timeout
	for card_res in first_cards:
		var card = card_scene.instantiate()
		card_selector.add_child(card)
		card.start(card_res)
	card_selector.show()
	get_tree().paused = true
	await get_tree().create_timer(8).timeout
	get_tree().paused = false
	MusicaFondo.pause_buff_music()
	card_selector.hide()
	for child in Game.card_selector.get_children():
		child.queue_free()
	# Second buff spawn 2 mins
	await get_tree().create_timer(120).timeout
	for card_res in second_cards:
		var card = card_scene.instantiate()
		card_selector.add_child(card)
		card.start(card_res)
	card_selector.show()
	get_tree().paused = true
	await get_tree().create_timer(8).timeout
	get_tree().paused = false
	MusicaFondo.pause_buff_music()
	card_selector.hide()
	for child in Game.card_selector.get_children():
		child.queue_free()
	# Third card spawn 1 min
	await get_tree().create_timer(60).timeout
	for card_res in third_cards:
		var card = card_scene.instantiate()
		card_selector.add_child(card)
		card.start(card_res)
	card_selector.show()
	get_tree().paused = true
	await get_tree().create_timer(8).timeout
	get_tree().paused = false
	MusicaFondo.pause_buff_music()
	for child in Game.card_selector.get_children():
		child.queue_free()
	card_selector.hide()
	# End of the game 2 mins
	await get_tree().create_timer(120).timeout
	get_tree().change_scene_to_file("res://scenes/final.tscn")
