extends Control

var main: Node2D


func _on_texture_button_pressed() -> void:
	main.player.damage += 1
	main.player_update.emit()
	get_tree().paused = false
	queue_free()


func _on_texture_button_2_pressed() -> void:
	main.player.hp += 15
	main.player_update.emit()
	get_tree().paused = false
	queue_free()
