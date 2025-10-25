extends Node
@warning_ignore_start("unused_signal")

signal game_state_shown ## If the Check or X has been shown. In practise, its a "game can start now"
signal start_game ## If the game has started. Makes the game time tick (time bar).
signal game_ended(won: bool) ## If the game has ended with a win or lose state
## If the game timer has ended. Only called if the game_ended signal wasn't called before
signal game_timer_ended
signal gamepack_pressed(gamepack: GamePackResource) ## Called when a gamepack is pressed
