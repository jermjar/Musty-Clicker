extends Node

const save_path = "user://save_data.json"
var save_data: Dictionary

enum OfflineHours {
	ZERO = 0,
	ONE = 1,
	TWO = 2,
	THREE = 3,
	FOUR = 4,
	FIVE = 5,
	SIX = 6,
	SEVEN = 7,
	EIGHT = 8
}

@onready var points_label: RichTextLabel = %PointsLabel
@onready var per_second_label: RichTextLabel = %PerSecondLabel
@onready var per_click_label: RichTextLabel = %PerClickLabel
@onready var offline_points_label: RichTextLabel = %OfflinePointsLabel
@onready var offline_upgrade_label: RichTextLabel = %OfflineUpgradeLabel

@onready var click_button: TextureButton = %Click_TextureButton
@onready var menu_button: Button = %MenuButton
@onready var click_upgrade_button: Button = %ClickUpgradeButton
@onready var pps_upgrade_button: Button = %PPSUpgradeButton
@onready var offline_upgrade_button: Button = %OfflineUpgradeButton

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
var offline_upgrade_amount: int = 5000
var offline_upgrade_scale: int = 15000

var offline_hours: OfflineHours = OfflineHours.ZERO
var offline_button_disabled: bool = false

func _ready() -> void:
	load_game()
	get_tree().set_auto_accept_quit(false)
	get_window().unresizable = true
	
	# Button signals
	click_button.button_down.connect(_on_click_button_down)
	menu_button.button_down.connect(_on_menu_button_down)
	click_upgrade_button.button_down.connect(_on_click_upgrade_button_down)
	pps_upgrade_button.button_down.connect(_on_pps_upgrade_button_down)
	offline_upgrade_button.button_down.connect(_on_offline_upgrade_button_down)
	
	# Initialize labels
	update_labels()
	update_upgrade_text()

func _process(delta: float) -> void:
	points += points_per_second * delta
	update_labels()

func update_upgrade_text() -> void:
	click_upgrade_button.text = str(click_upgrade_amount)
	pps_upgrade_button.text = str(pps_upgrade_amount)
	offline_upgrade_button.text = str(offline_upgrade_amount)
	if offline_hours > OfflineHours.ZERO and not offline_button_disabled:
		offline_upgrade_label.text = "Offline Hours Upgrade (%s Hours)" % [offline_hours + 1]
	if offline_button_disabled:
		offline_upgrade_label.text = "Offline Hours Upgrade (8 Hours)"
		offline_upgrade_button.text = "PURCHASED"

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

func _on_offline_upgrade_button_down() -> void:
	if points >= offline_upgrade_amount:
		points -= offline_upgrade_amount
		match offline_hours:
			OfflineHours.ZERO:
				offline_hours = OfflineHours.ONE
				offline_upgrade_amount = 25000
			OfflineHours.ONE:
				offline_hours = OfflineHours.TWO
				offline_upgrade_amount = 50000
			OfflineHours.TWO:
				offline_hours = OfflineHours.THREE
				offline_upgrade_amount = 100000
			OfflineHours.THREE:
				offline_hours = OfflineHours.FOUR
				offline_upgrade_amount = 150000
			OfflineHours.FOUR:
				offline_hours = OfflineHours.FIVE
				offline_upgrade_amount = 300000
			OfflineHours.FIVE:
				offline_hours = OfflineHours.SIX
				offline_upgrade_amount = 500000
			OfflineHours.SIX:
				offline_hours = OfflineHours.SEVEN
				offline_upgrade_amount = 1000000
			OfflineHours.SEVEN:
				offline_hours = OfflineHours.EIGHT
				offline_button_disabled = true
				offline_upgrade_button.disabled = offline_button_disabled
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
		"pps_upgrade_amount": pps_upgrade_amount,
		"offline_upgrade_amount": offline_upgrade_amount,
		"offline_hours": offline_hours,
		"offline_button_disabled": offline_button_disabled
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
		offline_upgrade_amount = save_data["offline_upgrade_amount"]
		offline_hours = save_data["offline_hours"]
		offline_button_disabled = save_data["offline_button_disabled"]
		offline_upgrade_button.disabled = offline_button_disabled
		
		var current_time = Time.get_unix_time_from_system()
		var elapsed = current_time - save_data["last_saved_time"]
		elapsed = clamp(elapsed, 0, (60 * 60 * offline_hours))
		offline_points = elapsed * points_per_second
		if offline_points > 0:
			points += offline_points
			display_offline_points_label()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()
#endregion
