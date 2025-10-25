extends Button
class_name ModifierDisplay

@export var pack_icon: TextureRect
@export var pack_icon_shadow: TextureRect

@export var icon_to_show: Texture2D

var pop_tween: Tween
var hover_tween: Tween

func _ready() -> void:
	pack_icon.texture = icon_to_show
	pack_icon_shadow.texture = icon_to_show

func _on_mouse_entered() -> void:
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
	hover_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	hover_tween.tween_property(self, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.1)
	hover_tween.parallel().tween_property(self, "scale", Vector2(1.2, 1.2), 0.5).set_trans(Tween.TRANS_ELASTIC)
	hover_tween.chain().tween_property(self, "modulate", Color(1.15, 1.15, 1.15, 1.0), 0.3)
	self.z_index = 16

func _on_mouse_exited() -> void:
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
	hover_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	hover_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	hover_tween.parallel().tween_property(self, "scale", Vector2(1, 1), 0.6).set_trans(Tween.TRANS_ELASTIC)
	self.z_index = 0
