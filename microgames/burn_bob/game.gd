extends Microgame

@export var bob_container: Button
@export var bob: AnimatedSprite2D

var stop: bool = false

func _ready() -> void:
	_setup()
	
	#randomize()
	#
	#pick_random()
	#
#func pick_random() -> void:
	#var index = randi() % path2ds.size()
	#var path = path2ds[index]
	#follow_line.target_path = path
	#sprite.frame = index
	#
#func _on_game_can_start() -> void:
	#print("game can now start, signaling follow the line script")
	#follow_line.start.emit()
	#
#func _on_follow_the_line_finished_drawing() -> void:
	#has_won(true)


func _on_node_2d_pressed() -> void:
	print("bob pressed")
	if stop: return
	stop = true
	
	bob.play()
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(bob_container.material, "shader_parameter/progress", 2, 2.0).from(-1.5)
	tween.parallel().tween_property($Shadow, "self_modulate:a", 0.0, 1.0)
	await tween.finished
	bob_container.queue_free()

func _on_game_ended():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
