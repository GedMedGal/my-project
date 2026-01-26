extends Resource
class_name Fish

@export var name: String
@export var texture: AtlasTexture
@export var weightgenerator: WeightGenerator = WeightGenerator.new()
@export var behavior: Array[int]
@export var catching: bool = false
@export_enum('COMMON','RARE','ULTRA_RARE','LEGENDARY') var RARITY = 0
@export_enum('WINTER','FALL','SUMMER','SPRING') var SEASON
@export_enum('DAY','MORNING','EVENING','NIGHT') var CATCH_TIME = 0
@export_enum('NOTHING','RAIN','FOG', 'SNOW', 'FOLIAGE') var CATCH_EVENT = 'NOTHING'

var weight: float 
