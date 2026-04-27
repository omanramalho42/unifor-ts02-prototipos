extends Control

@onready var botao: Button = $Button

func _ready() -> void:
	botao.pressed.connect(_on_botao_pressed)

func _on_botao_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/street.tscn")
