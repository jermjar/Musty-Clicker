extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $FlyAnimatedSprite2D
@onready var button: Button = $Button

var audio: Node
var game_manager: Node2D
var fly_player: AudioStreamPlayer
var squish_player: AudioStreamPlayer


func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("game_manager")
	audio = get_tree().get_first_node_in_group("audio")
	fly_player = audio.fly_player
	squish_player = audio.squish_player
	button.button_down.connect(_on_fly_clicked)

func _on_fly_clicked() -> void:
	fly_player.stop()
	squish_player.play()
	game_manager.display_floating_updoot_label(50)
	queue_free()
