extends Control

@onready var voltar: Button = $Voltar

func _ready() -> void:
	voltar.pressed.connect(_on_voltar_pressed)

func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://prefabs/tittle_screen.tscn")
