extends Label
class_name Notifications

@export var control: Control

var tween: Tween



func _ready() -> void:
	EventBus.text_update.connect(text_update)


func text_update(new_text: String):
	
	if tween and tween.is_running():
		tween.kill()
		control.modulate.a = 0
	
	new_text = new_text.replace('_',' ')
	
	text = tr(new_text)
	tween = get_tree().create_tween()
	await tween.tween_property(control,'modulate:a', 1, 2).finished
	tween = get_tree().create_tween()
	await tween.tween_property(control,'modulate:a', 0, 2).finished
	EventBus.text_update_finished.emit()
	return
