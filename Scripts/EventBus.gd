extends Node


signal update_enemy_info(enemy: Enemy)
signal death_emit()

signal start_cathing
signal end_cathing(result: bool, fish: Fish)

signal text_update(new_text: String)
signal text_update_finished()

signal time_updated(hour: int)
signal season_updated(season: int)
signal date_updated(year: int, month: int, day: int)
