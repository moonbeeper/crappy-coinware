extends Control

@onready var timer: Timer = $Timer
@onready var label: RichTextLabel = $Label

func _ready() -> void:
	timer.wait_time = GameManager.current_game.action_prompt_shown_for
	timer.start()
	var text = GameManager.current_game.action_prompt
	text.capitalize()
	label.text = text
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), .5).from(Vector2(5,5)).set_trans(Tween.TRANS_BOUNCE)
	await tween.finished
	
func _on_timer_timeout() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(label, "scale", Vector2(0,0), 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0), 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	GameManager.game_can_start.emit()
	queue_free()
	
