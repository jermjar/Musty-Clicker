extends CenterContainer

@onready var main_button: TextureButton = %Click_TextureButton

func _ready() -> void:
	main_button.pivot_offset_ratio = Vector2(0.5, 0.5)
	main_button.button_down.connect(_on_main_button_down)
	main_button.button_up.connect(_on_main_button_up)

func _on_main_button_down() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(main_button, "scale", Vector2(0.9, 0.9), 0.1)

func _on_main_button_up() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(main_button, "scale", Vector2(1.0, 1.0), 0.1)
