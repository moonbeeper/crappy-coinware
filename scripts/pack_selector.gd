extends Control

@export var game_pack_container: GridContainer
@export var too_many_packs_thing: TextureRect
@export var loading_containers: Array[CenterContainer]
@export var loading_icons: Array[TextureRect]
@export var right_side: MarginContainer
@export var rankings_container: VBoxContainer
@export var play_button: Button
@export var info_text: RichTextLabel

var game_pack_button = preload("res://nodes/gamepack_button.tscn")
var game_pack_ranking = preload("res://nodes/gamepack_ranking.tscn")
var loading_rot_delta: float = 0.0
var loading_stopped: bool = false
var active_packs: Array[int] = []
var play_button_tween: Tween

func _ready() -> void:
	game_pack_container.modulate = Color(1,1,1,0)
	right_side.modulate = Color(1,1,1,0)
	play_button.modulate = Color(1,1,1,0)
	info_text.modulate = Color(1,1,1,0)
	GameManager.gamepack_press.connect(_on_gamepack_press)

	var game_packs = GameManager.get_game_packs()
	for pack in game_packs:
		var child = game_pack_button.instantiate() as GamePackButton
		child.game_pack = pack
		game_pack_container.add_child(child)
	await get_tree().create_timer(.5).timeout
	
	loading_stopped = true	
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	for loading_container in loading_containers:
		tween.parallel().tween_property(loading_container, "modulate", Color(1,1,1,0), 0.5)
	tween.parallel().tween_property(game_pack_container, "modulate", Color(1,1,1,1), 0.5).from(Color(1,1,1,0))
	tween.parallel().tween_property(right_side, "modulate", Color(1,1,1,1), 0.5).from(Color(1,1,1,0))
	tween.parallel().tween_property(info_text, "position", Vector2(11, 608), 0.5).from(Vector2(-1190, 608))
	tween.parallel().tween_property(info_text, "modulate", Color(1,1,1,1), 0.5).from(Color(1,1,1,0))
	await tween.finished
	
	for loading_container in loading_containers:
		loading_container.queue_free()


func _process(delta: float) -> void:
	if !loading_stopped:
		loading_rot_delta += delta
		if loading_rot_delta >= 0.5:
			loading_rot_delta -= 0.5
			for loading_icon in loading_icons:
				loading_icon.rotation -= TAU / 12

func _on_gamepack_press(gamepack: GamePackResource):
	print("gamepack pressed: %s with id %s" % [gamepack.display_name, gamepack.pack_id])
	
	if gamepack.pack_id in active_packs:
		active_packs.erase(gamepack.pack_id)
	else:
		active_packs.append(gamepack.pack_id)
		
	update_play_button()
	update_rankings()

func update_rankings() -> void:
	for child in rankings_container.get_children():
		child.queue_free()
	
	if active_packs.is_empty():
		return
	
	var save_data = GameManager.save_data
	var scores: Array[Dictionary] = []
	
	if active_packs.size() == 1:
		scores = save_data.get_scores_for_pack(active_packs[0])
	else:
		scores = save_data.get_scores_for_packs(active_packs)
	
	if scores.is_empty():
		var no_scores_label = Label.new()
		no_scores_label.text = "No scores yet for this combination!"
		no_scores_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_scores_label.add_theme_font_size_override("normal_font_size", 24)
		rankings_container.add_child(no_scores_label)
	else:
		for i in range(scores.size()):  
			var ranking = game_pack_ranking.instantiate() as GamePackRanking
			ranking.ranking = i + 1
			ranking.points = scores[i].score
			ranking.max_combo = scores[i].combo
			rankings_container.add_child(ranking)

func update_play_button():
	if play_button_tween and play_button_tween.is_running():
		play_button_tween.kill()
	play_button_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if active_packs.is_empty():
		play_button_tween.tween_property(play_button, "modulate", Color(1,1,1,0), 0.2)
	else:
		play_button_tween.tween_property(play_button, "modulate", Color(1,1,1,1), 0.2)

func _on_play_button_pressed() -> void:
	print("play button pressed, going to intermission")
	GameManager.reset()
	GameManager.create_game_pool(active_packs)
	SceneManager.swap_scene("res://scenes/intermission.tscn", self)
