extends Microgame

@export var bob_container: Button
@export var bob: AnimatedSprite2D

var stop: bool = false

func _ready() -> void:
	_setup()

func _on_node_2d_pressed() -> void:
	print("bob pressed")
	if stop: return
	stop = true
	
	bob.play()
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(bob_container.material, "shader_parameter/progress", 2, 2.0).from(-1.5)
	#tween.parallel().tween_property($Shadow, "self_modulate:a", 0.0, 1.0) what
	await tween.finished
	bob_container.queue_free()
	has_won(true)

func _on_game_ended():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
