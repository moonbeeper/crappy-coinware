extends Microgame

#@onready var frame: TextureRect = ^"./	"
#@onready var coin: Button
#@onready var frame_uhh: Panel

var already_pressed: bool = false

func _ready() -> void:
	_setup() 	
	$OpenSlack/Application.connect("open_app", _on_application_open_app)
	$OpenSlack/Screenshot.modulate = Color(1,1,1,0)
	$"OpenSlack/my god please".modulate = Color(1,1,1,0)
	$"OpenSlack/omg please showup".visible = false


func _on_application_open_app() -> void:
	if !game_started: return

	print("opening slack screenshot")
	if already_pressed:
		print("already opened before, ignoring")
		return
	
	already_pressed = true
	var tween = get_tree().create_tween()
	tween.tween_property($OpenSlack/Screenshot, "modulate", Color(1,1,1,1), 0.5).from(Color(1,1,1,0)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property($"OpenSlack/my god please", "modulate", Color(1,1,1,1), 0.5).from(Color(1,1,1,0)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	await tween.finished
	$"OpenSlack/omg please showup".visible = true
	$"OpenSlack/omg please showup"._on_pressed()
	$"OpenSlack/my god please".visible = false
	has_won(true)
