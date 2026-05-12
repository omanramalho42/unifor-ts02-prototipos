extends Area2D

@export var dano: int = 1
@export var textura: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if textura:
		sprite.texture = textura
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("receber_dano"):
		body.receber_dano(dano)
