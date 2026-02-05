extends Node
class_name ChatController

signal message_received(text: String)

# ================== CONFIG ==================
const SERVER_URL := "wss://server-godot-5ghy.onrender.com"
const PING_INTERVAL := 10.0
const RECONNECT_COOLDOWN := 2.0
const MAX_PENDING := 10

# ================== STATE ==================
var ws: WebSocketPeer = null
var connected := false
var reconnecting := false
var last_reconnect_time := 0.0

var pending_messages: Array[String] = []

# ================== SERVER DATA ==================
var server_hour: int = 0
var server_season: int = 0
var server_date := {}

static var nick: String

# ================== LIFECYCLE ==================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	randomize()

	nick = "Player" + str(randi() % 1000)

	_create_ping_timer()
	_connect_new_socket()

func _process(_delta):
	if ws == null:
		_try_reconnect()
		return

	ws.poll()
	var state := ws.get_ready_state()

	# ---- CLOSED ----
	if state == WebSocketPeer.STATE_CLOSED:
		if connected:
			print("[WS] closed")
		_cleanup_socket()
		return

	# ---- OPEN ----
	if state == WebSocketPeer.STATE_OPEN and not connected:
		connected = true
		reconnecting = false
		print_debug("[WS] connected")

		_join_chat()
		_flush_pending()

	# ---- INCOMING ----
	while ws.get_available_packet_count() > 0:
		var pkt := ws.get_packet().get_string_from_utf8()
		var data = JSON.parse_string(pkt)
		if data:
			_handle_message(data)

# ================== SOCKET ==================
func _connect_new_socket():
	if ws != null:
		return # ❗ НЕ создаём второй сокет
	print(ws)
	ws = WebSocketPeer.new()
	var err = ws.connect_to_url(SERVER_URL)
	print("[WS] connect:", err)

func _cleanup_socket():
	if ws != null:
		ws.close()
	ws = null
	connected = false
	reconnecting = false

# ================== JOIN ==================
func _join_chat():
	ws.send_text(JSON.stringify({
		"type": "join",
		"name": nick
	}))

# ================== SEND ==================
func send_message(text: String):
	if text.strip_edges() == "":
		return

	if ws == null or ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		_queue_message(text)
		return

	ws.send_text(JSON.stringify({
		"type": "message",
		"text": text
	}))

func send_system_message(text: String):
	if ws != null and ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		ws.send_text(JSON.stringify({
			"type": "system",
			"text": text
		}))
	else:
		message_received.emit("[SYSTEM] " + text)

# ================== RECONNECT ==================
func _try_reconnect():
	var now := Time.get_ticks_msec() / 1000.0

	if reconnecting:
		return
	if now - last_reconnect_time < RECONNECT_COOLDOWN:
		return

	last_reconnect_time = now
	reconnecting = true

	print("[WS] reconnecting...")

	_cleanup_socket()        # ❗ ВАЖНО
	_connect_new_socket()    # ❗ только после cleanup

# ================== QUEUE ==================
func _queue_message(text: String):
	pending_messages.append(text)
	if pending_messages.size() > MAX_PENDING:
		pending_messages.pop_front()

func _flush_pending():
	for msg in pending_messages:
		ws.send_text(JSON.stringify({
			"type": "message",
			"text": msg
		}))
	pending_messages.clear()

# ================== PING ==================
func _create_ping_timer():
	var t := Timer.new()
	t.wait_time = PING_INTERVAL
	t.autostart = true
	t.one_shot = false
	t.timeout.connect(_send_ping)
	add_child(t)

func _send_ping():
	if ws != null and ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		ws.send_text(JSON.stringify({
			"type": "ping",
			"client_time": Time.get_unix_time_from_system()
		}))

# ================== HANDLE INCOMING ==================
func _handle_message(data):
	match data.type:
		"message":
			message_received.emit(data.name + ": " + data.text)

		"system":
			message_received.emit("[SYSTEM] " + data.text)

		"time":
			server_hour = int(data.hour)
			server_season = int(data.season)
			server_date = {
				"year": int(data.year),
				"month": int(data.month),
				"day": int(data.day)
			}

			EventBus.time_updated.emit(server_hour)
			EventBus.season_updated.emit(server_season)
			EventBus.date_updated.emit(
				server_date.year,
				server_date.month,
				server_date.day
			)
