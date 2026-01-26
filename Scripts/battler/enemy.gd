extends Node2D

@export var main: Node2D
@export var player: Player 

signal enemy_dead()

func _on_main_enemy_turn() -> void:
	if check_life():
		check_turn()


func check_life() -> bool:
	if main.current_enemy.hp <= 0:
		enemy_dead.emit()
		return false
	return true


func check_turn():
	var enemy = main.current_enemy
	if randf_range(0,100) > enemy.miss_chance:
		match enemy.name:
			'Wolf':
				pass
			'Bear':
				pass
				enemy.damage +=1
				enemy.hp -= enemy.damage
				main.card_scene.anim.play('damage')
				await main.card_scene.anim.animation_finished
		if check_life():
			if player.in_block:
				player.hp -= main.current_enemy.damage / 2
				player.in_block = false
			else:
				player.hp -= main.current_enemy.damage
			main.card_scene.anim.play('punch')
			await main.card_scene.anim.animation_finished
		else:
			return
	else:
		main.card_scene.miss()
	main.player_update.emit()
