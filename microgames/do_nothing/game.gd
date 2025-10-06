extends Microgame

# ah, so simple
func _ready() -> void:
	_setup()
	force_win_on_timeout = true
	
func _input(event) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		has_won(false)
