extends Area2D

signal jogador_fora_da_tela

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		jogador_fora_da_tela.emit()
