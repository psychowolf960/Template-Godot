class_name RemapButton
extends Button
## Click, then press a key (or a gamepad button) to rebind the action.
## Escape (or a press on the other device) cancels.

const PAD_NAMES := {
	JOY_BUTTON_A: "A", JOY_BUTTON_B: "B", JOY_BUTTON_X: "X", JOY_BUTTON_Y: "Y",
	JOY_BUTTON_BACK: "Select", JOY_BUTTON_START: "Start",
	JOY_BUTTON_LEFT_STICK: "L3", JOY_BUTTON_RIGHT_STICK: "R3",
	JOY_BUTTON_LEFT_SHOULDER: "LB", JOY_BUTTON_RIGHT_SHOULDER: "RB",
	JOY_BUTTON_DPAD_UP: "Croix ↑", JOY_BUTTON_DPAD_DOWN: "Croix ↓",
	JOY_BUTTON_DPAD_LEFT: "Croix ←", JOY_BUTTON_DPAD_RIGHT: "Croix →",
}

var action: StringName
var joypad := false


func _ready() -> void:
	toggle_mode = true
	custom_minimum_size.x = 180
	add_to_group(&"remap_buttons")
	toggled.connect(_on_toggled)
	update_text()


func update_text() -> void:
	var event := Settings.get_event(action, joypad)
	if event is InputEventKey:
		text = OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode))
	elif event is InputEventJoypadButton:
		text = PAD_NAMES.get(event.button_index, "Bouton %d" % event.button_index)
	else:
		text = "—"


func _on_toggled(listening: bool) -> void:
	if listening:
		text = "Appuie sur un bouton..." if joypad else "Appuie sur une touche..."
	else:
		update_text()


func _input(event: InputEvent) -> void:
	if not button_pressed or not event.is_pressed() or event.is_echo():
		return
	if not (event is InputEventKey or event is InputEventJoypadButton):
		return
	# Escape, or a press on the other device (keyboard vs gamepad), cancels.
	if joypad and event is InputEventJoypadButton:
		var new_event := InputEventJoypadButton.new()
		new_event.device = -1
		new_event.button_index = event.button_index
		Settings.set_event(action, true, new_event)
	elif not joypad and event is InputEventKey and event.physical_keycode != KEY_ESCAPE:
		var new_event := InputEventKey.new()
		new_event.device = -1
		new_event.physical_keycode = event.physical_keycode
		Settings.set_event(action, false, new_event)
	get_viewport().set_input_as_handled()
	button_pressed = false
	# Refresh all buttons: another action may have swapped with this one.
	get_tree().call_group(&"remap_buttons", &"update_text")
