extends Node
## Music (with fade) and sound effects.
## Audio.play_music(preload("res://assets/music/theme.ogg"))
## Audio.play_sfx(preload("res://assets/sfx/jump.wav"))
## Audio.play_sfx(HIT_SOUND, 0.1)  # random pitch +/- 10%
## Every button in the game plays the UI sounds automatically.

const SFX_VOICES := 16
const FADE_TIME := 0.5
const SILENT_DB := -40.0
const UI_FOCUS := preload("res://assets/sfx/ui/ui_focus.ogg")
const UI_PRESS := preload("res://assets/sfx/ui/ui_press.ogg")
const UI_NAVIGATION: Array[StringName] = [
	&"ui_up", &"ui_down", &"ui_left", &"ui_right", &"ui_focus_next", &"ui_focus_prev",
]

var _music := AudioStreamPlayer.new()
var _music_tween: Tween
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music.bus = &"Music"
	add_child(_music)
	for i in SFX_VOICES:
		var player := AudioStreamPlayer.new()
		player.bus = &"SFX"
		add_child(player)
		_sfx_players.append(player)
	get_tree().node_added.connect(_on_node_added)


func play_music(stream: AudioStream) -> void:
	if _music.stream == stream and _music.playing:
		return
	_fade_music_to(stream)


func stop_music() -> void:
	_fade_music_to(null)


func play_sfx(stream: AudioStream, pitch_variation := 0.0) -> void:
	var player := _sfx_players[_next_sfx]
	_next_sfx = (_next_sfx + 1) % SFX_VOICES
	player.stream = stream
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	player.play()


func _on_node_added(node: Node) -> void:
	if not (node is Control) or node.focus_entered.is_connected(_on_ui_focus_entered):
		return
	node.focus_entered.connect(_on_ui_focus_entered)
	if node is BaseButton:
		node.mouse_entered.connect(_on_button_hovered.bind(node))
		node.pressed.connect(play_sfx.bind(UI_PRESS))


func _on_ui_focus_entered() -> void:
	# Only when the player moves the focus, not when a menu opens (grab_focus).
	for action in UI_NAVIGATION:
		if Input.is_action_just_pressed(action):
			play_sfx(UI_FOCUS)
			return


func _on_button_hovered(button: BaseButton) -> void:
	if not button.disabled:
		play_sfx(UI_FOCUS)


func _fade_music_to(stream: AudioStream) -> void:
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	if _music.playing:
		_music_tween.tween_property(_music, "volume_db", SILENT_DB, FADE_TIME)
	_music_tween.tween_callback(_switch_music.bind(stream))
	if stream:
		_music_tween.tween_property(_music, "volume_db", 0.0, FADE_TIME)


func _switch_music(stream: AudioStream) -> void:
	_music.stop()
	_music.stream = stream
	_music.volume_db = SILENT_DB
	if stream:
		_music.play()
