extends CanvasLayer


@export var main: Node2D
@export var texture_rect: TextureRect
@export var label: Notifications
@export var control: Control


func show_fish_info(fish: Fish) -> void:
	texture_rect.texture = fish.texture
	label.text_update(fish.name + '\n' + str(snapped(fish.weight,0.01)) + 'kg' + '\n' + \
	main.rarity_to_str(fish))
	await EventBus.text_update_finished
