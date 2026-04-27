extends Area2D

enum TipoLixo { PAPEL, METAL, PLASTICO, VIDRO, ORGANICO }

@export var tipo: TipoLixo = TipoLixo.PAPEL
@export var textura: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

signal coletado(tipo: TipoLixo)

func _ready() -> void:
	if textura:
		sprite.texture = textura
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		coletado.emit(tipo)
		queue_free()


func _on_coletado(tipo: int) -> void:
	pass # Replace with function body.
