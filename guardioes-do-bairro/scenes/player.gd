extends CharacterBody2D

const VELOCIDADE := 180.0
const PULO_ALTURA := 16.0
const PULO_DURACAO := 0.4

var pulando: bool = false
var inventario: Array[Dictionary] = []
var ultima_direcao: String = "down"
var coletavel_proximo: Node = null
var lixeira_proxima: Node = null

# Vetor controlado pelos comandos recebidos da rede física
var direcao_rede := Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

signal lixo_coletado(tipo: int, textura: Texture2D)
signal descarte_feito(tipo: int, textura: Texture2D, acertou: bool)

func _ready() -> void:
	add_to_group("player")
# Procurando o nó de rede na cena e conectando os sinais
	# NOTA: Ajuste o caminho "/root/Main/NetworkController" para onde seu nó de rede real está!
	if WebSocket:
		# Conecta os sinais globais do seu ESP32 diretamente nas funções atuais do Player
		if WebSocket.has_signal("right"): WebSocket.right.connect(mover_direita)
		if WebSocket.has_signal("left"): WebSocket.left.connect(mover_esquerda)
		if WebSocket.has_signal("up"): WebSocket.up.connect(mover_cima)
		if WebSocket.has_signal("down"): WebSocket.down.connect(mover_baixo)
		if WebSocket.has_signal("take"): WebSocket.take.connect(interagir_rede)
		if WebSocket.has_signal("jump"): WebSocket.jump.connect(pular_rede)
		if WebSocket.has_signal("stop"): WebSocket.stop.connect(parar_movimento)
		
		print("Player conectado aos sinais físicos do ESP32!")
		print("Player conectado aos sinais físicos do ESP32!")
	else:
		print("Aviso: NetworkController não foi encontrado na cena.")
	print("Player conectado aos sinais físicos do ESP32!")
	
func _physics_process(_delta: float) -> void:
# =====================================================
	# MOVIMENTO VIA ESP32
	# =====================================================

	var direcao := direcao_rede

	# fallback teclado caso ESP32 não envie nada
	if direcao == Vector2.ZERO:
		direcao = Input.get_vector(
			"ui_left",
			"ui_right",
			"ui_up",
			"ui_down"
		)

	velocity = direcao * VELOCIDADE

	# =====================================================
	# INPUT LOCAL (TECLADO)
	# =====================================================

	if Input.is_action_just_pressed("ui_accept") and not pulando:
		_pular()

	if Input.is_action_just_pressed("interagir"):
		_interagir()

	# =====================================================
	# MOVIMENTAÇÃO
	# =====================================================

	move_and_slide()

	# =====================================================
	# ANIMAÇÃO
	# =====================================================

	_atualizar_animacao()

# =========================================================
# FUNÇÕES RECEBIDAS DO ESP32
# =========================================================

func mover_direita():
	direcao_rede = Vector2.RIGHT

func mover_esquerda():
	direcao_rede = Vector2.LEFT

func mover_cima():
	direcao_rede = Vector2.UP

func mover_baixo():
	direcao_rede = Vector2.DOWN

func parar_movimento():
	direcao_rede = Vector2.ZERO

func pular_rede():
	if not pulando:
		_pular()

func interagir_rede():
	_interagir()

func _interagir() -> void:
	if coletavel_proximo and is_instance_valid(coletavel_proximo):
		coletavel_proximo.coletar()

# =========================================================
# ANIMAÇÕES
# =========================================================

func _atualizar_animacao() -> void:
	var movendo := velocity.length() > 0.0
	if movendo:
		if absf(velocity.x) >= absf(velocity.y):
			ultima_direcao = "right" if velocity.x > 0.0 else "left"
		else:
			ultima_direcao = "down" if velocity.y > 0.0 else "up"
	var prefixo := "walk_" if movendo else "idle_"
	sprite.play(prefixo + ultima_direcao)
	sprite.flip_h = ultima_direcao == "left"

# =========================================================
# PULO
# =========================================================

func _pular() -> void:
	pulando = true

	var y_inicial := sprite.position.y

	var tween := create_tween()

	tween.tween_property(
		sprite,
		"position:y",
		y_inicial - PULO_ALTURA,
		PULO_DURACAO / 2.0
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		sprite,
		"position:y",
		y_inicial,
		PULO_DURACAO / 2.0
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tween.tween_callback(_fim_pulo)

func _fim_pulo() -> void:
	pulando = false

# =========================================================
# INVENTÁRIO
# =========================================================

func descartar_lixo(tipo_aceito: int) -> bool:
	for i in inventario.size():

		if inventario[i].tipo == tipo_aceito:

			var textura: Texture2D = inventario[i].textura

			inventario.remove_at(i)

			descarte_feito.emit(tipo_aceito, textura, true)

			return true

	descarte_feito.emit(tipo_aceito, null, false)

	return false

func adicionar_lixo(tipo: int, textura: Texture2D) -> void:
	inventario.append({
		"tipo": tipo,
		"textura": textura
	})

	lixo_coletado.emit(tipo, textura)

func proxima_textura_descartavel(tipo_aceito: int) -> Texture2D:
	for item in inventario:

		if item.tipo == tipo_aceito:
			return item.textura

	return null

# =========================================================
# CALLBACKS
# =========================================================

func _on_descarte_feito(tipo: int, textura: Texture2D, acertou: bool) -> void:
	pass

func _on_lixo_coletado(tipo: int, textura: Texture2D) -> void:
	pass
