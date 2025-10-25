extends Control

@onready var destroy_heart_pos: Control = $DestroyHeartPos
@onready var ready_text: RichTextLabel = $ReadyText
@onready var your_hearts_img: TextureRect = $YourHearts
@onready var you_lost_txt: RichTextLabel = $YouLost
@onready var speed_up_txt: RichTextLabel = $SpeedUp
@export var heart_scene: PackedScene

signal can_draw_hearts(hearts: int)

var animating_lost_heart: bool = false
var speed_tween: Tween
var failed_tween: Tween
var has_already_continued: bool = false

func _ready() -> void:	
	ready_text.modulate = Color(1,1,1,0)
	you_lost_txt.modulate = Color(1,1,1,0)
	speed_up_txt.modulate = Color(1,1,1,0)
	await get_tree().create_timer(.5).timeout
	
	if GameManager.has_lost_heart && GameManager.has_speed_increased:
		speed_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await animate_lost_heart()
		
		speed_tween.tween_property(speed_up_txt, "modulate", Color(1,1,1,1), 1)
		# useless time eater thingy lmao
		speed_tween.tween_property(speed_up_txt, "modulate", Color(1,1,1,1), 1)
		speed_tween.chain().tween_property(speed_up_txt, "modulate", Color(1,1,1,0), 1)
		
		can_draw_hearts.emit(GameManager.current_hearts)
	elif GameManager.has_lost_heart:
		await animate_lost_heart()	
		can_draw_hearts.emit(GameManager.current_hearts)
	elif GameManager.current_hearts <= 0:
		failed_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		failed_tween.parallel().tween_property(your_hearts_img, "modulate", Color(1,1,1,0), 1)
		failed_tween.parallel().tween_property(you_lost_txt, "modulate", Color(1,1,1,1), 1)
	elif GameManager.has_speed_increased:
		speed_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		speed_tween.tween_property(speed_up_txt, "modulate", Color(1,1,1,1), 1)
	else:
		can_draw_hearts.emit(GameManager.current_hearts)
	
	var tween = get_tree().create_tween()
	tween.tween_property(ready_text, "modulate", Color(1,1,1,1), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _input(event: InputEvent) -> void:
	if has_already_continued: return
	if event.is_action_pressed("intermission_continue"):
		has_already_continued = true
		print("continue pressed, reseting GameManager state about this")
		GameManager.game_intermission_finished.emit()
		
		if GameManager.current_hearts <= 0:
			GameManager.reset()
			SceneManager.swap_scene("res://scenes/main_menu.tscn", self)
			
		SceneManager.swap_scene(GameManager.get_next_scene(), self)

func animate_lost_heart() -> void:
	print("Animating lost heart card")
	
	animating_lost_heart = true
	var child = heart_scene.instantiate() as HeartButton
	add_child(child)
	child.global_position = destroy_heart_pos.global_position - child.size/2
	child.scale = Vector2(4,4)
	child.modulate = Color(1,1,1,.2)
	child.disable_hover = true
	
	var child_tween = get_tree().create_tween()
	child_tween.tween_property(child, "modulate", Color(1,1,1,1), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(1).timeout
	child.destroy()
	
	await get_tree().create_timer(.8).timeout
	var scale_tween = get_tree().create_tween()
	scale_tween.tween_property(child, "scale", Vector2(2,2), .7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await scale_tween.finished
	
