extends Control

@onready var hover: Panel = $Hover
@onready var selected: Panel = $Selected

var tween: Tween
var select_tween: Tween
var double_click: Timer
var mouse_over: bool = false

signal open_app

func _ready() -> void:
	hover.self_modulate = Color(1,1,1,0)
	double_click = Timer.new()
	double_click.wait_time = 0.2
	double_click.one_shot = true
	double_click.ignore_time_scale = true
	add_child(double_click)

func _on_mouse_entered() -> void:
	mouse_over = true
	if tween && tween.is_running():
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(hover, "self_modulate", Color(1,1,1,1), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _on_mouse_exited() -> void:
	mouse_over = false
	if tween && tween.is_running():
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(hover, "self_modulate", Color(1,1,1,0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)


func _on_pressed() -> void:
	if mouse_over:
		selected.visible = true
		if !double_click.is_stopped():
			print("open app")
			open_app.emit()
		else:
			double_click.start()
	else:
		selected.visible = false
		
