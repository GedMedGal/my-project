extends Control
class_name Card


@onready var anim: AnimationPlayer = $AnimationPlayer

var tween: Tween

func _init() -> void:
	EventBus.update_enemy_info.connect(update_enemy_info)

func update_enemy_info(enemy: Enemy):
	$TextureRect.texture = enemy.icon
	$Hp.text = str(enemy.hp)
	$Damage.text = str(enemy.damage)
	$Name.text = (enemy.name)

func death():
	get_tree().create_tween().tween_property(self,'position',Vector2([-250,1300].pick_random(),450),0.5)
	await get_tree().create_tween().tween_property(self,'rotation_degrees',-75,1).finished
	EventBus.death_emit.emit()
	
func miss():
	if tween:
		tween.kill()
	$Status.modulate.a = 255
	$Status.position = Vector2(-64,-16)
	tween = get_tree().create_tween()
	tween.parallel().tween_property($Status,'position',Vector2([-250,1300].pick_random(),450),2)
	tween.parallel().tween_property($Status,'rotation_degrees',randf_range(-360,360),2)
	tween.parallel().tween_property($Status,'modulate:a',0,1)
