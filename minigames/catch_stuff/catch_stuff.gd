extends Microgame

@export var falling_objects: Array[Area2D] 
@export var basket: Area2D

var points: int = 0
var stop_responding: bool = true

func _ready() -> void:
	_setup()
	for node in falling_objects:
		node.position.x = randi_range(500, 900)
		
func _physics_process(delta: float) -> void:
	if stop_responding: return
	
	for node in falling_objects:
		node.position.y += 200 * delta
	
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
		
	basket.position.x += input_vector.x * 400.0 * delta 
	basket.position.x = clamp(basket.position.x, 50, 750)
	
	if points >= 4:
		stop_responding = true
		has_won(true)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area in falling_objects:
		area.queue_free()
		falling_objects.erase(area) 
		points += 1

func _on_game_started() -> void:
	stop_responding = false
