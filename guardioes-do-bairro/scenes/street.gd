extends Node2D

const VELOCIDADE_CAMERA := 60.0
const PENALIDADE := 30
const PONTOS_COLETA := 10
const PONTOS_DESCARTE := 50
const ESPERA_TRANSICAO := 5.0

@export var fim_fase_1_x: float = 3460.0
@export var fim_fase_2_x: float = 6920.0

@onready var camera: Camera2D = $Camera2D
@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var damage_area: Area2D = $DamageArea
@onready var coletaveis: Node = get_node_or_null("Coletaveis")
@onready var lixeiras: Node = get_node_or_null("Lixeiras")

var pontos: int = 0
var tempo: float = 0.0
var fase_terminou: bool = false
var fase_atual: int = 1
var parada_camera_x: float = 0.0
var camera_parou: bool = false
var transicionando: bool = false

func _ready() -> void:
	GameState.resetar()
	camera.make_current()
	parada_camera_x = _parada_para(fim_fase_1_x)

	# =========================================================
	# CONECTANDO OS COMANDOS DO WEBSOCKET/TCP AO PLAYER
	var network = get_node_or_null("/root/Main/WebSocket")
	
	if network and player:
		# Vincula os sinais emitidos pela rede com as funções internas do player.gd
		network.right.connect(player.mover_direita)
		network.left.connect(player.mover_esquerda)
		network.up.connect(player.mover_cima)
		network.take.connect(player.interagir_rede)
		network.stop.connect(player.parar_movimento) # Conecta a parada do botão
		print("Street.gd vinculou com sucesso as respostas do ESP32 ao Player!")
	else:
		print("Erro: NetworkController ou Player não foram encontrados na cena.")

	# =========================================================
	# OUTRAS CONEXÕES DO JOGO
	# =========================================================
	player.lixo_coletado.connect(_on_lixo_coletado)
	player.descarte_feito.connect(_on_descarte_feito)
	player.inventario_cheio.connect(_on_inventario_cheio)
	damage_area.jogador_fora_da_tela.connect(_on_jogador_fora_da_tela)

	if coletaveis:
		for c in coletaveis.get_children():
			if c.has_signal("coletado"):
				c.coletado.connect(player.adicionar_lixo)

	if lixeiras:
		for l in lixeiras.get_children():
			if l.has_signal("progresso_descarte"):
				l.progresso_descarte.connect(_on_progresso_descarte)
			if l.has_signal("descarte_terminou"):
				l.descarte_terminou.connect(_on_descarte_terminou)
			if l.has_signal("descarte_errado"):
				l.descarte_errado.connect(_on_descarte_errado)

	if hud.has_method("atualizar_pontuacao"):
		hud.atualizar_pontuacao(0)
	if hud.has_method("atualizar_cronometro"):
		hud.atualizar_cronometro(0.0)

func _process(delta: float) -> void:
	if fase_terminou:
		return

	tempo += delta
	if hud.has_method("atualizar_cronometro"):
		hud.atualizar_cronometro(tempo)

	if not camera_parou:
		camera.position.x = minf(camera.position.x + VELOCIDADE_CAMERA * delta, parada_camera_x)
		damage_area.position.x = camera.position.x
		if camera.position.x >= parada_camera_x:
			camera_parou = true
			_verificar_fim_de_fase()

func _parada_para(fim_x: float) -> float:
	return fim_x - get_viewport_rect().size.x / camera.zoom.x

func _on_lixo_coletado(tipo: int, textura: Texture2D) -> void:
	pontos += PONTOS_COLETA
	if hud.has_method("atualizar_pontuacao"):
		hud.atualizar_pontuacao(pontos)
	if hud.has_method("atualizar_inventario"):
		hud.atualizar_inventario(tipo, textura)

func _on_descarte_feito(tipo: int, textura: Texture2D, acertou: bool) -> void:
	if acertou:
		pontos += PONTOS_DESCARTE
		if hud.has_method("atualizar_pontuacao"):
			hud.atualizar_pontuacao(pontos)
		if hud.has_method("remover_inventario"):
			hud.remover_inventario(tipo, textura)
		_verificar_fim_de_fase()

func _verificar_fim_de_fase() -> void:
	if not camera_parou or not player.inventario.is_empty():
		return
	if transicionando:
		return
	transicionando = true
	if fase_atual == 1:
		_transicao_para_fase_2()
	else:
		_finalizar_fase_2()

func _transicao_para_fase_2() -> void:
	if hud.has_method("mostrar_aviso"):
		hud.mostrar_aviso("Continue! Mais lixo pela frente...")
	await get_tree().create_timer(ESPERA_TRANSICAO).timeout
	if fase_terminou:
		return
	if hud.has_method("esconder_aviso"):
		hud.esconder_aviso()
	fase_atual = 2
	parada_camera_x = _parada_para(fim_fase_2_x)
	camera_parou = false
	transicionando = false

func _finalizar_fase_2() -> void:
	if hud.has_method("mostrar_aviso"):
		hud.mostrar_aviso("Bairro limpo! Missão cumprida...")
	await get_tree().create_timer(ESPERA_TRANSICAO).timeout
	if fase_terminou:
		return
	if not player.inventario.is_empty():
		if hud.has_method("esconder_aviso"):
			hud.esconder_aviso()
		transicionando = false
		return
	_terminar_fase(true)

func _on_progresso_descarte(textura: Texture2D, fracao: float) -> void:
	if hud.has_method("atualizar_progresso_descarte"):
		hud.atualizar_progresso_descarte(textura, fracao)

func _on_descarte_terminou(textura: Texture2D) -> void:
	if hud.has_method("esconder_barra_descarte"):
		hud.esconder_barra_descarte(textura)

func _on_descarte_errado() -> void:
	pontos = maxi(0, pontos - PENALIDADE)
	if hud.has_method("atualizar_pontuacao"):
		hud.atualizar_pontuacao(pontos)
	if hud.has_method("chacoalhar_inventario"):
		hud.chacoalhar_inventario(Color(1, 0.3, 0.3))

func _on_inventario_cheio() -> void:
	if hud.has_method("chacoalhar_inventario"):
		hud.chacoalhar_inventario(Color(1, 0.85, 0.3))

func _on_jogador_fora_da_tela() -> void:
	_terminar_fase(false)

func _terminar_fase(venceu: bool) -> void:
	if fase_terminou:
		return
	fase_terminou = true
	GameState.tempo_final = tempo
	GameState.pontos_finais = pontos
	var destino := "res://prefabs/winner_screen.tscn" if venceu else "res://prefabs/game_over.tscn"
	get_tree().change_scene_to_file.call_deferred(destino)
