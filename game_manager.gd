extends Node2D

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
enum Cosmetics {
	WOJAK,
	SOYJAK,
	COBSON,
	CHUDJAK,
	GAPEJAK,
	REDACTED
}

const LABEL_SPEED = 200
const upvote_sprite: StringName = "res://art/UI/Upvote.png"
const save_path = "user://save_data.json"

var save_data: Dictionary
var cosmetic_data: Dictionary = {
	Cosmetics.WOJAK: true,
	Cosmetics.SOYJAK: false,
	Cosmetics.COBSON: false,
	Cosmetics.CHUDJAK: false,
	Cosmetics.GAPEJAK: false,
	Cosmetics.REDACTED: false
}

@export var wojak_sprite: CompressedTexture2D
@export var soyjak_sprite: CompressedTexture2D
@export var cobson_sprite: CompressedTexture2D
@export var chudjak_sprite: CompressedTexture2D
@export var gapejak_sprite: CompressedTexture2D
@export var redacted_sprite: CompressedTexture2D

@onready var wojak_button: Button = %WojakButton
@onready var soyjak_button: Button = %SoyjakButton
@onready var cobson_button: Button = %CobsonButton
@onready var chudjak_button: Button = %ChudjakButton
@onready var gapejak_button: Button = %GapejakButton
@onready var redacted_button: Button = %RedactedButton

@onready var points_label: RichTextLabel = %UpdootsLabel
@onready var per_second_label: RichTextLabel = %PerSecondLabel
@onready var offline_points_label: RichTextLabel = %OfflineUpdootsLabel
@onready var offline_upgrade_label: RichTextLabel = %OfflineUpgradeLabel
@onready var redacted_label: RichTextLabel = %RedactedLabel

@onready var click_button: TextureButton = %Click_TextureButton
@onready var menu_button: Button = %MenuButton
@onready var click_upgrade_button: Button = %ClickUpgradeButton
@onready var pps_upgrade_button: Button = %PPSUpgradeButton
@onready var offline_upgrade_button: Button = %OfflineUpgradeButton

@onready var upgrade_foldable_container: FoldableContainer = %UpgradeFoldableContainer
@onready var cosmetic_foldable_container: FoldableContainer = %CosmeticFoldableContainer
@onready var click_center_container: CenterContainer = %Click_CenterContainer

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

var offline_hours: OfflineHours = OfflineHours.ZERO
var offline_button_disabled: bool = false
var current_skin: Cosmetics = Cosmetics.WOJAK
var show_redacted_amount: bool = false
var stop_process_check: bool = false

func _ready() -> void:
	load_game()
	get_tree().set_auto_accept_quit(false)
	get_window().unresizable = true
	
	# Button signals
	click_button.button_up.connect(_on_click_button_up)
	menu_button.button_down.connect(_on_menu_button_down)
	click_upgrade_button.button_down.connect(_on_click_upgrade_button_down)
	pps_upgrade_button.button_down.connect(_on_pps_upgrade_button_down)
	offline_upgrade_button.button_down.connect(_on_offline_upgrade_button_down)
	
	wojak_button.button_down.connect(_on_cosmetic_button_down.bind(Cosmetics.WOJAK))
	soyjak_button.button_down.connect(_on_cosmetic_button_down.bind(Cosmetics.SOYJAK))
	cobson_button.button_down.connect(_on_cosmetic_button_down.bind(Cosmetics.COBSON))
	chudjak_button.button_down.connect(_on_cosmetic_button_down.bind(Cosmetics.CHUDJAK))
	gapejak_button.button_down.connect(_on_cosmetic_button_down.bind(Cosmetics.GAPEJAK))
	redacted_button.button_down.connect(_on_cosmetic_button_down.bind(Cosmetics.REDACTED))
	
	# Initialize labels
	update_labels()
	update_upgrade_text()
	update_cosmetic(current_skin)
	update_cosmetic_labels()

func _process(delta: float) -> void:
	points += points_per_second * delta
	update_labels()
	
	if points >= 9000000 and not show_redacted_amount:
		show_redacted_amount = true
	
	if show_redacted_amount and not stop_process_check:
		stop_process_check = true
		update_cosmetic_labels()

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
	points_label.text = "[outline_size=4][outline_color=black]%s updoots" % [int(points)]
	per_second_label.text = "[outline_size=4][outline_color=black]per second:  %s" % [points_per_second]

func update_cosmetic(skin: Cosmetics) -> void:
	match skin:
		Cosmetics.WOJAK:
			wojak_button.text = "EQUIPPED"
			click_button.texture_normal = wojak_sprite
			wojak_button.disabled = true
			current_skin = skin
		Cosmetics.SOYJAK:
			soyjak_button.text = "EQUIPPED"
			click_button.texture_normal = soyjak_sprite
			soyjak_button.disabled = true
			current_skin = skin
		Cosmetics.COBSON:
			cobson_button.text = "EQUIPPED"
			click_button.texture_normal = cobson_sprite
			cobson_button.disabled = true
			current_skin = skin
		Cosmetics.CHUDJAK:
			chudjak_button.text = "EQUIPPED"
			click_button.texture_normal = chudjak_sprite
			chudjak_button.disabled = true
			current_skin = skin
		Cosmetics.GAPEJAK:
			gapejak_button.text = "EQUIPPED"
			click_button.texture_normal = gapejak_sprite
			gapejak_button.disabled = true
			current_skin = skin
		Cosmetics.REDACTED:
			redacted_button.text = "EQUIPPED"
			click_button.texture_normal = redacted_sprite
			redacted_button.disabled = true
			current_skin = skin

func update_cosmetic_labels() -> void:
	if cosmetic_data[Cosmetics.WOJAK]:
		if current_skin == Cosmetics.WOJAK:
			wojak_button.text = "EQUIPPED"
			wojak_button.disabled = true
		else:
			wojak_button.text = "EQUIP"
			wojak_button.disabled = false
	
	if cosmetic_data[Cosmetics.SOYJAK]:
		if current_skin == Cosmetics.SOYJAK:
			soyjak_button.text = "EQUIPPED"
			soyjak_button.disabled = true
		else:
			soyjak_button.text = "EQUIP"
			soyjak_button.disabled = false
	
	if cosmetic_data[Cosmetics.COBSON]:
		if current_skin == Cosmetics.COBSON:
			cobson_button.text = "EQUIPPED"
			cobson_button.disabled = true
		else:
			cobson_button.text = "EQUIP"
			cobson_button.disabled = false
	
	if cosmetic_data[Cosmetics.CHUDJAK]:
		if current_skin == Cosmetics.CHUDJAK:
			chudjak_button.text = "EQUIPPED"
			chudjak_button.disabled = true
		else:
			chudjak_button.text = "EQUIP"
			chudjak_button.disabled = false
	
	if cosmetic_data[Cosmetics.GAPEJAK]:
		if current_skin == Cosmetics.GAPEJAK:
			gapejak_button.text = "EQUIPPED"
			gapejak_button.disabled = true
		else:
			gapejak_button.text = "EQUIP"
			gapejak_button.disabled = false
	
	if cosmetic_data[Cosmetics.REDACTED]:
		if current_skin == Cosmetics.REDACTED:
			redacted_label.text = "Tony Soprano Soyjak"
			redacted_button.text = "EQUIPPED"
			redacted_button.disabled = true
		else:
			redacted_label.text = "Tony Soprano Soyjak"
			redacted_button.text = "EQUIP"
			redacted_button.disabled = false
	else:
		if show_redacted_amount:
			redacted_button.text = str(25000000)
			redacted_label.text = "Tony Soprano Soyjak"
		else:
			redacted_button.text = "???"
			redacted_label.text = "[REDACTED]"

func display_offline_points_label() -> void:
	offline_points_label.text = "[outline_size=4][outline_color=black]You earned %s updoots while away!" % [int(offline_points)]
	offline_points_label.show()
	await get_tree().create_timer(3.0).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(offline_points_label, "modulate:a", 0, 1)
	await tween.finished
	offline_points_label.hide()

#region BUTTON SIGNALS
func _on_click_button_up() -> void:
	if click_center_container.hovering:
		points += points_per_click
		var ppc_label: RichTextLabel = RichTextLabel.new()
		var mouse_pos = get_global_mouse_position()
		#ppc_label.theme = load("res://soyjak_theme.tres")
		ppc_label.text = "[color=white][outline_size=4][outline_color=black][img]%s[/img] %s" % [upvote_sprite, points_per_click]
		ppc_label.position = mouse_pos
		ppc_label.bbcode_enabled = true
		ppc_label.fit_content = true
		ppc_label.custom_minimum_size = Vector2(100, 25)
		ppc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		self.get_child(0).add_child(ppc_label)
		var position_tween = get_tree().create_tween()
		position_tween.tween_property(ppc_label, "position:y", mouse_pos.y - LABEL_SPEED, 3)
		await get_tree().create_timer(2.0).timeout
		var alpha_tween = get_tree().create_tween()
		alpha_tween.tween_property(ppc_label, "modulate:a", 0, 1)
		await alpha_tween.finished
		ppc_label.queue_free()

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
				offline_upgrade_amount = 200000
			OfflineHours.FOUR:
				offline_hours = OfflineHours.FIVE
				offline_upgrade_amount = 500000
			OfflineHours.FIVE:
				offline_hours = OfflineHours.SIX
				offline_upgrade_amount = 1000000
			OfflineHours.SIX:
				offline_hours = OfflineHours.SEVEN
				offline_upgrade_amount = 10000000
			OfflineHours.SEVEN:
				offline_hours = OfflineHours.EIGHT
				offline_button_disabled = true
				offline_upgrade_button.disabled = offline_button_disabled
		update_upgrade_text()

func _on_cosmetic_button_down(skin: Cosmetics) -> void:
	match skin:
		Cosmetics.WOJAK:
			update_cosmetic(skin)
			cosmetic_data[Cosmetics.WOJAK] = true
		Cosmetics.SOYJAK:
			if points >= int(soyjak_button.text):
				points -= int(soyjak_button.text)
				update_cosmetic(skin)
				cosmetic_data[Cosmetics.SOYJAK] = true
		Cosmetics.COBSON:
			if points >= int(cobson_button.text):
				points -= int(cobson_button.text)
				update_cosmetic(skin)
				cosmetic_data[Cosmetics.COBSON] = true
		Cosmetics.CHUDJAK:
			if points >= int(chudjak_button.text):
				points -= int(chudjak_button.text)
				update_cosmetic(skin)
				cosmetic_data[Cosmetics.CHUDJAK] = true
		Cosmetics.GAPEJAK:
			if points >= int(gapejak_button.text):
				points -= int(gapejak_button.text)
				update_cosmetic(skin)
				cosmetic_data[Cosmetics.GAPEJAK] = true
		Cosmetics.REDACTED:
			if points >= int(redacted_button.text):
				points -= int(redacted_button.text)
				update_cosmetic(skin)
				cosmetic_data[Cosmetics.REDACTED] = true
	update_cosmetic_labels()

func _on_menu_button_down() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
#endregion

#region SAVE GAME
func save_game() -> void:
	save_data = {
		"last_saved_time": Time.get_unix_time_from_system(),
		"points": int(points),
		"points_per_click": points_per_click,
		"points_per_second": points_per_second,
		"click_upgrade_amount": click_upgrade_amount,
		"pps_upgrade_amount": pps_upgrade_amount,
		"offline_upgrade_amount": offline_upgrade_amount,
		"offline_hours": offline_hours,
		"offline_button_disabled": offline_button_disabled,
		"current_skin": current_skin,
		"cosmetic_data": var_to_str(cosmetic_data),
		"upgrade_foldable": upgrade_foldable_container.folded,
		"cosmetic_foldable": cosmetic_foldable_container.folded,
		"show_redacted_amount": show_redacted_amount
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
		current_skin = save_data["current_skin"]
		cosmetic_data = str_to_var(save_data["cosmetic_data"])
		upgrade_foldable_container.folded = save_data["upgrade_foldable"]
		cosmetic_foldable_container.folded = save_data["cosmetic_foldable"]
		show_redacted_amount = save_data["show_redacted_amount"]
		
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
