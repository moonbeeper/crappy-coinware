extends Control

func _ready() -> void:
	pass	
	
func _on_button_pressed() -> void:
	GameManager.pick_random_game()
	SceneManager.swap_scene("res://scenes/pack_selector.tscn", self)

func _on_button_exit() -> void:
	get_tree().quit()
