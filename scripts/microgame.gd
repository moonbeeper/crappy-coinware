extends Node
class_name Microgame

var action_prompt = preload("res://microgames/common/action_prompt.tscn")
var time_bar = preload("res://microgames/common/time_bar.tscn")
var background = preload("res://microgames/common/background.tscn")
var action_finished = preload("res://microgames/common/action_finished.tscn")

signal game_ended
var ihas_won = null
var game_started: bool = false
var finished_wait_timer: Timer
var force_win_on_timeout: bool = false

func _setup():
	GameManager.game_timer_finished.connect(_on_game_timer_finished)
	GameManager.game_can_start.connect(_on_game_can_start)
	GameManager.game_can_swap.connect(_on_game_can_swap)
	
	game_ended.connect(_on_game_ended)
	
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
	
func _on_game_timer_finished() -> void:
	print("game timer finished")
	await get_tree().create_timer(.5, true, false, true).timeout
	
	if !ihas_won:
		if force_win_on_timeout:
			GameManager.game_finished.emit(true)	
		else:
			GameManager.game_finished.emit(false)	
	game_ended.emit()
	
	finished_wait_timer.start()
	await finished_wait_timer.timeout

func _on_game_can_start() -> void:
	print("game can start now")
	game_started = true

func has_won(yup: bool):
	print("game has finished with a has_won of %s" % yup)
	ihas_won = yup
	GameManager.game_finished.emit(yup)
	game_ended.emit()
	
func _on_game_ended():
	pass

func _on_game_can_swap():
	go_to_scene()

func go_to_scene():
	SceneManager.swap_scene(GameManager.get_next_scene(), self)
