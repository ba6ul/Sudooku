extends Node2D

const MAIN_MENU = preload("res://scenes/MainMenu.tscn")
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

#func url_encode(text: String) -> String:
	#var encoded := ""
	#for c in text.to_utf8():
		#if (c >= 48 and c <= 57) or  # 0-9
		   #(c >= 65 and c <= 90) or  # A-Z
		   #(c >= 97 and c <= 122) or  # a-z
		   #c == 45 or c == 46 or c == 95 or c == 126:  # - . _ ~
			#encoded += char(c)
		#else:
			#encoded += "%%%02X" % c
	#return encoded


func _on_feedback_pressed() -> void:
	var email_address = "hibabulsingh@gmail.com"
	var subject = "Feedback Tada".uri_encode()
	
	# Gather system information
	#var resolution = DisplayServer.window_get_size()
	#var os_name = OS.get_name()
	#var os_version = OS.get_version()
	#var app_version = "v21"

	# Format the email body with system info
	var body = (
	"Feedback:\n\n---\nDevice Info:\n- Resolution: %s\n- OS: %s %s\n- App Version: %s" % [
		str(DisplayServer.window_get_size()),
		OS.get_name(),
		OS.get_version(),
		"v21"
	]
).uri_encode()
	
	
	
	# Create the mailto URL
	var email_url = "mailto:%s?subject=%s&body=%s" % [email_address, subject, body]
	
	# Open the default email client
	OS.shell_open(email_url)
