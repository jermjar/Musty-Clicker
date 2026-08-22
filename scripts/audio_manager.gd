extends Node

@export var bgm_player: AudioStreamPlayer
@export var sfx_player: AudioStreamPlayer

var sfx_players: Array[AudioStreamPlayer] = []
var master_volume: int
var music_volume: int
var sfx_volume: int

func _ready() -> void:
	pass
