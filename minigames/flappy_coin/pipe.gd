extends Node2D
class_name FlappyCoinPipe

signal pipe_touched
signal pipe_scored

var stop_moving: bool = true

func _ready():
	self.position.y = randi_range(-80, 80)
	
func _process(delta):
	if stop_moving: return
	self.position.x -= delta * 200
	
func _on_score_area_body_entered(_body: Node2D) -> void:
	pipe_scored.emit()
	
func _on_area_2d_body_entered(_body: Node2D) -> void:
	pipe_touched.emit()
	
