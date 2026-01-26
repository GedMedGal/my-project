extends Control


@export var label: Label
@export var main: Node2D

func _process(delta: float) -> void:
	label.text = 'Chapter %d %d' % [main.current_chapter, main.current_level ]
