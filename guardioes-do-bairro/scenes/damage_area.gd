extends Area2D

@export var dano: int = 1
@export var intervalo: float = 0.5

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = intervalo
	timer.one_shot = false
	timer.timeout.connect(_aplicar_dano)
	timer.start()

func _aplicar_dano() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("receber_dano"):
			body.receber_dano(dano)
