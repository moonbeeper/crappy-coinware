extends Node 
class_name GameManagerNode

signal game_started
signal game_can_start
signal game_finished(has_won: bool)
signal game_timer_finished
signal game_can_swap
signal game_intermission_finished

signal gamepack_press(gamepack: GamePackResource)

enum TransitionType {SLIDE, FADE}

@export var max_hearts: int = 6
@export var game_pool: Array[MicrogameResource] = []
@export var game_packs: Array[GamePackResource] = []
var current_game: MicrogameResource
var game_won: bool = true

var current_hearts: int = 0
var has_lost_heart = false
var win_chain: int = 0
var game_round: int = 0
var is_speed_up: bool = false
var cached_gamepack_meta: Dictionary[GamePackResource, int] = {}
var save_data: SaveData = null
var current_game_pool: Array[MicrogameResource] = []

func _ready() -> void:
	game_finished.connect(_on_game_finished)
	game_intermission_finished.connect(_on_intermission_finished)
	current_hearts = max_hearts / 2
	save_data = SaveData.load_me()

func _on_game_finished(has_won: bool):
	game_won = has_won
	if !game_won:
		win_chain = 0
		has_lost_heart = true
		current_hearts -= 1
		print("game failed, lost a heart. the player now has %s" % current_hearts)
	else:
		win_chain_add()
	game_round += 1
	speeeeeeed()
	pick_random_game()

func get_random_game() -> MicrogameResource:
	if current_game_pool.is_empty():
		push_error("Somehow the microgame pool is empty")
		return null
	return current_game_pool.pick_random()

func pick_random_game() -> void:
	if current_game_pool.is_empty():
		push_error("Somehow the microgame pool is empty")
		return
	var game = current_game_pool.pick_random()
	current_game = game

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

func create_game_pool(pack_ids: Array[int]):
	print("creating new game pool for pack id(s): %s" % pack_ids)
	if pack_ids.is_empty():
		push_error("cannot create a game pool without any pack id(s)")
	for game in game_pool:
		if game.game_pack != null and game.game_pack.pack_id in pack_ids:
			current_game_pool.append(game)
	print("created a game pool with %s games" % current_game_pool.size())
	
	if current_game_pool.is_empty():
		push_error("sadly, we have a game pool without games smh")

func get_next_scene() -> String:
	print("choosing next scene")
	print("current hearts: %s" % current_hearts)
	if !game_won || is_speed_up:
		print("player has lost a heart or speedup, going to intermission")
		return "res://scenes/intermission.tscn"
	else:
		print("continuing the gaming")
		if current_game == null:
			push_error("current_game is null, going to intermission")
			return "res://scenes/intermission.tscn"

		return current_game.scene.resource_path

func _on_intermission_finished():
	game_won = true
	has_lost_heart = false
	is_speed_up = false
	pick_random_game()

func reset() -> void:
	current_hearts = max_hearts / 2
	has_lost_heart = false
	game_won = true
	current_game = null
	win_chain = 0
	game_round = 0
	is_speed_up = false
	Engine.time_scale = 1.0
	current_game_pool.clear()

func win_chain_add():
	win_chain += 1
	if win_chain % 3 == 0:
		NotificationManager.show_notification("[wave amp=50.0 freq=5.0 connected=1]You Are On [color=#f3c96a]Fire![/color] %s Wins In a Row![/wave]" % win_chain)
	if win_chain % 12 == 0 and current_hearts < max_hearts:
		current_hearts += 1
		NotificationManager.show_notification("[wave amp=50.0 freq=5.0 connected=1]You Obtained a [color=#f3c96a]Heart![/color][/wave]")
	elif win_chain % 12 == 9: 
		NotificationManager.show_notification("[wave amp=50.0 freq=5.0 connected=1]3 More To Get a [color=#f3c96a]Heart![/color][/wave]")

func speeeeeeed():
	if game_round % 4 == 0:
		print("making faster the engine timescale by 0.2")
		Engine.time_scale += .2
		print("the current engine timescale is %s" % Engine.time_scale)
		is_speed_up = true
		
