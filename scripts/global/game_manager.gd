extends Node 
class_name GameManagerNode

# REMOVE ME
#signal game_can_start
#signal game_finished(has_won: bool)
#signal game_timer_finished
#signal game_can_swap
#signal gamepack_press(gamepack: GamePackResource)

signal game_intermission_finished

enum TransitionType {SLIDE, FADE}

@export var max_hearts: int = 6
@export var game_pool: Array[MicrogameResource] = []
@export var game_packs: Array[GamePackResource] = []
@export var base_points: int = 100
@export var round_point_multiplier: float = 0.1
@export var increase_speed_every: int = 5

var game_cycler: GameCycler = null

var game_won: bool = true
var current_hearts: int = 0
var has_lost_heart = false
var win_chain: int = 0
var game_round: int = 0
var has_speed_increased: bool = false
var current_score: int = 0
var current_game_pack_ids: Array[int] = []
var current_game_pool: Array[MicrogameResource] = []
var current_game: MicrogameResource = null
var current_speed_counter: int = 0

var cached_gamepack_meta: Dictionary[GamePackResource, int] = {}

func _ready() -> void:
	GameEvents.game_ended.connect(_on_game_ended)
	game_intermission_finished.connect(_on_intermission_finished)
	current_hearts = roundi(max_hearts / 2.0)

func _on_game_ended(has_won: bool) -> void:
	game_won = has_won
	if !game_won:
		if current_hearts != 0: 
			win_chain = 0
			has_lost_heart = true
			current_hearts -= 1 
			print("game failed, lost a heart. the player now has %s" % current_hearts)
		else:
			print("player died, saving scores")
			if !current_game_pack_ids.is_empty():
				SaveDataManager.add_score(current_game_pack_ids, current_score, win_chain)
			else:
				print("Somehow the player has failed a game session without any gamepacks... Failed to save")
	else:
		current_score += calculate_score()
		win_chain_add()
		game_round += 1
		current_speed_counter += 1
		if current_speed_counter >= increase_speed_every:
			increase_speed()
			current_speed_counter = 0

func _pick_random_game() -> MicrogameResource:
	if !game_cycler:
		print("Somehow the GameCycler wasn't created upto this point")
		return null
		
	var game = game_cycler.next_game()
	current_game = game
	
	return game

func get_game_packs() -> Dictionary[GamePackResource, int]:
	var pack_counts: Dictionary[GamePackResource, int] = {}
	for pack in game_packs:
		print("found GAMEPACK: %s" % pack.display_name)
		pack_counts[pack] = 0
	for game in game_pool:
		if game.game_pack == null || !game_packs.has(game.game_pack):
			pack_counts[game_packs[0]] += 1
		else:
			pack_counts[game.game_pack] += 1
		
	cached_gamepack_meta = pack_counts
	return cached_gamepack_meta

func create_game_pool(pack_ids: Array[int]) -> void:
	print("Creating new game pool for pack id(s): %s" % pack_ids)
	current_game_pack_ids = pack_ids
	current_game_pool.clear()
	
	if pack_ids.is_empty():
		push_error("cannot create a game pool without any pack id(s)")
	
	for game in game_pool:
		if game.game_pack != null and game.game_pack.pack_id in pack_ids:
			current_game_pool.append(game)
	print("created a game pool with %s games" % current_game_pool.size())
	
	if current_game_pool.is_empty():
		push_error("sadly, we have a game pool without games smh")
	
	game_cycler = GameCycler.new(current_game_pool, true)

func get_next_scene() -> String:
	print("Choosing next scene")
	print("Current hearts: %s" % current_hearts)
	
	if !game_won || has_speed_increased:
		print("player has lost a heart or speedup, going to intermission")
		return "res://scenes/intermission.tscn"
	else:
		var next_game = _pick_random_game()
		print("continuing the gaming")
		print(next_game)
		if next_game == null:
			push_error("current_game is null, going to intermission")
			return "res://scenes/intermission.tscn"

		return next_game.scene.resource_path

func _on_intermission_finished() -> void:
	game_won = true # must be set to true or else the next scene will be always the intermission
	
	has_lost_heart = false
	has_speed_increased = false

func reset() -> void:
	print("Resetting game manager state")
	current_hearts = roundi(max_hearts / 2.0)
	has_lost_heart = false
	game_won = true
	win_chain = 0
	game_round = 0
	has_speed_increased = false
	Engine.time_scale = 1.0
	current_game_pool.clear()
	current_game = null
	if game_cycler:
		game_cycler.reset_games_left()

func win_chain_add() -> void:
	win_chain += 1
	if win_chain % 3 == 0:
		NotificationManager.show_notification("[wave amp=50.0 freq=5.0 connected=1]You Are On [color=#f3c96a]Fire![/color] %s Wins In a Row![/wave]" % win_chain)
	if win_chain % 12 == 0 and current_hearts < max_hearts:
		current_hearts += 1
		NotificationManager.show_notification("[wave amp=50.0 freq=5.0 connected=1]You Obtained a [color=#f3c96a]Heart![/color][/wave]")
	elif win_chain % 12 == 9: 
		NotificationManager.show_notification("[wave amp=50.0 freq=5.0 connected=1]3 More To Get a [color=#f3c96a]Heart![/color][/wave]")

func increase_speed() -> void:
	print("making faster the engine timescale by 0.2")
	Engine.time_scale += .1
	print("the current engine timescale is %s" % Engine.time_scale)
	has_speed_increased = true

func calculate_score() -> int:
	var round_multiplier = 1.0 + (game_round * 0.1)
	var combo_bonus = 0
	
	if win_chain >= 3:
		combo_bonus = win_chain * 50
	var heart_bonus = current_hearts * 25
	var total_points = int((base_points * round_multiplier * Engine.time_scale) + combo_bonus + heart_bonus)
	print("the current score is %s" % total_points)
	
	return total_points
