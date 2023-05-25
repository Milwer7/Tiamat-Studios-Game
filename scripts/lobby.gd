extends MarginContainer


const MAX_PLAYERS = 3
const PORT = 5409

@onready var user = %User
@onready var ip = %IP
@onready var host = %Host
@onready var join = %Join

@onready var start = %Start
@onready var pending = %Pending
@onready var players = %Players

@onready var cancel = $PanelContainer/MarginContainer/Pending/HBoxContainer/Cancel
@onready var go = $PanelContainer/MarginContainer/Pending/HBoxContainer/Go

@onready var info = $PanelContainer/MarginContainer/Start/Info


# { id: true }
var status = { 1 : false }


func _ready():
	host.pressed.connect(_on_host_pressed)
	join.pressed.connect(_on_join_pressed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	start.show()
	pending.hide()
	user.text = OS.get_environment("USERNAME") + str(randi() % 1000)
	
	go.pressed.connect(_on_go_pressed)
	
	info.hide()


func _on_upnp_completed(status) -> void:
	print(status)
	if status == OK:
		info.text = "Port Opened"
	else:
		info.text = "Error"
	info.show()
	

func _on_host_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	start.hide()
	_add_player(user.text, multiplayer.get_unique_id())
	pending.show()


func _on_join_pressed() -> void:

	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip.text, PORT)
	multiplayer.multiplayer_peer = peer
	start.hide()
	_add_player(user.text, multiplayer.get_unique_id())
	pending.show()



func _on_peer_connected(id: int) -> void:
	rpc_id(id, "send_info", { "name": user.text })
	if multiplayer.is_server():
		status[id] = false


func _add_player(name: String, id: int):
	var label = Label.new()
	label.name = str(id)
	label.text = name
	players.add_child(label)
	Game.players.append(id)
	Game.names.append(name)


@rpc("any_peer", "reliable")
func send_info(info: Dictionary) -> void:
	var name = info.name
	var id = multiplayer.get_remote_sender_id()
	_add_player(name, id)


func _paint_ready(id: int) -> void:
	for child in players.get_children():
		if child.name == str(id):
			child.modulate = Color.GREEN_YELLOW


func _on_go_pressed() -> void:
	rpc("player_ready")
	_paint_ready(multiplayer.get_unique_id())


@rpc("reliable", "any_peer", "call_local")
func player_ready():
	var id = multiplayer.get_remote_sender_id()
	_paint_ready(id)
	if multiplayer.is_server():
		status[id] = true
		var all_ok = true
		for ok in status.values():
			all_ok = all_ok and ok
		if all_ok:
			rpc("start_game")
			
func onTeam1ButtonPressed():
	rpc_id(1, "setPlayerTeam", 1)

func onTeam2ButtonPressed():
	rpc_id(1, "setPlayerTeam", 2)
	

@rpc("any_peer", "call_local", "reliable")
func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
