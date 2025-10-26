extends Microgame

@export var pipes: Node2D
@export var coin_rigid: RigidBody2D

const target_score: int = 3
var current_score: int = 0
var should_stop: bool = false
var already_unfrozen: bool = false


# ah, so simple
func _ready() -> void:
	_setup()
	#should_win_on_timeout = true
	
func _input(event) -> void:
	# any key, any click 
	if !game_started: return
	if event is InputEventKey and event.pressed and not event.echo:
		coin_rigid.apply_central_impulse(Vector2(0, -400))
	if event is InputEventMouseButton and event.pressed:
		coin_rigid.apply_central_impulse(Vector2(0, -400))

func _physics_process(_delta: float) -> void:
	if !game_started: return
	if should_stop: return 
	coin_rigid.set_rotation(deg_to_rad(coin_rigid.linear_velocity.y * 0.05))
	if coin_rigid.linear_velocity.y > 600:
		coin_rigid.linear_velocity.y = 600
	if current_score == 3:
		should_stop = true
		has_won(true)
		print("WIN")
		explode_coin()

func _on_pipe_pipe_scored() -> void:
	current_score += 1

func _on_pipe_pipe_touched() -> void:
	if should_stop: return
	for pipe in pipes.get_children():
		var typed = pipe as FlappyCoinPipe
		typed.stop_moving = true
		
	has_won(false)
	print("FAIL")
	should_stop = true
	
func explode_coin():
	coin_rigid.freeze = false
	coin_rigid.apply_impulse(Vector2(100, -500))
		
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	coin_rigid.queue_free()
	
func _on_game_started() -> void:
	coin_rigid.freeze = false
	for pipe in pipes.get_children():
		var typed = pipe as FlappyCoinPipe
		typed.stop_moving = false
