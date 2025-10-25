extends Control

func _ready() -> void:
	pass	
	
func _on_play_pressed() -> void:
	SceneManager.swap_scene("res://scenes/chosen_difficulty.tscn", self)

func _on_custom_game_pressed() -> void:
	SceneManager.swap_scene("res://scenes/pack_selector.tscn", self)

func _on_rankings_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()
