extends Control

@export var background: ColorRect
@export var container: CenterContainer
@export var panel_bg: NinePatchRect
@export var difficulty_container: HBoxContainer
@export var actions_container: MarginContainer
@export var reroll_button: Button
@export var start_button: Button

var modifier_card = preload("res://nodes/modifer_display.tscn")
var pop_tween1: Tween
var pop_tween: Tween
var current_cards: Array[Node] = []

func _ready() -> void:
	container.modulate = Color(1,1,1,0)
	var actions_original_pos = Vector2(0, actions_container.position.y)
	actions_container.position.y = actions_container.position.y + actions_container.size.y + 16.0
		
	GameEvents.game_modifiers_chosen.connect(_on_game_modifiers_chosen)
	var tween = get_tree().create_tween()
	tween.tween_property(background, "color", Color(0.061, 0.061, 0.061, 1.0), .5)
	tween.chain().tween_property(container, "modulate", Color(1,1,1,1), .5)
	await tween.finished
	var tween2 = get_tree().create_tween()
	var original_color = panel_bg.modulate
	tween2.tween_property(panel_bg, "modulate", Color(1.5, 1.5, 1.5, 1.0) * original_color, 0.1).from(Color(1,1,1,1) * original_color)
	tween2.chain().tween_property(panel_bg, "modulate", Color(1, 1, 1, 1) * original_color, 0.2).from(Color(1.5,1.5,1.5,1) * original_color	)
	panel_bg.material.set_shader_parameter("stop", false)
	tween2.chain().tween_property(actions_container, "position", actions_original_pos, .6)
	await tween2.finished
	
	GameManager.create_all_game_pool()
	
func _on_game_modifiers_chosen() -> void:
	var cards_to_delete = current_cards.duplicate()
	for card in cards_to_delete:
		print("deleting")
		var tween = get_tree().create_tween()
		tween.tween_property(card, "modulate", Color(1, 1, 1, 0), 0.1).from(Color(1,1,1,1))
		await tween.finished
		current_cards.erase(card)
		card.queue_free()

	for mod in GameManager.current_game_modifiers:
		var card = modifier_card.instantiate() as ModifierDisplay
		var tween = get_tree().create_tween()
		
		card.modulate = Color(1,1,1,0)
		card.icon_to_show = mod.icon
		difficulty_container.add_child(card)
		tween.tween_property(card, "modulate", Color(1,1,1,1), 0.5)
		await tween.finished
		print("adding")
		current_cards.append(card)


func _on_reroll_mods_pressed() -> void:
	if pop_tween and pop_tween.is_running():
		pop_tween.kill()
	pop_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	pop_tween.tween_property(reroll_button, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.1).from(Color(1,1,1,1))
	pop_tween.chain().tween_property(reroll_button, "modulate", Color(1, 1, 1, 1), 0.2).from(Color(1.5,1.5,1.5,1))
	GameManager.pick_game_modifiers()

func _on_start_pressed() -> void:
	if pop_tween and pop_tween.is_running():
		pop_tween.kill()
	pop_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	pop_tween.tween_property(start_button, "modulate", Color(1.1, 1.1, 1.1, 1.0), 0.1).from(Color(1,1,1,1))
	pop_tween.chain().tween_property(start_button, "modulate", Color(1, 1, 1, 1), 0.2).from(Color(1.1,1.1,1.1,1))
	SceneManager.swap_scene(GameManager.get_next_scene(), self)


func _on_go_back_pressed() -> void:
	GameManager.reset()
	SceneManager.swap_scene("res://scenes/main_menu.tscn", self)
