extends CanvasModulate
class_name TimeChanger

@export var night_color := Color(0.1, 0.1, 0.2)
@export var day_color := Color(1, 1, 1)


@export var sunrise := 6.0
@export var sunset := 20.0

var tween: Tween

enum CURRENT_TIME { DAY, MORNING, EVENING, NIGHT }
enum CURRENT_SEASON { WINTER, SPRING, SUMMER, FALL }

static var current_hour: int
static var current_time: CURRENT_TIME
static var current_season: CURRENT_SEASON = CURRENT_SEASON.WINTER
static var current_date := {"year": 0, "month": 0, "day": 0}

# ----- READY -----
func _ready():
	EventBus.time_updated.connect(update_light)
	EventBus.season_updated.connect(update_season)
	EventBus.date_updated.connect(update_date)

# ----- LIGHT -----
func update_light(hour: int):
	current_hour = hour
	var k := get_day_factor(float(hour))
	var target_color := night_color.lerp(day_color, k)
	
	
	if hour >= 6 and hour < 12:
		current_time = CURRENT_TIME.MORNING
	elif hour >= 12 and hour < 18:
		current_time = CURRENT_TIME.DAY
	elif hour >= 18 and hour < 24:
		current_time = CURRENT_TIME.EVENING
	else:
		current_time = CURRENT_TIME.NIGHT

	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(self, "color", target_color, 3.0)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

# ----- СЕЗОН -----
func update_season(season: int):
	current_season = season

# ----- ДАТА -----
func update_date(year: int, month: int, day: int):
	current_date.year = year
	current_date.month = month
	current_date.day = day

# ----- ФАКТОР ДНЯ -----
func get_day_factor(hour: float) -> float:
	if hour < sunrise or hour > sunset:
		return 0.0
	var t := (hour - sunrise) / (sunset - sunrise)
	return lerp(0.05, 1.0, sin(t * PI))

# ----- СТРОКА ВРЕМЕНИ И СЕЗОНА -----
static func get_string_season_and_time() -> String:
	return CURRENT_SEASON.keys()[current_season] + " " + CURRENT_TIME.keys()[current_time]
