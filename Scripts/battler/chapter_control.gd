extends Node
class_name ChapterControl

var Bosses: Array[Enemy]
var Enemys: Array[Enemy]
@export var main: Node2D


func _on_main_chapter_update(current_chapter: int) -> void:
	var enemys_path = "res://Chapters/Chapter%d/Enemys/" % current_chapter
	var bosses_path = "res://Chapters/Chapter%d/Bosses/" % current_chapter
	var enemys_files = DirAccess.get_files_at(enemys_path)
	var bosses_files =  DirAccess.get_files_at(bosses_path)
	for file in enemys_files:
		if file.ends_with('.tres'):
			var full_path = enemys_path + file
			Enemys.append(load(full_path))
	main.Enemys = Enemys
	for file in bosses_files:
		if file.ends_with('.tres'):
			var full_path = bosses_path + file
			Bosses.append(load(full_path))
	main.Bosses = Bosses
