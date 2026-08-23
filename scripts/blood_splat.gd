extends Sprite2D

func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 1)
	await tween.finished
	
	queue_free()
