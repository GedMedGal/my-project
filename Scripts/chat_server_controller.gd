extends Node
class_name ChatController

signal message_received(text: String)


var ws := WebSocketPeer.new()
var connected := false

var server_hour: int = 0
var server_season: int = 0
var server_date := {}  # {"year": , "month": , "day": }

static var nick: String

func connect_to_server():
	var err = ws.connect_to_url(
		"wss://server-godot-5ghy.onrender.com"
	)
	print("Connect:", err)

func _process(delta):
	ws.poll()

	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN and not connected:
		connected = true
		nick = "Player" + str(randi() % 1000)
		join_chat(nick)

	while ws.get_available_packet_count() > 0:
		var pkt := ws.get_packet().get_string_from_utf8()
		var data = JSON.parse_string(pkt)
		if data:
			handle_message(data)

func join_chat(nick: String):
	ws.send_text(JSON.stringify({
		"type": "join",
		"name": nick
	}))

func send_message(text: String):
	if ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return

	ws.send_text(JSON.stringify({
		"type": "message",
		"text": text
	}))

func handle_message(data):
	match data.type:
		"message":
			message_received.emit(data.name + ": " + data.text)

		"system":
			message_received.emit("[SYSTEM] " + data.text)

		"time":
			server_hour = int(data.hour)
			EventBus.time_updated.emit(server_hour)

			server_season = int(data.season)
			EventBus.season_updated.emit(server_season)

			server_date = {
				"year": int(data.year),
				"month": int(data.month),
				"day": int(data.day)
			}
			EventBus.date_updated.emit(server_date.year, server_date.month, server_date.day)


func send_system_message(text: String):
	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		# Отправляем как сообщение типа system на сервер, чтобы все получили
		ws.send_text(JSON.stringify({
			"type": "system",
			"text": text
		}))
	else:
		# Если сервер недоступен, можно локально показать
		message_received.emit("[SYSTEM] " + text)
