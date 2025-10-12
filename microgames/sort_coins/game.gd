extends Microgame

@onready var real_coin_zone = $Control/VBoxContainer/HBoxContainer/real/Area2D
@onready var fake_coin_zone = $Control/VBoxContainer/HBoxContainer/fake/Area2D

var coin_amount = 0
var coin_scene = preload("res://microgames/sort_coins/coin.tscn")
var finished = false
var is_ready = false
var instantiated_coins = []
var real_zone_coins = []
var fake_zone_coins = []

func _ready() -> void:
	_setup()
	coin_amount = randi_range(4, 8)
	
	for i in coin_amount:
		var sprite = coin_scene.instantiate()
		var is_fake = randi_range(0,1)
		randomize()
		sprite.position.x = randi_range(69, 1055)
		sprite.position.y = randi_range(430, 480)
		sprite.rotation_degrees = randi_range(-45, 45)
		sprite.coin_type = is_fake
		instantiated_coins.append(sprite)
		add_child(sprite)
		
	is_ready = true

func _process(_delta: float) -> void:
	if finished || !is_ready || !game_started:
		return

	var coins_in_real = real_coin_zone.get_overlapping_areas()
	var coins_in_fake = fake_coin_zone.get_overlapping_areas()
	
	#print(coins_in_real.size())
	#print(coins_in_fake.size())
	
	var total_sorted = coins_in_real.size() + coins_in_fake.size()
	if total_sorted == coin_amount:
		print("gaming")
		var all_correct = true
		
		for raw_coin in real_zone_coins:
			var coin = raw_coin.get_parent()
			if coin.coin_type != 0:
				all_correct = false
				print("failed check real")

				break
		
		for raw_coin in fake_zone_coins:
			var coin = raw_coin.get_parent()
			if coin.coin_type != 1:
				all_correct = false
				print("failed check false")
				break
		
		if all_correct:
			finished = true
		print(all_correct)
		has_won(all_correct)
		
func _on_game_ended():
	finished = true
	for coin in instantiated_coins:
		if coin:
			coin.explode()
