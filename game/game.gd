extends Node
## Main gameplay scene: build your game here (add a Node2D or Node3D child).
## End the game from any script with: Events.game_over.emit(true)  # true = won

@export var music: AudioStream


func _ready() -> void:
	# One shot: if game_over is emitted twice, only the first result counts.
	Events.game_over.connect(_on_game_over, CONNECT_ONE_SHOT)
	if music:
		Audio.play_music(music)


func _on_game_over(won: bool) -> void:
	Global.won = won
	SceneManager.change_scene(SceneManager.END_SCREEN)
