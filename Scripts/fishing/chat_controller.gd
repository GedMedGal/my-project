extends Control

@onready var chat = $ChatController
@onready var logs := [$MiniPanel/RichTextLabel, $MainPanel/RichTextLabel2]
@onready var input = $MainPanel/LineEdit

var max_messages = 10
var messages = []  # массив словарей: {text:String, color:Color}

func _ready():
	# Подписка на сигналы
	EventBus.end_cathing.connect(on_end_catching)
	chat.message_received.connect(on_message_received)
	input.text_submitted.connect(_on_Input_text_submitted)

func _on_Input_text_submitted(new_text):
	if new_text == "":
		return
	chat.send_message(new_text)
	input.text = ""

# ----- Добавляем обычное сообщение -----
func on_message_received(text: String):
	add_line(text, Color(1,1,1))  # белый цвет для обычного чата

# ----- Добавляем системное сообщение -----
func on_end_catching(result: bool, fish: Fish) -> void:
	if result and fish:
		var player_name = ChatController.nick # здесь можно взять реальное имя игрока, если есть
		var msg = "%s caught %s!" % [player_name, fish.name]
		chat.send_system_message(msg)

# ----- Добавление строки в массив и обновление логов -----
func add_line(text: String, color: Color):
	# Сохраняем сообщение и цвет
	messages.append({"text": text, "color": color})
	if messages.size() > max_messages:
		messages.pop_front()

	# Обновляем все RichTextLabel
	for log in logs:
		log.clear()
		for msg in messages:
			log.push_color(msg.color)
			log.add_text(msg.text + "\n")
			log.pop()
		log.scroll_to_line(log.get_line_count())


func _on_MINI_button_pressed() -> void:
	$TouchBlocker.mouse_filter = Control.MOUSE_FILTER_STOP 
	$MiniPanel.hide() 
	$MainPanel.show() 
	
	
func _on_MAIN_button_pressed() -> void: 
	$TouchBlocker.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	$MainPanel.hide() 
	$MiniPanel.show()
