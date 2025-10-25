extends Resource
class_name GameModifierResource

enum Type {
	TIME_SCALE, HEALTH, ANNOYANCE
}

enum AnnoyanceType {
	NONE
}

@export var display_name: String = "My Game Modifier"
@export var icon: Texture2D = preload("res://icon.svg")
@export var type: Type = Type.TIME_SCALE
@export var annoyance_type: AnnoyanceType = AnnoyanceType.NONE
@export var weight: int = 1

@export_category("Speed Modifier")
@export var starting_time_scale: float = 1.0
@export var increase_speed_after: int = 5
@export var increase_speed_after_pool: bool = false

@export_category("Health Modifier")
@export var initial_hearts: int = 5
