extends Node2D
class_name Player

@export var main: Node2D
@export var attack_button: TextureButton
@export var block_button: TextureButton

var hp = 100
var damage = 3
var score: int = 0
var in_block: bool = false

func _on_main_player_update() -> void:
	$HP.text = str(hp)
	attack_button.show()
	block_button.show()
	$Score.text = 'Score: %d' %score
	if hp <= 0:
		get_tree().reload_current_scene()
		return


func _on_attack_button_pressed() -> void:
	if main.card_scene:
		main.current_enemy.hp -= damage
		main.card_scene.anim.play('damage')
		attack_button.hide()
		await get_tree().create_timer(0.5).timeout
		main.enemy_turn.emit()
		


func _on_block_button_pressed() -> void:
	if main.card_scene:
		in_block = true
		block_button.hide()
		main.enemy_turn.emit()
