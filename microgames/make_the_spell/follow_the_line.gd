extends Node2D
class_name FollowTheLine

signal finished_drawing
signal start

@export var target_path: Path2D
@export_range(20.0, 80.0) var margin_of_error: float = 30.0
@export var completion_needed: float = 0.95
@export_range(0.01, 0.1) var max_gap: float = 0.01
@export var show_dots: bool = false
@export var force_start: bool = false

var path_points: PackedVector2Array = []
var traced: Array[bool] = []

var drawing: bool = false
var drawn_points: PackedVector2Array = []
var should_start: bool = false
var finished: bool = false
@export var player_line: PackedScene

var local_player_line: Line2D

func _ready() -> void:
	start.connect(_on_start)
	if force_start:
		should_start = true
	make_path_points()
	
	local_player_line = player_line.instantiate()
	add_child(local_player_line)

func _on_start():
	should_start = true

func make_path_points():
	var curve = target_path.curve
	var length = curve.get_baked_length()
	var samples = int(length / 10.0)
	
	for i in range(samples):
		var offset = (float(i) / samples) * length
		var point = target_path.to_global(curve.sample_baked(offset))
		path_points.append(point)
		traced.append(false)

func get_progress() -> float:
	var count = 0
	for is_traced in traced:
		if is_traced:
			count += 1
			
	return float(count) / float(traced.size())

func _process(_delta):
	if !should_start || finished:
		return
			
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse = get_viewport().get_mouse_position()
		
		if !drawing:
			local_player_line.clear_points()
			local_player_line.add_point(mouse)
			drawing = true
		elif mouse.distance_to(local_player_line.points[-1]) > 3:
			local_player_line.add_point(mouse)
			check_trace(mouse)
	else:
		drawing = false

	
	queue_redraw()

func check_trace(pos: Vector2):
	for i in range(path_points.size()):
		if !traced[i] and pos.distance_to(path_points[i]) <= margin_of_error:
			traced[i] = true
	
	if is_complete():
		finished = true
		print("finished")
		finished_drawing.emit()
		
func is_complete() -> bool:
	if get_progress() < completion_needed:
		return false
	
	var gap = 0
	for is_traced in traced:
		if !is_traced:
			gap += 1
			if gap > traced.size() * max_gap:
				return false
		else:
			gap = 0
	
	return true

func _draw():
	if show_dots:
		var baked = target_path.curve.get_baked_points()
		for i in range(baked.size() - 1):
			draw_line(target_path.to_global(baked[i]), target_path.to_global(baked[i + 1]), Color(1.0, 0.2, 0.2, 0.4), 10, true)
