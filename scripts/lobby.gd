extends MarginContainer
@export var player_team: PackedScene

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
@onready var button = $PanelContainer/MarginContainer/Pending/TeamSelector/Button
@onready var button_2 = $PanelContainer/MarginContainer/Pending/TeamSelector/Button2
var team = 0

# { id: true }
var status = { 1 : false }


func _ready():
	host.pressed.connect(_on_host_pressed)
	join.pressed.connect(_on_join_pressed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_cancel_pressed)
	start.show()
	pending.hide()
	user.text = OS.get_environment("USERNAME") + str(randi() % 1000)
	
	go.pressed.connect(_on_go_pressed)
	cancel.pressed.connect(_on_cancel_pressed)
	button.pressed.connect(onTeam1ButtonPressed)
	button_2.pressed.connect(onTeam2ButtonPressed)
	
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
	_add_player(multiplayer.get_unique_id(), user.text, team)
	pending.show()


func _on_join_pressed() -> void:

	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip.text, PORT)
	multiplayer.multiplayer_peer = peer
	start.hide()
	_add_player(multiplayer.get_unique_id(), user.text, team)
	pending.show()


func _on_peer_connected(id: int) -> void:
	rpc_id(id, "send_info", { "name": user.text, "team": team })
	if multiplayer.is_server():
		status[id] = false
		
func _on_peer_disconnected(id: int) -> void:
	_on_cancel_pressed()		


func _add_player(id: int, name: String, team: int):
	var playerr_team = player_team.instantiate()
	playerr_team.name = str(id)
	players.add_child(playerr_team)
	playerr_team.set_namee(name)
	playerr_team.set_team(team)
	Game.players.append({"id": id, "name": name, "team": team})


@rpc("any_peer", "reliable")
func send_info(info: Dictionary) -> void:
	var name1 = info.name
	var team1 = info.team
	var id = multiplayer.get_remote_sender_id()
	_add_player(id, name1 ,team1)


func _paint_ready(id: int) -> void:
	for child in players.get_children():
		if child.name == str(id):
			child.modulate = Color.GREEN_YELLOW


func _on_go_pressed() -> void:
	rpc("player_ready")
	_paint_ready(multiplayer.get_unique_id())
	
func _on_cancel_pressed() -> void:
	multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
	
	
	

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

@rpc("reliable", "any_peer", "call_local")
func send_team(teamm: int):
	var id = multiplayer.get_remote_sender_id()
	for child in players.get_children():
		if child.name == str(id):
			child.set_team(teamm)
			break
	for i in Game.players.size():
		if Game.players[i].id == id:
			Game.players[i].team = teamm
			
func onTeam1ButtonPressed():
	team = 1
	send_team.rpc(team)

func onTeam2ButtonPressed():
	team = 2
	send_team.rpc(team)


@rpc("any_peer", "call_local", "reliable")
func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
