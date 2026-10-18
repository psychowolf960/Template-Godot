extends CanvasLayer
## Scene changes with a fade to black.
## SceneManager.new_game()  # resets Global, then loads GAME
## SceneManager.change_scene("res://game/level_2.tscn")

const MAIN_MENU := "res://menus/main_menu.tscn"
const GAME := "res://game/game.tscn"
const END_SCREEN := "res://menus/end_screen.tscn"
const CREDITS := "res://menus/credits.tscn"

@export var fade_time := 0.3

## true during a scene change (used by the pause menu to ignore input).
var is_changing := false

var _fade := ColorRect.new()


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade.color = Color.BLACK
	_fade.modulate.a = 0.0
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_fade)


func change_scene(path: String) -> void:
	if is_changing:
		return
	is_changing = true
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade_to(1.0)
	var error := get_tree().change_scene_to_file(path)
	if error == OK:
		get_tree().paused = false
		await get_tree().scene_changed
	else:
		push_error("SceneManager: impossible de charger \"%s\" (%s)" % [path, error_string(error)])
	await _fade_to(0.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_changing = false


## Starts a new run: resets Global (score...) then loads the game scene.
func new_game() -> void:
	if is_changing:
		return
	Global.reset()
	change_scene(GAME)


func _fade_to(alpha: float) -> void:
	await create_tween().tween_property(_fade, "modulate:a", alpha, fade_time).finished
