extends Control
## Demo only: delete the Placeholder node once your game exists.


func _ready() -> void:
	Events.score_changed.connect(_on_score_changed)
	_on_score_changed(Global.score)
	%WinButton.grab_focus()


func _on_score_changed(score: int) -> void:
	%ScoreLabel.text = "Score : %d" % score


func _on_score_button_pressed() -> void:
	Global.score += 10


func _on_win_button_pressed() -> void:
	Events.game_over.emit(true)


func _on_lose_button_pressed() -> void:
	Events.game_over.emit(false)
