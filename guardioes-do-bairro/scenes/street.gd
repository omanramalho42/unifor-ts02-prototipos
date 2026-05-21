extends Node2D

const VELOCIDADE_CAMERA := 60.0
const FIM_DA_FASE_X := 1300.0

@onready var camera: Camera2D = $Camera2D
@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var damage_area: Area2D = $DamageArea
@onready var coletaveis: Node = get_node_or_null("Coletaveis")
@onready var lixeiras: Node = get_node_or_null("Lixeiras")

var pontos: int = 0
var tempo: float = 0.0
var fase_terminou: bool = false

func _ready() -> void:
	GameState.resetar()
	camera.make_current()

	player.lixo_coletado.connect(_on_lixo_coletado)
	player.descarte_feito.connect(_on_descarte_feito)
	damage_area.jogador_fora_da_tela.connect(_on_jogador_fora_da_tela)

	if coletaveis:
		for c in coletaveis.get_children():
			if c.has_signal("coletado"):
				c.coletado.connect(player.adicionar_lixo)

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

	camera.position.x += VELOCIDADE_CAMERA * delta
	damage_area.position.x = camera.position.x

	if camera.position.x >= FIM_DA_FASE_X:
		_terminar_fase(true)

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
