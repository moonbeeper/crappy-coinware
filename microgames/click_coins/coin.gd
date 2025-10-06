extends Button

@onready var sprite: AnimatedSprite2D = $RigidBody2D/CollisionShape2D/AnimatedSprite2D
@onready var rigid: RigidBody2D = $RigidBody2D
@export var coin_type: CoinType = CoinType.REAL
	
enum CoinType { REAL, FAKE }

signal am_pressed(Node)

var already_pressed = false

func _ready() -> void:
	if coin_type == CoinType.FAKE:
		sprite.frame = 1

func _on_pressed() -> void:
	if already_pressed:
		return
	
	already_pressed = true
	rigid.freeze = false
	rigid.apply_impulse(Vector2(100, -500))
		
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	am_pressed.emit(self)
	queue_free()
