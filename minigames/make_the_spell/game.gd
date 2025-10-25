extends Microgame

@export var follow_line: FollowTheLine
@export var path2ds: Array[Path2D] = []
@export var sprite: AnimatedSprite2D

var shape_groups := {
	"star": [2, 5],
	"triangle": [0, 0, 1],
	"flower": [1, 2, 3, 4]
}

# holy crap, extra simple?!
func _ready() -> void:
	_setup()
	randomize()
	pick_random()
	
func pick_random() -> void:
	var keys = shape_groups.keys()
	var shape = keys[randi() % keys.size()]
	var shapes: Array = shape_groups.get(shape)
	var sprite_idx = shapes[0]
	
	var parsed_paths : Array[Path2D]= []
	
	for i in range(1, shapes.size()):
		if i < path2ds.size():
			parsed_paths.append(path2ds[shapes[i]])
	
	#var index = randi() % path2ds.size()
	#var path = path2ds[index]
	#follow_line.target_path = path
	sprite.frame = sprite_idx
	follow_line.target_paths = parsed_paths
	follow_line.make_path_points()
		
func _on_start_game() -> void:
	print("Because the game started, the line can now be followed (wow)")
	follow_line.start.emit()
	
func _on_follow_the_line_finished_drawing() -> void:
	has_won(true)
	#print("win")
