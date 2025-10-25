extends Control

@onready var sprite: TextureRect = $Sprite
@onready var timer: Timer = $Timer
@onready var texture: AtlasTexture = $Sprite.texture

var status: bool = false

func _ready() -> void:
	GameEvents.game_ended.connect(_on_game_ended)
	self.modulate = Color(1,1,1,0)
	
func _on_game_ended(win: bool):
	print("game ended with win state of ", win)
	if !win:
		texture.region = Rect2(126.0, 0.0, 126.0, 110.0)
	else:
		texture.region = Rect2(0.0, 0.0, 126.0, 110.0)
		
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,1), .5).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(sprite, "scale", Vector2(1,1), .4).from(Vector2(2,2)).set_trans(Tween.TRANS_BOUNCE)
	await tween.finished
	
	timer.start()
	await timer.timeout
	GameEvents.game_state_shown.emit()
	queue_free()

	
