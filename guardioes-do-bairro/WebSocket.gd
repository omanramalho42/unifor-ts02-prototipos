extends Node

var client: StreamPeerTCP
var connected = false
var txt = ""

# DECLARAÇÃO DE TODOS OS SINAIS QUE SEU COMDANDO PRECISA
signal left()
signal right()
signal up()
signal take()
signal stop() # Sinal crucial para fazer o player parar de andar!
signal down()
signal jump
signal store_start
signal store_cancel
const ip = "192.168.0.5" 
const port = 80

func _ready():
	client = StreamPeerTCP.new()
	client.set_no_delay(true)
	
	var error = client.connect_to_host(ip, port)
	if error == OK:
		print("Tentando conectar ao ESP32...")
	else:
		print("Erro imediato ao tentar iniciar a conexão: ", error)

func _process(delta):
	client.poll() 
	var status = client.get_status()
	
	if not connected:
		if status == StreamPeerTCP.STATUS_CONNECTED:
			connected = true
			print("Conectei com sucesso ao ESP32!")
		elif status == StreamPeerTCP.STATUS_ERROR or status == StreamPeerTCP.STATUS_NONE:
			print("Falha ao conectar ou conexão encerrada.")
			set_process(false)
	else:
		if status == StreamPeerTCP.STATUS_CONNECTED:
			_read_websocket()
		else:
			print("Conexão perdida com o ESP32.")
			connected = false

func _read_websocket():
	while client.get_available_bytes() > 0:
		var bytes_count = client.get_available_bytes()
		var message = client.get_utf8_string(bytes_count)
		
		if message == "":
			continue
			
		for i in message:
			if i == "\n":
				_message_interpreter(txt.strip_edges())
				txt = "" 
			else:
				txt = txt + i
func _message_interpreter(msg: String):

	if msg == "":
		return

	print("Mensagem recebida do ESP32: ", msg)

	var command: Array = msg.split(" ")

	if command.size() < 2:
		return

	var acao: String = str(command[0])
	var estado: String = str(command[1])

	# =====================================================
	# BOTÃO SOLTO
	# =====================================================

	if estado == "0":

		match acao:

			"DIREITA", "ESQUERDA", "UP", "CIMA", "BAIXO":
				emit_signal("stop")

			"TAKE":
				emit_signal("store_cancel")

		return

	# =====================================================
	# BOTÃO PRESSIONADO
	# =====================================================

	match acao:

		"DIREITA":
			emit_signal("right")

		"ESQUERDA":
			emit_signal("left")

		"UP", "CIMA":
			emit_signal("up")

		"BAIXO":
			emit_signal("down")

		"JUMP":
			emit_signal("jump")

		"TAKE":

			# interação normal
			emit_signal("take")

			# inicia HOLD de descarte
			emit_signal("store_start")

func _writeWebSocket(txt: String): 
	if connected and client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		client.put_data(txt.to_utf8_buffer())
