extends Button
class_name GamePackButton

@export var pack_icon: TextureRect
@export var pack_icon_shadow: TextureRect

var game_pack: GamePackResource = null
var pop_tween: Tween
var hover_tween: Tween
var hideShaderOutline: bool = false
var toggle: bool = false

func _ready() -> void:
	if game_pack == null:
		push_warning("created gamepack button without an actual gamepack")
		return
	pack_icon.texture = game_pack.icon
	pack_icon_shadow.texture = game_pack.icon
	tooltip_text = game_pack.display_name


func _on_pressed() -> void:
	if pop_tween and pop_tween.is_running():
		pop_tween.kill()
	pop_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	pop_tween.tween_property(self, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.1).from(Color(1,1,1,1))
	pop_tween.chain().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2).from(Color(1.5,1.5,1.5,1))
	GameManager.gamepack_press.emit(game_pack)
	toggleActive()

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
	
func toggleActive() -> void:
	toggle = !toggle
	if !toggle:
		print("hiding shader outline")
		pack_icon.material.set_shader_parameter("stop", true)
	else:
		print("showing shader outline")
		pack_icon.material.set_shader_parameter("stop", false)
