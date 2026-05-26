extends Control


func _ready() -> void:
	var resultado := find_child("Resultado") as Label
	if resultado:
		var minutos := int(GameState.tempo_final) / 60
		var segs := int(GameState.tempo_final) % 60
		resultado.text = "Tempo: %02d:%02d   Pontos: %d" % [minutos, segs, GameState.pontos_finais]


func _on_restart_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/street.tscn")


func _on_quit_btn_pressed() -> void:
	get_tree().quit()
