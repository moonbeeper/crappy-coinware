extends Node

var save_data: SaveData
const data_path: String = "user://save_data.tres"
const corrupted_data_path: String = "user://save_data_corrupted.tres"
var max_highscores_per_packs: int = 10

func _ready() -> void:
	print("Loading save data")
	load_me()

func save() -> void:
	print("Saving game...")
	
	var error = ResourceSaver.save(save_data, data_path)
	if error:
		print("Something went wrong while saving: %s" % error)
		
	print("Game saved")
	
func load_me() -> void:
	if !ResourceLoader.exists(data_path):
		print("player didn't already a save data file, creating a fresh one")
		save_data = SaveData.new()
		save()
	else:
		print("Save data found, loading existing one")
		var loaded = ResourceLoader.load(data_path)
		if loaded is SaveData:
			save_data = loaded
		else:
			print("Somehow the save data isn't ours or its corrupted, creating a fresh save and moving unknown one")
			var error = DirAccess.rename_absolute(data_path, corrupted_data_path)
			if error:
				print("Something went wrong while renaming the original save: %s" % error)
			else:
				print("Successfully renamed original save")
				
			print("Creating new save data")
			save_data = SaveData.new()
			save()

		print("Save data loaded")

func add_score(packs: Array[int], score: int, combo: int) -> void:
	print("Adding new score to save data")
	var sorted_packs = packs.duplicate()
	sorted_packs.sort()
	
	var entry = {
		"score": score,
		"packs": sorted_packs,
		"combo": combo
	}
	
	save_data.highscores.append(entry)
	trim_scores_for_packs(sorted_packs)
	save()

func trim_scores_for_packs(packs: Array[int]) -> void:
	print("trimming save data scores")
	var combo_scores: Array[Dictionary] = []
	var other_scores: Array[Dictionary] = []
	
	for entry in save_data.highscores:
		if entry.packs == packs:
			combo_scores.append(entry)
		else:
			other_scores.append(entry)
	
	combo_scores.sort_custom(func(a, b): return a.score > b.score)
	if combo_scores.size() > max_highscores_per_packs:
		combo_scores = combo_scores.slice(0, max_highscores_per_packs)
	
	save_data.highscores = other_scores + combo_scores

func get_scores_for_pack(pack_id: int) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	
	for entry in save_data.highscores:
		if pack_id in entry.packs:
			results.append(entry)
	
	results.sort_custom(func(a, b): return a.score > b.score)
	return results

func get_scores_for_packs(packs: Array[int]) -> Array[Dictionary]:
	var sorted_packs = packs.duplicate()
	sorted_packs.sort()
	
	var results: Array[Dictionary] = []
	
	for entry in save_data.highscores:
		if entry.packs == sorted_packs:
			results.append(entry)
	
	results.sort_custom(func(a, b): return a.score > b.score)
	return results
