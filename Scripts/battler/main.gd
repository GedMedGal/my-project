extends Node2D

@export var ChapterControler: ChapterControl
@export var player: Player
@export var EnemyConstruct: Enemy

var award_menu = preload('res://Scenes/battler/award_menu.tscn')
var card = preload('res://Scenes/battler/a_card.tscn')
var Enemys: Array[Enemy]
var Bosses: Array[Enemy]
var current_chapter: int = 1
var current_level: int = 1
var current_enemy: Enemy
var card_scene


signal chapter_update(current_chapter: int)
@warning_ignore("unused_signal")
signal enemy_turn()
signal player_update()


func _ready() -> void:
	start_round()


func start_round():
	player_update.emit()
	chapter_update.emit(current_chapter)
	spawn_enemy()

func spawn_enemy(boss: bool = false):
	card_scene = card.instantiate()
	if boss:
		current_enemy = Bosses.pick_random().duplicate()
	else:
		current_enemy = Enemys.pick_random().duplicate()
	EventBus.update_enemy_info.emit(current_enemy)
	card_scene.global_position = $Enemy/Marker2D.global_position
	$Enemy.add_child(card_scene)


func _on_enemy_enemy_dead() -> void:
	card_scene.death()
	await EventBus.death_emit
	card_scene.queue_free()
	player.score +=1
	chapter_settings()
	player_update.emit()
	if current_level % 5 == 0:
		spawn_enemy(true)
	else:
		spawn_enemy()


func award_menu_setting():
	var menu = award_menu.instantiate()
	menu.main = self
	add_child(menu)
	get_tree().paused = true


func chapter_settings():
	current_level +=1
	if current_level % 6 == 0:
		current_chapter +=1
		current_level = 0 
		chapter_update.emit(current_chapter)
	else:
		await award_menu_setting()
