extends Node
class_name Microgame

var action_prompt = preload("res://minigames/common/action_prompt.tscn")
var time_bar = preload("res://minigames/common/time_bar.tscn")
var background = preload("res://minigames/common/background.tscn")
var action_finished = preload("res://minigames/common/action_finished.tscn")

signal game_ended
signal game_started

var has_game_started: bool = false
var finished_wait_timer: Timer
var should_win_on_timeout: bool = false
var should_ignore_new_win: bool = false

func _setup() -> void:
	GameEvents.game_timer_ended.connect(_on_game_timer_ended)
	GameEvents.start_game.connect(_on_start_game)
	
	GameEvents.game_state_shown.connect(_on_game_state_shown)
	
	game_ended.connect(_on_game_ended)
	game_started.connect(_on_game_started)
	
	finished_wait_timer = Timer.new()
	finished_wait_timer.wait_time = 1 
	finished_wait_timer.one_shot = true
	add_child(finished_wait_timer)
	
	var action_child = action_prompt.instantiate()
	add_child(action_child)
	
	var time_child = time_bar.instantiate()
	add_child(time_child)
	
	var background_child = background.instantiate()
	add_child(background_child)
	
	var finished_child = action_finished.instantiate()
	add_child(finished_child)
	
func _on_game_timer_ended() -> void:
	should_ignore_new_win = true
	print("The game timer has finished. Choosing to end the game as win or lose")
	await get_tree().create_timer(.5, true, false, true).timeout
	
	if should_win_on_timeout:
		GameEvents.game_ended.emit(true)
	else:
		GameEvents.game_ended.emit(false)
	game_ended.emit()
	
	finished_wait_timer.start()
	await finished_wait_timer.timeout

func _on_start_game() -> void:
	print("Game started, setting game_started var")
	has_game_started = true
	game_started.emit()

func has_won(state: bool):
	if should_ignore_new_win: return
	print("game has finished with a has_won of %s" % state)
	GameEvents.game_ended.emit(state)
	game_ended.emit()
	
func _on_game_ended() -> void:
	pass

func _on_game_state_shown() -> void:
	swap_to_next_game()

func swap_to_next_game() -> void:
	SceneManager.swap_scene(GameManager.get_next_scene(), self)

func _on_game_started() -> void:
	pass
