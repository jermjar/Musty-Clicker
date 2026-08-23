extends Node

const FLY = preload("uid://db2x75j23im2c")

@export var audio: Node
@onready var fly_player: AudioStreamPlayer = audio.fly_player

@onready var path_1: PathFollow2D = $Path2D_1/PathFollow2D
@onready var path_2: PathFollow2D = $Path2D_2/PathFollow2D
@onready var path_3: PathFollow2D = $Path2D_3/PathFollow2D
@onready var path_4: PathFollow2D = $Path2D_4/PathFollow2D
@onready var paths: Array[PathFollow2D] = [ path_1, path_2, path_3, path_4 ]

var elapsed_time: float = 0.0
var path_index: int = 0

## TODO
## - Make the fly appear every few minutes and save the time/index in save data
## - Add bug splat gfx
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	elapsed_time += delta
	
	if elapsed_time >= 10.0:
		elapsed_time = 0
		fly(paths[path_index])
		path_index += 1
		if path_index >= paths.size():
			path_index = 0

func fly(path: PathFollow2D) -> void:
	fly_player.play()
	path.progress_ratio = 0
	
	var fly_node = FLY.instantiate()
	path.add_child(fly_node)
	if path_index == 0:
		fly_node.sprite.flip_h = false
		fly_node.sprite.flip_v = false
	elif path_index == 1:
		fly_node.sprite.flip_h = true
		fly_node.sprite.flip_v = true
	elif path_index == 2:
		fly_node.sprite.flip_h = true
		fly_node.sprite.flip_v = true
	elif path_index == 3:
		fly_node.sprite.flip_h = false
		fly_node.sprite.flip_v = false
		
	var tween: Tween = create_tween()
	tween.tween_property(path, "progress_ratio", 1.0, 6.0)
	await tween.finished
	fly_player.stop()
	if fly_node:
		fly_node.queue_free()
