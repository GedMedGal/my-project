extends Control

@onready var item_list := $TabContainer/Winter/MarginContainer/ItemList

var fish_descriptions := [
"Карась — рыба из пресных вод, живет тихо и ест ил и мягкие растения.",
"Щука — хищная рыба, прячется в камышах и нападает на добычу резкими рывками.",
"Окунь — полосатый хищник, активно охотится днём и легко попадается рыбакам.",
"Сом — ночной донный хищник, ориентируется усами и любит глубокие тихие места.",
"Лещ — осторожная рыба с плоским телом, держится стаями и любит спокойные воды.",
"Плотва — маленькая распространённая рыба, часто попадается рыбакам в мелких водоёмах.",
"Судак — ночной хищник с острым зрением, предпочитает чистую прохладную воду.",
"Форель — быстрая и пугливая рыба, обитает в холодных реках, чувствительна к качеству воды.",
"Лосось — проходная рыба, преодолевает большие расстояния из моря в реки ради нереста.",
"Карп — крупная сильная рыба, известна своей выносливостью и долгой борьбой после поклёвки."
]


func _ready() -> void:
	EventBus.end_cathing.connect(update_item_list)
	var text = ''
	TranslationServer.set_locale('en')
	print(OS.get_locale_language())
	for i in range(item_list.item_count):
		if i < len(fish_descriptions):
			text = tr('fisheSSS')
			#text = fish_descriptions[i]
		var wrapped := wrap_text(text, 30)
		item_list.set_item_tooltip(i, wrapped)
		item_list.set_item_tooltip_enabled(i, true)
		var icon = item_list.get_item_icon(i)
		item_list.set_item_icon_modulate(i, Color.BLACK)


func wrap_text(text: String, line_len := 30) -> String:
	var result := ""
	for i in range(text.length()):
		if i != 0 and i % line_len == 0:
			if result[i-1] != '':
				result += '-'
			result += "\n"
		result += text[i]
	return result


func update_item_list(result: bool, fish: Fish):
	for i in item_list.item_count:
		if fish.name == item_list.get_item_text(i):
			item_list.set_item_icon_modulate(i, Color.WHITE)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if $".".visible:
			$".".hide()
		else:
			$".".show()
		
