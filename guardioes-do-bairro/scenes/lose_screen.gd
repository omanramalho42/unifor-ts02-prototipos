extends Control

@onready var botao: Button = $Button
@onready var label: Label = $Label
@onready var subtitulo: Label = $Subtitulo
@onready var musica: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	botao.pressed.connect(_on_botao_pressed)
	botao.text = "Reiniciar"
	label.text = "Que pena!"
	subtitulo.text = "João não conseguiu o emprego de limpador da cidade."
	if musica.stream:
		musica.play()

func _on_botao_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/street.tscn")
