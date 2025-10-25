extends Control

@onready var game_timer: Timer = $Timer
@onready var progress_bar: ProgressBar = $ProgressBar

var is_timer_stopped: bool = false
var update_progress: bool = false

func _ready() -> void:
	GameEvents.start_game.connect(_on_start_game)
	GameEvents.game_ended.connect(_on_game_ended)
	
	game_timer.wait_time = GameManager.current_game.time
	progress_bar.value = 100.0 # reset progress to 100%
	
	show_self()

func _process(_delta: float) -> void:
	var time_left = game_timer.time_left
	
	if update_progress:
		progress_bar.value = time_left / game_timer.wait_time * 100

func hide_self() -> void:
	var bar_to_pos = Vector2(progress_bar.position.x, progress_bar.position.y + 54)	
	var tween = get_tree().create_tween()
	tween.tween_property(progress_bar, "position", bar_to_pos, 0.3).set_trans(Tween.TRANS_SINE)
	await tween.finished
	
func show_self() -> void:
	var bar_to_pos = Vector2(progress_bar.position.x, progress_bar.position.y - 54)	
	var tween = get_tree().create_tween()
	tween.tween_property(progress_bar, "position", bar_to_pos, 0.5).set_trans(Tween.TRANS_SINE)
	await tween.finished
	
func _on_start_game() -> void:
	update_progress = true
	game_timer.start()

func _on_game_ended(_won: bool) -> void:
	is_timer_stopped = true
	game_timer.stop()
	
	await hide_self()
	queue_free()

func _on_timer_timeout() -> void:
	await hide_self()
	GameEvents.game_timer_ended.emit()
