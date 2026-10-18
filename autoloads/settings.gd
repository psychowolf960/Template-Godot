extends Node
## Player settings (volume, fullscreen, controls), saved in user://settings.cfg.

const PATH := "user://settings.cfg"
const BUSES: Array[StringName] = [&"Master", &"Music", &"SFX"]
## Actions listed in Options > Controls, with their on-screen name.
## Add your own actions in Project Settings > Input Map, then here.
const REMAPPABLE := {
	&"move_up": "Haut",
	&"move_down": "Bas",
	&"move_left": "Gauche",
	&"move_right": "Droite",
	&"action": "Action",
}

var _config := ConfigFile.new()


func _ready() -> void:
	_config.load(PATH)
	for bus in BUSES:
		set_volume(bus, get_volume(bus))
	set_fullscreen(is_fullscreen())
	for action in REMAPPABLE:
		for joypad in [false, true]:
			if _config.has_section_key("controls", _key(action, joypad)):
				var event = _config.get_value("controls", _key(action, joypad))
				if event is InputEvent:
					_replace_event(action, joypad, event)


func save() -> void:
	_config.save(PATH)


func get_volume(bus: StringName) -> float:
	return _config.get_value("audio", bus, 1.0)


func set_volume(bus: StringName, linear: float) -> void:
	_config.set_value("audio", bus, linear)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(linear))


func is_fullscreen() -> bool:
	return _config.get_value("video", "fullscreen", false)


func set_fullscreen(value: bool) -> void:
	_config.set_value("video", "fullscreen", value)
	if value:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


## Keyboard key (joypad = false) or gamepad button (joypad = true) of an action.
func get_event(action: StringName, joypad: bool) -> InputEvent:
	for event in InputMap.action_get_events(action):
		if (event is InputEventJoypadButton and joypad) or (event is InputEventKey and not joypad):
			return event
	return null


## If another action already uses this key/button, the two actions swap.
func set_event(action: StringName, joypad: bool, event: InputEvent) -> void:
	var old := get_event(action, joypad)
	for other in REMAPPABLE:
		var other_event := get_event(other, joypad)
		if other != action and other_event and old and _same_input(other_event, event):
			_store_event(other, joypad, old)
	_store_event(action, joypad, event)
	save()


func reset_controls() -> void:
	InputMap.load_from_project_settings()
	if _config.has_section("controls"):
		_config.erase_section("controls")
	save()


func _store_event(action: StringName, joypad: bool, event: InputEvent) -> void:
	_replace_event(action, joypad, event)
	_config.set_value("controls", _key(action, joypad), event)


func _same_input(a: InputEvent, b: InputEvent) -> bool:
	if a is InputEventKey and b is InputEventKey:
		return a.physical_keycode == b.physical_keycode
	if a is InputEventJoypadButton and b is InputEventJoypadButton:
		return a.button_index == b.button_index
	return false


func _replace_event(action: StringName, joypad: bool, event: InputEvent) -> void:
	var old := get_event(action, joypad)
	if old:
		InputMap.action_erase_event(action, old)
	InputMap.action_add_event(action, event)


func _key(action: StringName, joypad: bool) -> String:
	return "%s_%s" % [action, "pad" if joypad else "key"]
