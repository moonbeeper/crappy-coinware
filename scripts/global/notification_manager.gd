extends Control

var notification_scene = preload("res://nodes/notification.tscn")

func show_notification(bbcode: String) -> void:
	var instance = notification_scene.instantiate() as NotificationBasic
	add_child(instance)
	instance.modulate = Color(1,1,1,0)
	
	instance.setLabel(bbcode)
	
	var enter_tween = get_tree().create_tween()
		
	enter_tween.tween_property(instance, "position", Vector2(12.0+8.0, 8), .7).from(Vector2(-instance.label.size.x-12.0, 8)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	enter_tween.parallel().tween_property(instance, "modulate", Color(1,1,1,1), .7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await enter_tween.finished
	
	await get_tree().create_timer(2).timeout
	
	var exit_tween = get_tree().create_tween()
	exit_tween.tween_property(instance, "position", Vector2(900+370 + instance.size.x, 8), .7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await exit_tween.finished
	
	instance.queue_free()
	return
