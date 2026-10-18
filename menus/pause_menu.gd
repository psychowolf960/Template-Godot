extends CanvasLayer
## Add this scene to any gameplay scene.
## "pause" (Escape / Start) opens and closes it.

const OPTIONS_MENU := preload("res://menus/options_menu.tscn")

var _options_open := false


func _ready() -> void:
	hide()
	%QuitButton.visible = not OS.has_feature("web")  # quit() does nothing in a browser


func _unhandled_input(event: InputEvent) -> void:
	if _options_open or SceneManager.is_changing:
		return
	if event.is_action_pressed(&"pause") or (visible and event.is_action_pressed(&"ui_cancel")):
		get_viewport().set_input_as_handled()
		set_paused(not visible)


func set_paused(paused: bool) -> void:
	visible = paused
	get_tree().paused = paused
	if paused:
		%ResumeButton.grab_focus()


func _on_resume_button_pressed() -> void:
	set_paused(false)


func _on_options_button_pressed() -> void:
	var options := OPTIONS_MENU.instantiate()
	options.closed.connect(_on_options_closed)
	_options_open = true
	add_child(options)


func _on_options_closed() -> void:
	_options_open = false
	%OptionsButton.grab_focus()


func _on_restart_button_pressed() -> void:
	SceneManager.new_game()


func _on_main_menu_button_pressed() -> void:
	SceneManager.change_scene(SceneManager.MAIN_MENU)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
