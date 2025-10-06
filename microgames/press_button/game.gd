extends Microgame

@export var label: Label
@export var not_label: RichTextLabel
@export var wrong_key: Label
@export var should_not_press: Label

const keys = [
	KEY_F, KEY_G, KEY_H, KEY_K, KEY_SPACE, KEY_2, KEY_Z, KEY_ENTER, KEY_SHIFT
]

var should_not = false
var stop_responding = false;
var label_set = false
var selected_key: Key


func _ready() -> void:
	_setup()
	randomize()
	
	should_not = randf() > 0.4
	if should_not:
		force_win_on_timeout = true
		not_label.visible = true
		
	selected_key = keys.pick_random()
	var event = InputEventKey.new()
	event.physical_keycode = selected_key
	
	InputMap.action_erase_events("press_button_action")
	InputMap.action_add_event("press_button_action", event)
	
func _process(_delta: float) -> void:
	if !game_started || label_set:
		return
	label.text = "Press %s" % OS.get_keycode_string(selected_key)
	label_set = true

func _input(event) -> void:
	if stop_responding or not game_started:
		return
	if event.is_action_pressed("press_button_action"):
		stop_responding = true
		if should_not:
			has_won(false)
		else:
			has_won(true)
	elif event is InputEventKey and event.pressed and not event.echo:
		stop_responding = true
		if should_not:
			has_won(true)
		else:
			has_won(false)
