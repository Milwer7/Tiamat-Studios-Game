extends PanelContainer

@onready var button = $Button
@onready var title = %Title
@onready var description = %Description
@onready var buff_icon = %BuffIcon
var action
@onready var sound = $sound
@onready var soundbuffmusic = $soundbuffmusic

# Called when the node enters the scene tree for the first time.
func _ready():
	button.pressed.connect(_on_button_pressed)
	MusicaFondo.buffs_music()
	
func start(card_buff: CardBuff):
	buff_icon.texture = card_buff.picture
	title.text = card_buff.name
	description.text = card_buff.description
	action = card_buff.action

func _on_button_pressed():
	Actions.get_action(action).call()
	sound.play()
	await get_tree().create_timer(1).timeout
	for child in Game.card_selector.get_children():
		child.queue_free()
