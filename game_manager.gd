extends Node2D

const save_path = "user://save_data.json"
var save_data: Dictionary
var cosmetic_data: Dictionary = {
	Cosmetics.DEFAULT: true,
	Cosmetics.BLACK_OPS: false,
	Cosmetics.INCREDIBLE_GASSY: false,
	Cosmetics.KAPPA: false,
	Cosmetics.HEDGEHOG: false,
	Cosmetics.REDACTED: false
}

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
	DEFAULT,
	BLACK_OPS,
	INCREDIBLE_GASSY,
	KAPPA,
	HEDGEHOG,
	REDACTED
}

const LABEL_SPEED = 200

@export var default_sprite: CompressedTexture2D
@export var black_ops_sprite: CompressedTexture2D
@export var incredible_gassy_sprite: CompressedTexture2D
@export var kappa_sprite: CompressedTexture2D
@export var hedgehog_sprite: CompressedTexture2D
@export var redacted_sprite: CompressedTexture2D

@onready var default_button: Button = %DefaultButton
@onready var black_ops_button: Button = %BlackOpsButton
@onready var incredible_gassy_button: Button = %IncredibleGassyButton
@onready var kappa_button: Button = %KappaButton
@onready var hedgehog_button: Button = %HedgehogButton
@onready var redacted_button: Button = %RedactedButton

@onready var points_label: RichTextLabel = %PointsLabel
@onready var per_second_label: RichTextLabel = %PerSecondLabel
@onready var offline_points_label: RichTextLabel = %OfflinePointsLabel
@onready var offline_upgrade_label: RichTextLabel = %OfflineUpgradeLabel

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
var current_skin: Cosmetics = Cosmetics.DEFAULT
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
	
	default_button.button_down.connect(_on_cosmetic_button_down.bind(Cosmetics.DEFAULT))
	black_ops_button.button_down.connect(_on_cosmetic_button_down.bind(Cosmetics.BLACK_OPS))
	incredible_gassy_button.button_down.connect(_on_cosmetic_button_down.bind(Cosmetics.INCREDIBLE_GASSY))
	kappa_button.button_down.connect(_on_cosmetic_button_down.bind(Cosmetics.KAPPA))
	hedgehog_button.button_down.connect(_on_cosmetic_button_down.bind(Cosmetics.HEDGEHOG))
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
	points_label.text = "[outline_size=4][outline_color=black]%s points" % [int(points)]
	per_second_label.text = "[outline_size=4][outline_color=black]per second:  %s" % [points_per_second]

func update_cosmetic(skin: Cosmetics) -> void:
	match skin:
		Cosmetics.DEFAULT:
			default_button.text = "EQUIPPED"
			click_button.texture_normal = default_sprite
			default_button.disabled = true
			current_skin = skin
		Cosmetics.BLACK_OPS:
			black_ops_button.text = "EQUIPPED"
			click_button.texture_normal = black_ops_sprite
			black_ops_button.disabled = true
			current_skin = skin
		Cosmetics.INCREDIBLE_GASSY:
			incredible_gassy_button.text = "EQUIPPED"
			click_button.texture_normal = incredible_gassy_sprite
			incredible_gassy_button.disabled = true
			current_skin = skin
		Cosmetics.KAPPA:
			kappa_button.text = "EQUIPPED"
			click_button.texture_normal = kappa_sprite
			kappa_button.disabled = true
			current_skin = skin
		Cosmetics.HEDGEHOG:
			hedgehog_button.text = "EQUIPPED"
			click_button.texture_normal = hedgehog_sprite
			hedgehog_button.disabled = true
			current_skin = skin
		Cosmetics.REDACTED:
			redacted_button.text = "EQUIPPED"
			click_button.texture_normal = redacted_sprite
			redacted_button.disabled = true
			current_skin = skin

func update_cosmetic_labels() -> void:
	if cosmetic_data[Cosmetics.DEFAULT]:
		if current_skin == Cosmetics.DEFAULT:
			default_button.text = "EQUIPPED"
			default_button.disabled = true
		else:
			default_button.text = "EQUIP"
			default_button.disabled = false
	
	if cosmetic_data[Cosmetics.BLACK_OPS]:
		if current_skin == Cosmetics.BLACK_OPS:
			black_ops_button.text = "EQUIPPED"
			black_ops_button.disabled = true
		else:
			black_ops_button.text = "EQUIP"
			black_ops_button.disabled = false
	
	if cosmetic_data[Cosmetics.INCREDIBLE_GASSY]:
		if current_skin == Cosmetics.INCREDIBLE_GASSY:
			incredible_gassy_button.text = "EQUIPPED"
			incredible_gassy_button.disabled = true
		else:
			incredible_gassy_button.text = "EQUIP"
			incredible_gassy_button.disabled = false
	
	if cosmetic_data[Cosmetics.KAPPA]:
		if current_skin == Cosmetics.KAPPA:
			kappa_button.text = "EQUIPPED"
			kappa_button.disabled = true
		else:
			kappa_button.text = "EQUIP"
			kappa_button.disabled = false
	
	if cosmetic_data[Cosmetics.HEDGEHOG]:
		if current_skin == Cosmetics.HEDGEHOG:
			hedgehog_button.text = "EQUIPPED"
			hedgehog_button.disabled = true
		else:
			hedgehog_button.text = "EQUIP"
			hedgehog_button.disabled = false
	
	if cosmetic_data[Cosmetics.REDACTED]:
		if current_skin == Cosmetics.REDACTED:
			redacted_button.text = "EQUIPPED"
			redacted_button.disabled = true
		else:
			redacted_button.text = "EQUIP"
			redacted_button.disabled = false
	else:
		if show_redacted_amount:
			redacted_button.text = str(25000000)
		else:
			redacted_button.text = "???"

func display_offline_points_label() -> void:
	offline_points_label.text = "[outline_size=4][outline_color=black]You earned %s points while away!" % [int(offline_points)]
	offline_points_label.show()
	await get_tree().create_timer(2.0).timeout
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
		ppc_label.text = "[outline_size=4][outline_color=black]+%s" % [points_per_click]
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
		Cosmetics.DEFAULT:
			update_cosmetic(skin)
			cosmetic_data[Cosmetics.DEFAULT] = true
		Cosmetics.BLACK_OPS:
			if points >= int(black_ops_button.text):
				points -= int(black_ops_button.text)
				update_cosmetic(skin)
				cosmetic_data[Cosmetics.BLACK_OPS] = true
		Cosmetics.INCREDIBLE_GASSY:
			if points >= int(incredible_gassy_button.text):
				points -= int(incredible_gassy_button.text)
				update_cosmetic(skin)
				cosmetic_data[Cosmetics.INCREDIBLE_GASSY] = true
		Cosmetics.KAPPA:
			if points >= int(kappa_button.text):
				points -= int(kappa_button.text)
				update_cosmetic(skin)
				cosmetic_data[Cosmetics.KAPPA] = true
		Cosmetics.HEDGEHOG:
			if points >= int(hedgehog_button.text):
				points -= int(hedgehog_button.text)
				update_cosmetic(skin)
				cosmetic_data[Cosmetics.HEDGEHOG] = true
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
