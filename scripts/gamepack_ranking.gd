extends Control
class_name GamePackRanking

@onready var ranking_label: RichTextLabel = $Panel/MarginContainer/HBoxContainer/Ranking
@onready var max_combo_label: RichTextLabel = $Panel/MarginContainer/HBoxContainer/VBoxContainer/MaxCombo
@onready var points_label: RichTextLabel = $Panel2/MarginContainer/HBoxContainer/Points

var ranking: int = 0
var max_combo: int = 0
var points: int =3123312

var already_set: bool = false

func _ready() -> void:
	if ranking == 0:
		push_warning("created gamepack ranking with default data")
	ranking_label.text = "#%s" % ranking
	max_combo_label.text = "%sx" % max_combo
	points_label.text = humanize_number(str(points))
func _process(_delta: float) -> void:
	if already_set:
		return
		


#https://forum.godotengine.org/t/humanize-numbers/88273/3 aaaa
func humanize_number(number : String) -> String:
	var to_return : String
	var decimals : String
	if "." in number:
		decimals = "." + number.split(".", false, 0)[1]
	if len(number.replace(decimals, "")) < 4:
		return number
	else:
		var i : int = 0
		for item in number.replace(decimals, "").reverse():
			if i == 3:
				item += ","
				i = 0
			to_return = item + to_return
			i += 1
		return to_return + decimals
