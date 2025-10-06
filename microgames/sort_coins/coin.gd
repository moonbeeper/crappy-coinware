extends Button

@onready var sprite: AnimatedSprite2D = $RigidBody2D/CollisionShape2D/AnimatedSprite2D
@onready var rigid: RigidBody2D = $RigidBody2D
@export var coin_type: CoinType = CoinType.REAL
@onready var area_collision = $Area2D

enum CoinType { REAL, FAKE }

signal am_pressed(Node)

var is_following_mouse = false
var tween_hover: Tween
var tween_rotate: Tween
var already_exploded: bool = false

var last_pos: Vector2
var velocity: Vector2
var oscillator_velocity: float = 0.0
var displacement: float = 0.0 

var zone = null

func _ready() -> void:
	if coin_type == CoinType.FAKE:
		sprite.frame = 1
		area_collision.collision_layer = 2

func _on_mouse_entered() -> void:
	if tween_hover && tween_hover.is_running():
		tween_hover.kill()
	tween_hover = get_tree().create_tween()
	tween_hover.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
func _on_mouse_exited() -> void:	
	if tween_hover && tween_hover.is_running():
		tween_hover.kill()
	tween_hover = get_tree().create_tween()
	tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
func _on_gui_input(event: InputEvent) -> void:
	if (not event is InputEventMouseButton) || (event.button_index != MOUSE_BUTTON_LEFT):
		return
	
	if event.is_pressed():
		is_following_mouse = true
	else:
		is_following_mouse = false
		
		if tween_rotate && tween_rotate.is_running():
			tween_rotate.kill()
		tween_rotate = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween_rotate.tween_property(self, "rotation", 0.0, 0.3)

func _process(delta: float) -> void:
	if !is_following_mouse:
		return
	rotate_velocity(delta)
	var mouse_pos: Vector2 = get_global_mouse_position()
	global_position = mouse_pos - (size/2.0)

func rotate_velocity(delta: float) -> void:
	velocity = (position - last_pos) / delta
	last_pos = position
	
	oscillator_velocity += velocity.normalized().x * 1.0
	
	var force = -150.0 * displacement - 10.0 * oscillator_velocity
	oscillator_velocity += force * delta
	displacement += oscillator_velocity * delta
	
	rotation = displacement

func explode():
	if already_exploded:
		return
	
	already_exploded = true
	rigid.freeze = false
	rigid.apply_impulse(Vector2(100, -500))
		
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	am_pressed.emit(self)
	queue_free()
