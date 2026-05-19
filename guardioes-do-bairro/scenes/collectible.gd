extends Area2D

enum TipoLixo { PAPEL, METAL, PLASTICO, VIDRO, ORGANICO }

@export var tipo: TipoLixo = TipoLixo.PAPEL
@export var textura: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt: Label = $Prompt

signal coletado(tipo: int, textura: Texture2D)

func _ready() -> void:
	if textura:
		sprite.texture = textura
	prompt.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.coletavel_proximo = self
		prompt.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.coletavel_proximo == self:
			body.coletavel_proximo = null
		prompt.visible = false

func coletar() -> void:
	coletado.emit(tipo, textura)
	queue_free()


func _on_coletado(tipo: int, textura: Texture2D) -> void:
	pass
