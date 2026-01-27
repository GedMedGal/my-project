extends StaticBody2D

@export_group('SEASONS FISH ARRAYS')
@export var possible_winter_fish: Array[Fish] #season id = 0
@export var possible_spring_fish: Array[Fish] #1
@export var possible_summer_fish: Array[Fish] #2
@export var possible_fall_fish: Array[Fish] #3
@export_group('')


@export var block: RigidBody2D
@export var rigid_fish: RigidBody2D
@export var fishtimer: Timer
@export var block_area: Area2D
@export var progress_bar: ProgressBar


var timer = 0
var fish: Fish
var echo: bool = false


const RARITY_PENALTY := 15.0
const MIN_BORDER := -16
const MAX_BORDER := 160


func _ready() -> void:
	rigid_fish.position.y = randf_range(MIN_BORDER,MAX_BORDER)
	fish = fish_picker()
	fish.weight = fish.weightgenerator.get_weight()


func fish_picker():
	var candidates: Array[Fish] = []
	var random = randi_range(0,100)

	for i in get_current_fish_array():
		if i.CATCH_TIME == TimeChanger.current_time \
		and i.CATCH_EVENT == WorldEvents.current_event:
			if random < 10:
				if i.RARITY == 3:
					candidates.append(i)
			elif random > 10 and random < 30:
				if i.RARITY == 2:
					candidates.append(i)
			elif random > 30 and random < 50:
				if i.RARITY == 1: #RARE
					candidates.append(i)
			else:
				candidates.append(i)

	if candidates.is_empty():
		return load("res://common_fish.tres")
	
	
	return candidates.pick_random()


func get_current_fish_array() -> Array[Fish]:
	match TimeChanger.current_season:
		0: return possible_winter_fish
		1: return possible_spring_fish
		2: return possible_summer_fish
		3: return possible_fall_fish
	return []



func _physics_process(delta: float) -> void:
	if echo:
		block.apply_impulse(Vector2(0,-8))
	elif not echo:
		block.apply_impulse(Vector2(0,8))
	if rigid_fish in block_area.get_overlapping_bodies():
		progress_bar.value += 0.5 - float(fish.RARITY) / RARITY_PENALTY
		timer = 0
	elif not rigid_fish in block_area.get_overlapping_bodies():
		progress_bar.value -= 0.5 - float(fish.RARITY) / RARITY_PENALTY
		if progress_bar.value <= 0.5:
			timer += delta
			if timer >= 2:
				catch_end(false)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
			echo = event.pressed


func _on_progress_bar_value_changed(value: float) -> void:
	if value >= 100:
		catch_end(true, fish)


func catch_end(result: bool, result_fish: Fish = null):
	rigid_fish.freeze = true
	block.freeze = true
	await get_tree().create_tween().tween_property(self,"modulate:a",0,1).finished
	if result:
		EventBus.end_cathing.emit(true, result_fish)
		queue_free()
	else:
		EventBus.end_cathing.emit(false, null)
		await get_tree().create_tween().tween_property(self,"modulate:a",0,1).finished
		queue_free()


func _on_fish_timer_timeout() -> void:
	rigid_fish.linear_velocity = Vector2(0,fish.behavior.pick_random())
	fishtimer.wait_time = randf_range(0.05,4-fish.RARITY)
