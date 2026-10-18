extends Node
## Variables shared between scenes during a run (not saved to disk).
## Global.score += 10

var score := 0:
	set(value):
		score = value
		Events.score_changed.emit(score)
var won := false


## Called by SceneManager.new_game() (Play, Retry, Restart), not between levels.
func reset() -> void:
	score = 0
	won = false
