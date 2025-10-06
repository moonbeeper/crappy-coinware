extends Microgame

@onready var progress_bar: ProgressBar = $Control/ProgressBar
@onready var arrow: TextureRect = $Control/ArrowUp
@export var anim_offset_y: float = 0.2
@export var time_multiplier: float = 5.0
@export var down_rate: float = 10.0
@export var press_fill_rate: float = 2.0
@export_range(10.0, 99.0) var destination_value: float = 95.0

var progress: float = 0.0
var stop: bool = false
var arrow_original_y: float = 0.0
var arrow_delta: float = 0.0
# ah, so simple
func _ready() -> void:
	_setup()
	progress_bar.value = 0
	arrow_original_y = arrow.position.y
	if Engine.time_scale > 1.0:
		press_fill_rate *= Engine.time_scale
	
func _process(delta: float) -> void:
	arrow_delta += delta
	arrow.position.y = arrow_original_y + sin(arrow_delta * time_multiplier) * anim_offset_y * 50
	if stop:
		return
		
	progress -= down_rate * delta
	progress = clamp(progress, 0, 100)
	progress_bar.value = progress
	
	if progress >= destination_value:
		print("progress reached destination value")
		stop = true
		animate_up()
		has_won(true)
		return
	
func _input(event) -> void:
	if event.is_action_pressed("spam_space"):
		print("pressed action to make progress go up")
		progress += press_fill_rate
		progress = clamp(progress, 0, 100)
		progress_bar.value = progress

func animate_up() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(progress_bar, "value", 100, 0.2).set_trans(Tween.TRANS_SINE)
	
