extends Node2D
class_name FollowTheLine

signal finished_drawing
signal start

@export var target_paths: Array[Path2D] = []
@export_range(10.0, 40.0) var margin_of_error: float = 20.0
@export var completion_needed: float = 0.97
@export_range(0.01, 0.1) var max_gap: float = 0.03
@export var show_dots: bool = false
@export var force_start: bool = false
@export var player_line: PackedScene

var path_points: PackedVector2Array = []
var traced: Array[bool] = []

var drawing: bool = false
var should_start: bool = false
var finished: bool = false

var local_current_line: Line2D

func _ready() -> void:
	start.connect(_on_start)
	if force_start:
		should_start = true
		
	local_current_line = player_line.instantiate()
	add_child(local_current_line)

func _on_start():
	should_start = true

func make_path_points():
	for path in target_paths:
		var curve = path.curve
		var length = curve.get_baked_length()
		var samples = max(12, int(length / 8.0))
		
		for i in range(samples):
			var offset = (float(i) / samples) * length
			var point = path.to_global(curve.sample_baked(offset))
			path_points.append(point)
			traced.append(false)

func get_progress() -> float:
	var count: float = 0
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
			local_current_line.add_point(mouse)
			drawing = true
		elif local_current_line.points.size() > 0 and mouse.distance_to(local_current_line.points[-1]) > 3:
			local_current_line.add_point(mouse)
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
		print("drawing finished")
		finished_drawing.emit()

func is_complete() -> bool:
	if traced.size() == 0:
		return false
		
	if get_progress() < completion_needed:
		return false
		
	var gap = 0
	var max_gap_size = int(traced.size() * max_gap)
	for is_traced in traced:
		if !is_traced:
			gap += 1
			if gap > max_gap_size:
				return false
		else:
			gap = 0
			
	return true

func _draw():
	if show_dots:
		for i in range(path_points.size()):
			var color = Color(0.3, 1.0, 0.3) if traced[i] else Color(1.0, 0.6, 0.6, 1.0)
			draw_circle(path_points[i], 5, color)
