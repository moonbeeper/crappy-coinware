extends Control

@onready var sprite: TextureRect = $Sprite
@onready var timer: Timer = $Timer
@onready var texture: AtlasTexture = $Sprite.texture

var status: bool = false

func _ready() -> void:
	GameManager.game_finished.connect(_on_game_finished)
	self.modulate = Color(1,1,1,0)
	
func _on_game_finished(has_won: bool):
	print("action_finished: gotten has_won = ", has_won)
	if !has_won:
		texture.region = Rect2(126.0, 0.0, 126.0, 110.0)
	else:
		texture.region = Rect2(0.0, 0.0, 126.0, 110.0)

		
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,1), .5).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(sprite, "scale", Vector2(1,1), .4).from(Vector2(2,2)).set_trans(Tween.TRANS_BOUNCE)
	await tween.finished
	
	timer.start()
	await timer.timeout
	GameManager.game_can_swap.emit()
	queue_free()

	
