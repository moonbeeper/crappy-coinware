extends TextureRect

var last_position = Vector2()
var scale_factor = 1.0
var max_scale = 2.2
var sensitivity = 0.0005 

func _ready() -> void:
	last_position = position

func _physics_process(delta: float) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		
	var target_position = get_global_mouse_position() - Vector2(4, 4)
	position = lerp(position, target_position, 0.25)

	var speed = position.distance_to(last_position) / delta
	last_position = position 

	var target_scale = 2.0 + min(speed * sensitivity, max_scale - 1.0)
	scale_factor = lerp(scale_factor, target_scale, 0.2)
	self.scale = Vector2(scale_factor, scale_factor)
