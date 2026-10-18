extends Control
## Shown after Events.game_over. Reads the result from Global.


func _ready() -> void:
	%Title.text = "Victoire !" if Global.won else "Perdu..."
	%Score.text = "Score : %d" % Global.score
	%RetryButton.grab_focus()


func _on_retry_button_pressed() -> void:
	SceneManager.new_game()


func _on_main_menu_button_pressed() -> void:
	SceneManager.change_scene(SceneManager.MAIN_MENU)
