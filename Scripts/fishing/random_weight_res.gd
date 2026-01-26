extends Resource
class_name WeightGenerator

@export var min_weight: float
@export var max_weight: float

func get_weight() -> float:
	return randf_range(min_weight,max_weight)
