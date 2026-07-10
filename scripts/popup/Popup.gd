extends CanvasLayer

class_name Popup

@export var animation_duration: float = 0.3

## UI References (should be set up in the scene)
@onready var background: Panel = $Background
@onready var container: VBoxContainer = $Container
@onready var title_label: Label = $Container/Title
@onready var content_area: PanelContainer = $Container/ContentArea
@onready var content_vbox: VBoxContainer = $Container/ContentArea/VBoxContainer
@onready var button_area: HBoxContainer = $Container/ButtonArea
@onready var primary_button: Button = $Container/ButtonArea/PrimaryButton
@onready var secondary_button: Button = $Container/ButtonArea/SecondaryButton

var config: PopupConfig
var tween: Tween

func _ready() -> void:
	## Set up background click-to-dismiss
	background.gui_input.connect(_on_background_clicked)
	
	## Button connections
	primary_button.pressed.connect(_on_primary_pressed)
	secondary_button.pressed.connect(_on_secondary_pressed)
	
	## Start hidden
	modulate.a = 0.0

## Configure and show the popup
func configure(new_config: PopupConfig) -> void:
	config = new_config
	
	## Apply title and colors
	title_label.text = config.title
	title_label.modulate = config.title_color
	
	## Clear previous content
	for child in content_vbox.get_children():
		child.queue_free()
	
	## Render content based on type
	match config.content_type:
		PopupConfig.ContentType.FEATURE_LIST:
			_render_feature_list()
		PopupConfig.ContentType.SIMPLE_TEXT:
			_render_simple_text()
		PopupConfig.ContentType.TEXT_WITH_TOGGLE:
			_render_text_with_toggle()
	
	## Configure buttons
	_setup_buttons()
	
	## Animate in
	show_popup()

## ====== Content Renderers ======

func _render_feature_list() -> void:
	## Scrollable list of features with icons
	var scroll_container = ScrollContainer.new()
	scroll_container.custom_minimum_size = Vector2(400, 250)
	
	var vbox = VBoxContainer.new()
	vbox.separation = 12
	
	for feature in config.features:
		var feature_row = _create_feature_row(feature)
		vbox.add_child(feature_row)
	
	scroll_container.add_child(vbox)
	content_vbox.add_child(scroll_container)

func _create_feature_row(feature: Dictionary) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.separation = 12
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	
	## Icon
	var icon_label = Label.new()
	icon_label.text = feature.get("icon", "•")
	icon_label.custom_minimum_size.x = 30
	icon_label.modulate = config.accent_color
	row.add_child(icon_label)
	
	## Title + Description
	var text_vbox = VBoxContainer.new()
	text_vbox.separation = 2
	
	var title = Label.new()
	title.text = feature.get("title", "Feature")
	title.modulate = config.title_color
	title.add_theme_font_size_override("font_size", 16)
	text_vbox.add_child(title)
	
	if feature.get("desc", "") != "":
		var desc = Label.new()
		desc.text = feature.get("desc", "")
		desc.modulate = Color(0.8, 0.8, 0.8)
		desc.add_theme_font_size_override("font_size", 12)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD
		text_vbox.add_child(desc)
	
	row.add_child(text_vbox)
	return row

func _render_simple_text() -> void:
	var message_label = Label.new()
	message_label.text = config.message
	message_label.modulate = config.text_color
	message_label.add_theme_font_size_override("font_size", 14)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	message_label.custom_minimum_size = Vector2(400, 0)
	content_vbox.add_child(message_label)

func _render_text_with_toggle() -> void:
	## Simple text + checkbox
	_render_simple_text()
	
	var hbox = HBoxContainer.new()
	var checkbox = CheckButton.new()
	checkbox.text = config.toggle_label
	hbox.add_child(checkbox)
	content_vbox.add_child(hbox)

## ====== Button Setup ======

func _setup_buttons() -> void:
	primary_button.text = config.primary_button_text
	primary_button.modulate = config.accent_color
	
	if config.secondary_button_text != "":
		secondary_button.text = config.secondary_button_text
		secondary_button.show()
	else:
		secondary_button.hide()

## ====== Callbacks ======

func _on_primary_pressed() -> void:
	config.on_primary.call()
	hide_popup()

func _on_secondary_pressed() -> void:
	config.on_secondary.call()
	hide_popup()

func _on_background_clicked(event: InputEvent) -> void:
	if config.close_on_background_click and event is InputEventMouseButton:
		if event.pressed:
			config.on_close.call()
			hide_popup()

## ====== Animation ======

func show_popup() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, animation_duration)

func hide_popup() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, animation_duration)
	await tween.finished
	queue_free()  ## Remove from scene after hiding
