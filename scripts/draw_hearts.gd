extends Control
class_name DrawHearts

@export var draw_from: Control
@export var heart_scene: PackedScene
@export var offset_x: float = 70.0
@export var rot_max: float = 10.0
@export var anim_offset_y: float = 0.2
@export var time_multiplier: float = 2.0

var time: float = 0.0
var is_drawn = false
var tween: Tween
var tween_animate: Tween
var sine_offset_mult: float = 0.0
var item_count: int = 1

func _ready() -> void:
	rot_max = deg_to_rad(rot_max)

func _process(delta: float) -> void:
	time += delta
	for i in range(get_child_count()):
		var c: Button = get_child(i)
		var val: float = sin(i + (time * time_multiplier))
		c.position.y += val * sine_offset_mult

func draw_obj() -> void:
	is_drawn = true
	if tween and tween.is_running():
		tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			
	for i in range(item_count):
		var instance: Button = heart_scene.instantiate()
		add_child(instance)
		instance.global_position = draw_from.global_position
		
		var final_pos: Vector2
		var rot_radians: float
		if item_count == 1:
			final_pos = -(instance.size / 2.0)
			rot_radians = 0.0
		else:
			final_pos = -(instance.size / 2.0) - Vector2(offset_x * (item_count - 1 - i), 0.0)
			final_pos.x += ((offset_x * (item_count-1)) / 2.0)
			rot_radians = lerp_angle(-rot_max, rot_max, float(i)/float(item_count-1))
		tween.parallel().tween_property(instance, "position", final_pos, 0.3 + (i * 0.075))
		tween.parallel().tween_property(instance, "rotation", rot_radians, 0.3 + (i * 0.075))
	
	tween.tween_property(self, "sine_offset_mult", anim_offset_y, 1.5).from(0.0)

func _on_gameplay_can_draw_hearts(hearts: int) -> void:
	print("drawing %s hearts" % hearts)
	item_count = hearts
	draw_obj()
