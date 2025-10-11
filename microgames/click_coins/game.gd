extends Microgame

var coin_amount = 0
var initial_coin_amount = 0
var coin_scene = preload("res://microgames/click_coins/coin.tscn")
var finished = false
var is_ready = false
var instantiated_coins = []

func _ready() -> void:
	_setup()
	coin_amount = randi_range(4, 8)
	initial_coin_amount = coin_amount
	
	for i in range(coin_amount):
		var sprite = coin_scene.instantiate()
		randomize()
		sprite.position.x = randi_range(56, 950)
		sprite.position.y = randi_range(50, 450)
		sprite.rotation_degrees = randi_range(-45, 45)
		sprite.am_pressed.connect(_on_pressed)
		instantiated_coins.append(sprite)
		add_child(sprite)
		
	is_ready = true

func _process(_delta: float) -> void:
	if !coin_amount == 0 || finished || !is_ready:
		return
	finished = true
	has_won(true)
	
func _on_pressed(node: Node) -> void:
	print("clicked, %s / %s" % [coin_amount,initial_coin_amount])
	coin_amount -= 1
	instantiated_coins.erase(node)

func _on_game_ended():
	finished = true
	for coin in instantiated_coins:
		if coin:
			coin.explode()
