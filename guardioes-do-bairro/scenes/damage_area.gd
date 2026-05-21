extends Area2D

signal jogador_fora_da_tela

var _disparou: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _disparou:
		return
	if body.is_in_group("player"):
		_disparou = true
		jogador_fora_da_tela.emit()
