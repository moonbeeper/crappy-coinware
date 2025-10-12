extends Microgame

@export var follow_line: FollowTheLine
@export var path2ds: Array[Path2D]
@export var sprite: AnimatedSprite2D

# holy crap, extra simple?!
func _ready() -> void:
	_setup()
	randomize()
	
	pick_random()
	
func pick_random() -> void:
	var index = randi() % path2ds.size()
	var path = path2ds[index]
	follow_line.target_path = path
	sprite.frame = index
	
func _on_game_can_start() -> void:
	print("game can now start, signaling follow the line script")
	follow_line.start.emit()
	
func _on_follow_the_line_finished_drawing() -> void:
	has_won(true)
