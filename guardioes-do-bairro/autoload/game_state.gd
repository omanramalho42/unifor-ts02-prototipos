extends Node

# Singleton (autoload) que guarda dados que precisam atravessar
# trocas de cena — tempo final, pontos finais, etc.

var tempo_final: float = 0.0
var pontos_finais: int = 0

func resetar() -> void:
	tempo_final = 0.0
	pontos_finais = 0
