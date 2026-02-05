extends Node2D

enum RARITY { COMMON , RARE , ULTRA_RARE , LEGENDARY }

var timer = 0
var speed = 2
var koef = 1
var sign_tween: Tween
var speed_koef: int = 1

var fishrod = preload("res://Scenes/fishing/fish_rod.tscn")

@export_group('Paralax_Nodes')
@export var water : Parallax2D
@export var underwater : Parallax2D
@export var earth: Parallax2D
@export var player_anim: AnimatedSprite2D
@export var ParalaxTimer: Timer
@export_group('','')

@warning_ignore("shadowed_global_identifier")
@export var sign: Sprite2D
@export var UI: CanvasLayer
@export var point_light: PointLight2D


func _ready() -> void:
	_on_timer_timeout()
	EventBus.end_cathing.connect(catch_end)
	EventBus.start_cathing.connect(catch_start)


func _process(delta: float) -> void:
	timer += delta
	if timer >= 3:
		koef *= -1
		timer = 0
	$Parallax/Node2D.position.x += koef* 0.03
	sign.position.x += koef* 0.03
	point_light.position.x += koef* 0.03


func _on_timer_timeout() -> void:
	speed *= (speed_koef)
	ParalaxTimer.wait_time = randi_range(1,10)
	water.autoscroll.x = speed
	underwater.autoscroll.x = -speed
	$"Parallax/Деревья".autoscroll.x = speed
	earth.autoscroll.x = 2*speed
	$Parallax/Parallax2D.autoscroll.x = -1.5*speed


func _on_fish_timer_timeout() -> void:
	$FishTimer.stop()
	sign_settings()


func sign_settings():
	sign.show()
	sign.position.y = 148
	sign_tween = get_tree().create_tween().set_loops()
	sign_tween.tween_property(sign,'position:y', sign.position.y - 5, 1).finished
	sign_tween.tween_property(sign,'position:y', sign.position.y + 5, 1).finished
	$CatchingTimer.start(3)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if sign.visible:
			$CatchingTimer.stop()
			if sign_tween:
				sign_tween.kill()
				sign.hide()
			add_child(fishrod.instantiate())
			EventBus.start_cathing.emit()


func catch_end(result: bool, fish: Fish = null):
	if result:
		player_anim.play('hook_start')
		await player_anim.animation_finished
		await UI.show_fish_info(fish)
		player_anim.play('hook_end')
		await player_anim.animation_finished
	$FishTimer.start(randf_range(5,20))
	EventBus.start_cathing.emit()
	return


func catch_start():
	player_anim.play('idle')


func rarity_to_str(fish: Fish) -> String:
	return RARITY.keys()[fish.RARITY]


func _on_catching_timer_timeout() -> void:
	sign.hide()
	$FishTimer.start(randf_range(5,20))
