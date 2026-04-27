extends Control

@onready var botao: Button = $Button
@onready var label: Label = $Label

const CURIOSIDADES := [
	"Uma garrafa PET leva 400 anos para se decompor.",
	"O lixo orgânico pode virar adubo em poucos meses.",
	"Reciclar uma lata de aluminio economiza energia para 3 horas de TV.",
	"O Brasil produz mais de 80 milhões de toneladas de lixo por ano.",
]

func _ready() -> void:
	botao.pressed.connect(_on_botao_pressed)
	label.text = CURIOSIDADES.pick_random()

func _on_botao_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
