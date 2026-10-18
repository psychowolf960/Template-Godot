extends Node
## Global signals, usable from any script.
## Emit:   Events.game_over.emit(true)
## Listen: Events.game_over.connect(_on_game_over)

@warning_ignore_start("unused_signal")

## Ends the game and shows the end screen. true = won, false = lost.
signal game_over(won: bool)
signal score_changed(score: int)

@warning_ignore_restore("unused_signal")
