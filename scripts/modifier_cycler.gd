extends Node
class_name ModifierCycler

var modifier_pool: Array[GameModifierResource] = []

func _init(modifiers: Array[GameModifierResource]) -> void:
	modifier_pool = modifiers.duplicate()

func pick_unique_weighted(n: int) -> Array[GameModifierResource]:
	var local_pool = modifier_pool.duplicate()
	var picks: Array[GameModifierResource] = []
	var picked_types: Array[GameModifierResource.Type] = []
	while picks.size() < n and local_pool.size() > 0:
		var acc_weights = []
		var total_weight = 0.0
		for m in local_pool:
			total_weight += m.weight
			acc_weights.append(total_weight)
		var roll = randf_range(0.0, total_weight)
		var picked_index = -1
		for i in range(local_pool.size()):
			if acc_weights[i] > roll:
				picked_index = i
				break
		if picked_index == -1:
			print("Somehow we failed to pick unique modifiers. Bailed out because of idx being -1")
			break
		var mod = local_pool[picked_index]
		if picked_types.has(mod.type):
			local_pool.remove_at(picked_index)
			continue # re-roll, do not add
		picks.append(mod)
		picked_types.append(mod.type)
		local_pool.remove_at(picked_index)

	return picks
