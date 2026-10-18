extends Control
## Options overlay, opened from the main menu and the pause menu.

signal closed

@onready var _sliders := {
	&"Master": %MasterSlider,
	&"Music": %MusicSlider,
	&"SFX": %SfxSlider,
}


func _ready() -> void:
	for bus in _sliders:
		var slider: HSlider = _sliders[bus]
		slider.value = Settings.get_volume(bus)
		slider.value_changed.connect(func(value: float) -> void: Settings.set_volume(bus, value))
	%FullscreenCheck.button_pressed = Settings.is_fullscreen()
	for action in Settings.REMAPPABLE:
		var label := Label.new()
		label.text = Settings.REMAPPABLE[action]
		%Controls.add_child(label)
		for joypad in [false, true]:
			var button := RemapButton.new()
			button.action = action
			button.joypad = joypad
			%Controls.add_child(button)
	%MasterSlider.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func close() -> void:
	Settings.save()
	closed.emit()
	queue_free()


func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	Settings.set_fullscreen(toggled_on)


func _on_reset_button_pressed() -> void:
	Settings.reset_controls()
	get_tree().call_group(&"remap_buttons", &"update_text")


func _on_back_button_pressed() -> void:
	close()
