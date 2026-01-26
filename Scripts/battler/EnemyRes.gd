extends Resource
class_name Enemy



@export var name: String
@export var icon: CompressedTexture2D
@export var hp: int:
	set(v):
		hp = v
		EventBus.update_enemy_info.emit(self)
@export var damage: int
@export var miss_chance: float
@export_flags('ATTACK','BLOCK','SPELL') var ACTIONS
