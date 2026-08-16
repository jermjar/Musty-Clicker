extends CenterContainer

@onready var main_button: TextureButton = %Click_TextureButton

var hovering: bool = false

func _ready() -> void:
	main_button.pivot_offset_ratio = Vector2(0.5, 0.5)
	main_button.button_down.connect(_on_main_button_down)
	main_button.button_up.connect(_on_main_button_up)
	main_button.mouse_entered.connect(_on_mouse_entered)
	main_button.mouse_exited.connect(_on_mouse_exited)

func _on_main_button_down() -> void:
	if hovering:
		var tween = get_tree().create_tween()
		tween.tween_property(main_button, "scale", Vector2(1.0, 1.0), 0.1)

func _on_main_button_up() -> void:
	if hovering:
		var tween = get_tree().create_tween()
		tween.tween_property(main_button, "scale", Vector2(1.15, 1.15), 0.05)
		tween.tween_property(main_button, "scale", Vector2(1.0, 1.0), 0.05)
		tween.tween_property(main_button, "scale", Vector2(1.1, 1.1), 0.08)

func _on_mouse_entered() -> void:
	hovering = true
	var tween = get_tree().create_tween()
	tween.tween_property(main_button, "scale", Vector2(1.1, 1.1), 0.1)

func _on_mouse_exited() -> void:
	hovering = false
	var tween = get_tree().create_tween()
	tween.tween_property(main_button, "scale", Vector2(1.0, 1.0), 0.1)
