extends Control

const OPTIONS_MENU := preload("res://menus/options_menu.tscn")

@export var music: AudioStream


func _ready() -> void:
	%Title.text = ProjectSettings.get_setting("application/config/name")
	%QuitButton.visible = not OS.has_feature("web")  # quit() does nothing in a browser
	if music:
		Audio.play_music(music)
	%PlayButton.grab_focus()


func _on_play_button_pressed() -> void:
	SceneManager.new_game()


func _on_options_button_pressed() -> void:
	var options := OPTIONS_MENU.instantiate()
	options.closed.connect(%OptionsButton.grab_focus)
	add_child(options)


func _on_credits_button_pressed() -> void:
	SceneManager.change_scene(SceneManager.CREDITS)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
