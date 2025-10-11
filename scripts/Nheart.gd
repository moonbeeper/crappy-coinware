extends Button
class_name HeartButton

@onready var texture: TextureRect = $Texture
@onready var shadow: TextureRect = $Shadow

var disable_hover: bool = false
var hover_tween: Tween

func _ready() -> void:
	pass

func destroy() -> void:
	$Texture.use_parent_material = true
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(material, "shader_parameter/progress", 2, 2.0).from(-1.5)
	tween.parallel().tween_property($Shadow, "self_modulate:a", 0.0, 1.0)
	await tween.finished
	queue_free()

func _on_mouse_entered() -> void:
	if disable_hover:
		return
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
		
	hover_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	hover_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)

func _on_mouse_exited() -> void:
	if disable_hover:
		return
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
		
	hover_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	hover_tween.tween_property(self, "scale", Vector2(1, 1), 0.6)
