extends Area2D

enum CorLixeira { AZUL, AMARELA, VERMELHA, VERDE, MARROM }

 # Mapeia cada cor da lixeira ao tipo de lixo que ela aceita
const COR_PARA_TIPO := {
	CorLixeira.AZUL: 0,      # PAPEL
	CorLixeira.AMARELA: 1,   # METAL
	CorLixeira.VERMELHA: 2,  # PLASTICO
	CorLixeira.VERDE: 3,     # VIDRO
	CorLixeira.MARROM: 4,    # ORGANICO
 }

@export var cor: CorLixeira = CorLixeira.AZUL
@export var textura: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt: Label = $Prompt

signal lixo_depositado(tipo_aceito: int, acertou: bool)

func _ready() -> void:
	if textura:
		sprite.texture = textura
	prompt.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.lixeira_proxima = self
		prompt.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.lixeira_proxima == self:
			body.lixeira_proxima = null
		prompt.visible = false

func depositar(player: Node) -> void:
	var tipo_aceito: int = COR_PARA_TIPO[cor]
	var acertou: bool = player.descartar_lixo(tipo_aceito)
	lixo_depositado.emit(tipo_aceito, acertou)


func _on_lixo_depositado(tipo_aceito: int, acertou: bool) -> void:
	pass
