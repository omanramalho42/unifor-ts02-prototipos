extends Control

@onready var botao: Button = $Button
@onready var label_titulo: Label = $Label
@onready var label_tempo: Label = $Label2
@onready var label_mensagem: Label = $Label3
@onready var musica: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	botao.pressed.connect(_on_botao_pressed)
	botao.text = "Jogar Novamente"
	label_titulo.text = "Você Venceu!"

	var minutos := int(GameState.tempo_final) / 60
	var segs := int(GameState.tempo_final) % 60
	label_tempo.text = "Tempo: %02d:%02d  |  Pontos: %d" % [minutos, segs, GameState.pontos_finais]
	label_mensagem.text = "Pequenas atitudes diárias transformam a comunidade inteira!"

	if musica.stream:
		musica.play()

func _on_botao_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
