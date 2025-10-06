extends Node

signal game_started
signal game_can_start
signal game_finished(has_won: bool)
signal game_timer_finished
signal game_can_swap
signal game_intermission_finished

enum TransitionType {SLIDE, FADE}

@export var max_hearts: int = 6
@export var game_pool: Array[MicrogameResource] = []
var current_game: MicrogameResource
var game_won: bool = true

var current_hearts: int = 0
var has_lost_heart = false
var win_chain: int = 0
var game_round: int = 0
var is_speed_up: bool = false

func _ready() -> void:
	game_finished.connect(_on_game_finished)
	game_intermission_finished.connect(_on_intermission_finished)
	current_hearts = max_hearts / 2
	#NotificationManager.show_notification("bbcode!")

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
	if game_pool.is_empty():
		push_error("Somehow the microgame pool is empty")
		return null
	return game_pool.pick_random()

func pick_random_game() -> void:
	if game_pool.is_empty():
		push_error("Somehow the microgame pool is empty")
		return
	var game = game_pool.pick_random()
	current_game = game

func get_next_scene() -> String:
	print("choosing next scene")
	print("current hearts: %s" % current_hearts)
	if !game_won || is_speed_up:
		print("player has lost a heart or speedup, going to intermission")
		return "res://scenes/intermission.tscn"
	else:
		print("continuing the gaming")
		return current_game.scene.resource_path

func _on_intermission_finished():
	game_won = true
	has_lost_heart = false
	pick_random_game()

func reset() -> void:
	current_hearts = max_hearts / 2
	has_lost_heart = false
	game_won = true
	current_game = null
	Engine.time_scale = 1.0

func win_chain_add():
	win_chain += 1
	if win_chain % 3 == 0:
		NotificationManager.show_notification("[wave amp=50.0 freq=5.0 connected=1]You Are On [color=#f3c96a]Fire![/color] %s Wins In a Row![/wave]" % win_chain)
	if win_chain % 12 == 0 and current_hearts < max_hearts:
		current_hearts += 1
		NotificationManager.show_notification("[wave amp=50.0 freq=5.0 connected=1]You Regained a [color=#f3c96a]Heart![/color][/wave]")
	elif win_chain % 12 == 9: 
		NotificationManager.show_notification("[wave amp=50.0 freq=5.0 connected=1]3 More To Get a [color=#f3c96a]Heart![/color][/wave]")

func speeeeeeed():
	if game_round % 4 == 0:
		print("GOING UP SPEEED")
		Engine.time_scale += .2
		print(Engine.time_scale)
		is_speed_up = true
		
