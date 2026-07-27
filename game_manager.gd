extends Node

const save_path = "user://save_data.json"
var save_data: Dictionary

@onready var points_label: RichTextLabel = %PointsLabel
@onready var per_second_label: RichTextLabel = %PerSecondLabel
@onready var per_click_label: RichTextLabel = %PerClickLabel
@onready var click_upgrade_label: RichTextLabel = %ClickUpgradeLabel
@onready var pps_upgrade_label: RichTextLabel = %PPSUpgradeLabel
@onready var offline_points_label: RichTextLabel = %OfflinePointsLabel

@onready var click_button: TextureButton = %Click_TextureButton
@onready var menu_button: Button = %MenuButton
@onready var click_upgrade_button: Button = %ClickUpgradeButton
@onready var pps_upgrade_button: Button = %PPSUpgradeButton

var points: float = 0.0
var offline_points: float = 0.0
var points_per_second: int = 0
var points_per_click: int = 1
var click_scale: int = 1
var pps_scale: int = 1

var click_upgrade_amount: int = 50
var pps_upgrade_amount: int = 500
var click_upgrade_scale: int = 50
var pps_upgrade_scale: int = 500

func _ready() -> void:
	load_game()
	get_tree().set_auto_accept_quit(false)
	get_window().unresizable = true
	
	# Button signals
	click_button.button_down.connect(_on_click_button_down)
	menu_button.button_down.connect(_on_menu_button_down)
	click_upgrade_button.button_down.connect(_on_click_upgrade_button_down)
	pps_upgrade_button.button_down.connect(_on_pps_upgrade_button_down)
	
	# Initialize labels
	update_labels()
	update_upgrade_text()

func _process(delta: float) -> void:
	points += points_per_second * delta
	update_labels()

func update_upgrade_text() -> void:
	click_upgrade_button.text = str(click_upgrade_amount)
	pps_upgrade_button.text = str(pps_upgrade_amount)

func update_labels() -> void:
	points_label.text = "%s points" % [int(points)]
	per_second_label.text = "per second:  %s" % [points_per_second]
	per_click_label.text = "per click:  %s" % [points_per_click]

func display_offline_points_label() -> void:
	offline_points_label.text = "You earned %s points while away!" % [int(offline_points)]
	offline_points_label.show()
	await get_tree().create_timer(2.0).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(offline_points_label, "modulate:a", 0, 1)
	await tween.finished
	offline_points_label.hide()

#region BUTTON SIGNALS
func _on_click_button_down() -> void:
	points += points_per_click

func _on_click_upgrade_button_down() -> void:
	if points >= click_upgrade_amount:
		points -= click_upgrade_amount
		click_upgrade_amount += click_upgrade_scale
		points_per_click += click_scale
		update_upgrade_text()

func _on_pps_upgrade_button_down() -> void:
	if points >= pps_upgrade_amount:
		points -= pps_upgrade_amount
		pps_upgrade_amount += pps_upgrade_scale
		points_per_second += pps_scale
		update_upgrade_text()

func _on_menu_button_down() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
#endregion

#region SAVE GAME
func save_game() -> void:
	save_data = {
		"last_saved_time": Time.get_unix_time_from_system(),
		"points": points,
		"points_per_click": points_per_click,
		"points_per_second": points_per_second,
		"click_upgrade_amount": click_upgrade_amount,
		"pps_upgrade_amount": pps_upgrade_amount
	}
	var file_access: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	file_access.store_string(JSON.stringify(save_data, "\t", false))
	file_access.close()

func load_game() -> void:
	if FileAccess.file_exists(save_path):
		var file_access: FileAccess = FileAccess.open(save_path, FileAccess.READ)
		save_data = JSON.parse_string(file_access.get_as_text())
		file_access.close()
		
		points = save_data["points"]
		points_per_click = save_data["points_per_click"]
		points_per_second = save_data["points_per_second"]
		click_upgrade_amount = save_data["click_upgrade_amount"]
		pps_upgrade_amount = save_data["pps_upgrade_amount"]
		
		var current_time = Time.get_unix_time_from_system()
		var elapsed = current_time - save_data["last_saved_time"]
		# Maximum of 8 hours idle
		elapsed = clamp(elapsed, 0, 60 * 60 * 8)
		offline_points = elapsed * points_per_second
		if offline_points > 0:
			points += offline_points
			display_offline_points_label()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()
#endregion
