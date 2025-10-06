extends Control

@onready var timer: Timer = $Timer
@onready var progress: ProgressBar = $ProgressBar

var timer_stopped = false
var timer_time_left = 0.0
var game_started: bool = false

func _ready() -> void:
	GameManager.game_can_start.connect(_on_game_can_start)
	GameManager.game_finished.connect(_on_game_finished)
	timer.wait_time = GameManager.current_game.time
	progress.value = 100.0

	var bar_to_pos = Vector2(progress.position.x, progress.position.y - 54)	
	var tween = get_tree().create_tween()
	tween.tween_property(progress, "position", bar_to_pos, 0.5).set_trans(Tween.TRANS_SINE)

func _process(_delta: float) -> void:
	var time_left = timer.time_left
	if timer_stopped:
		time_left = timer_time_left
	if game_started:
		progress.value = time_left / timer.wait_time * 100

func _on_timer_timeout() -> void:
	await go_down()

	GameManager.game_timer_finished.emit()

func go_down() -> void:
	var bar_to_pos = Vector2(progress.position.x, progress.position.y + 54)	
	var tween = get_tree().create_tween()
	tween.tween_property(progress, "position", bar_to_pos, 0.3).set_trans(Tween.TRANS_SINE)
	await tween.finished

func _on_game_can_start() -> void:
	timer.start()
	game_started = true

func _on_game_finished(_has_won: bool) -> void:
	timer_stopped = true
	timer_time_left = timer.time_left
	timer.stop()
	
	await go_down()
	queue_free()
