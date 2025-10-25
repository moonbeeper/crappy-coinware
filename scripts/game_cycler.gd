extends Node
class_name GameCycler

var game_pool: Array[MicrogameResource] = []
var games_left: Array[MicrogameResource] = []
var last_game: MicrogameResource = null
var should_loop: bool = false

func _init(games: Array[MicrogameResource], loop: bool) -> void:
	game_pool = games.duplicate()
	should_loop = loop
	reset_games_left()

func reset_games_left() -> void:
	games_left = game_pool.duplicate()
	games_left.shuffle()

func next_game() -> MicrogameResource:
	if games_left.is_empty():
		if should_loop:
			reset_games_left()
			print(games_left.size())
			if last_game && games_left.size() > 1:
				while games_left[0] == last_game:
					games_left.shuffle()

	var next = games_left[0]
	games_left.pop_front()
	last_game = next
	return next
				
