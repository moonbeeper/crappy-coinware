extends Control
class_name NotificationBasic

@onready var label: RichTextLabel = $PanelContainer/MarginContainer/HBoxContainer/Label

# cool hack lol
var text: String = ""
var text_set: bool = false
func _ready() -> void:
	label.clear()
	
func _process(_delta: float) -> void:
	if text_set:
		return
	text_set = true
	label.append_text(text)

func setLabel(bbcode: String):
	text = bbcode 
