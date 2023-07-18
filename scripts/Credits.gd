extends MarginContainer

@onready var scroll=$ScrollContainer

var scroll_speed = 1
var scroll_ended = false

func _ready():
	scroll.scroll_vertical=0
	set_physics_process(false)
	await get_tree().create_timer(2).timeout
	set_physics_process(true)
	
func _physics_process(delta):
	var last_scroll = scroll.scroll_vertical
	scroll.scroll_vertical += scroll_speed
	var new_scroll = scroll.scroll_vertical
	if last_scroll == new_scroll:
		_check_scroll_ended()

func _check_scroll_ended():
	if not scroll_ended:
		scroll_ended = true
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
