extends Node
@onready var music = %Music
@onready var music_game = %MusicGame
@onready var musicbuffs = $Musicbuffs

func pause_menu_music():
	music.stream_paused = true
	music_game.playing = true
	
func pause_game_music():
	music_game.stream_paused = true
	music.playing = true	
	
func buffs_music():
	music_game.stream_paused = true
	musicbuffs.playing = true
	
func pause_buff_music():
	musicbuffs.stream_paused = true
	music_game.playing = true
		
	
