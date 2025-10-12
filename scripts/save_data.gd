extends Resource
class_name SaveData

@export var highscores: Array[Dictionary] = []
var max_highscores_per_packs: int = 10

func save() -> void:
	print("saving game")
	var error = ResourceSaver.save(self, "user://save_data.tres")
	if error:
		print("something went wrong while saving: %s" % error)
	
static func load_me() -> SaveData:
	if !ResourceLoader.exists("user://save_data.tres"):
		push_warning("there wasn't already a save data file, loading a fresh one")
		return SaveData.new()
	else:
		print("save data found, loading existing one")
		return ResourceLoader.load("user://save_data.tres") as SaveData

func add_score(packs: Array[int], score: int, combo: int) -> void:
	print("adding new score to save data")
	var sorted_packs = packs.duplicate()
	sorted_packs.sort()
	
	var entry = {
		"score": score,
		"packs": sorted_packs,
		"combo": combo
	}
	
	highscores.append(entry)
	trim_scores_for_packs(sorted_packs)
	
	save()

func trim_scores_for_packs(packs: Array[int]) -> void:
	print("trimming save data scores")
	var combo_scores: Array[Dictionary] = []
	var other_scores: Array[Dictionary] = []
	
	for entry in highscores:
		if entry.packs == packs:
			combo_scores.append(entry)
		else:
			other_scores.append(entry)
	
	combo_scores.sort_custom(func(a, b): return a.score > b.score)
	if combo_scores.size() > max_highscores_per_packs:
		combo_scores = combo_scores.slice(0, max_highscores_per_packs)
	
	highscores = other_scores + combo_scores

func get_scores_for_pack(pack_id: int) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	
	for entry in highscores:
		if pack_id in entry.packs:
			results.append(entry)
	
	results.sort_custom(func(a, b): return a.score > b.score)
	return results

func get_scores_for_packs(packs: Array[int]) -> Array[Dictionary]:
	var sorted_packs = packs.duplicate()
	sorted_packs.sort()
	
	var results: Array[Dictionary] = []
	
	for entry in highscores:
		if entry.packs == sorted_packs:
			results.append(entry)
	
	results.sort_custom(func(a, b): return a.score > b.score)
	return results
