extends Node2D

const VELOCIDADE_CAMERA := 60.0
const FIM_CENARIO_X := 3460.0

@onready var camera: Camera2D = $Camera2D
@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var damage_area: Area2D = $DamageArea
@onready var coletaveis: Node = get_node_or_null("Coletaveis")
@onready var lixeiras: Node = get_node_or_null("Lixeiras")

var pontos: int = 0
var tempo: float = 0.0
var fase_terminou: bool = false
var parada_camera_x: float = FIM_CENARIO_X
var camera_parou: bool = false

func _ready() -> void:
	GameState.resetar()
	camera.make_current()
	parada_camera_x = FIM_CENARIO_X - get_viewport_rect().size.x / camera.zoom.x

	player.lixo_coletado.connect(_on_lixo_coletado)
	player.descarte_feito.connect(_on_descarte_feito)
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
			_verificar_vitoria()

func _on_lixo_coletado(tipo: int, textura: Texture2D) -> void:
	if hud.has_method("atualizar_inventario"):
		hud.atualizar_inventario(tipo, textura)

func _on_descarte_feito(tipo: int, textura: Texture2D, acertou: bool) -> void:
	if acertou:
		pontos += 100
		if hud.has_method("atualizar_pontuacao"):
			hud.atualizar_pontuacao(pontos)
		if hud.has_method("remover_inventario"):
			hud.remover_inventario(tipo, textura)
		_verificar_vitoria()

func _verificar_vitoria() -> void:
	if camera_parou and player.inventario.is_empty():
		_terminar_fase(true)

func _on_progresso_descarte(textura: Texture2D, fracao: float) -> void:
	if hud.has_method("atualizar_progresso_descarte"):
		hud.atualizar_progresso_descarte(textura, fracao)

func _on_descarte_terminou(textura: Texture2D) -> void:
	if hud.has_method("esconder_barra_descarte"):
		hud.esconder_barra_descarte(textura)

func _on_jogador_fora_da_tela() -> void:
	_terminar_fase(false)

func _terminar_fase(venceu: bool) -> void:
	if fase_terminou:
		return
	fase_terminou = true
	GameState.tempo_final = tempo
	GameState.pontos_finais = pontos
	var destino := "res://prefabs/winner_screen.tscn" if venceu else "res://prefabs/game_over.tscn"
	get_tree().change_scene_to_file(destino)
