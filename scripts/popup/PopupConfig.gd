## PopupConfig.gd
## Lightweight data class for configuring any popup dynamically
## Usage: Create instance, set properties, pass to PopupManager.show_popup()

class_name PopupConfig

## Content type determines how the popup renders its body
enum ContentType {
	FEATURE_LIST,      ## Bulleted list of features (first launch)
	SIMPLE_TEXT,       ## Plain text message (exit confirm, alerts)
	TEXT_WITH_TOGGLE,  ## Text + checkbox (future: "don't show again")
}

## ====== Core Configuration ======
var title: String = ""
var content_type: ContentType = ContentType.SIMPLE_TEXT
var primary_button_text: String = "OK"
var secondary_button_text: String = ""  ## Empty = hidden
var close_on_background_click: bool = true

## ====== Content Data ======
var message: String = ""  ## For SIMPLE_TEXT
var features: Array[Dictionary] = []  ## For FEATURE_LIST: [{icon: "✨", title: "Auto Save", desc: ""}]
var toggle_label: String = ""  ## For TEXT_WITH_TOGGLE

## ====== Callbacks ======
var on_primary: Callable = func(): pass
var on_secondary: Callable = func(): pass
var on_close: Callable = func(): pass

## Optional: Custom styling
var title_color: Color = Color.WHITE
var text_color: Color = Color.WHITE
var accent_color: Color = Color(0.3, 0.7, 1.0)  ## Default blue

## ====== Helper Methods ======

## Create first-launch popup config
static func first_launch(on_done: Callable) -> PopupConfig:
	var config = PopupConfig.new()
	config.title = "What's New"
	config.content_type = ContentType.FEATURE_LIST
	config.primary_button_text = "Got it"
	config.on_primary = on_done
	config.close_on_background_click = true
	return config

## Create exit confirmation popup config
static func exit_confirm(on_confirm: Callable, on_cancel: Callable) -> PopupConfig:
	var config = PopupConfig.new()
	config.title = "Hold up!"
	config.message = "Are you sure you want to exit?"
	config.content_type = ContentType.SIMPLE_TEXT
	config.primary_button_text = "Exit"
	config.secondary_button_text = "Keep Playing"
	config.on_primary = on_confirm
	config.on_secondary = on_cancel
	config.close_on_background_click = false  ## User must choose
	return config

## Create simple alert popup
static func alert(title: String, message: String, on_dismiss: Callable) -> PopupConfig:
	var config = PopupConfig.new()
	config.title = title
	config.message = message
	config.content_type = ContentType.SIMPLE_TEXT
	config.primary_button_text = "OK"
	config.on_primary = on_dismiss
	return config

## Create warning popup
static func warning(title: String, message: String, on_confirm: Callable) -> PopupConfig:
	var config = PopupConfig.new()
	config.title = title
	config.message = message
	config.content_type = ContentType.SIMPLE_TEXT
	config.primary_button_text = "I Understand"
	config.on_primary = on_confirm
	config.accent_color = Color(1.0, 0.4, 0.2)  ## Orange warning
	return config
