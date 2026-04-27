extends CharacterBody2D

const VELOCIDADE := 180.0
const FORCA_PULO := -380.0
const GRAVIDADE := 900.0

@export var vidas_max: int = 3

var vidas: int = 3
var invulneravel: bool = false
var inventario: Array[int] = []

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer_invulneravel: Timer = $InvulnerabilidadeTimer

signal vida_alterada(vidas_atuais: int)
signal morreu
signal lixo_coletado(tipo: int)
signal descarte_feito(tipo: int, acertou: bool)

func _ready() -> void:
	add_to_group("player")
	vidas = vidas_max
	timer_invulneravel.one_shot = true
	timer_invulneravel.wait_time = 1.0
	timer_invulneravel.timeout.connect(_fim_invulnerabilidade)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta
	var direcao := Input.get_axis("ui_left", "ui_right")
	velocity.x = direcao * VELOCIDADE
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = FORCA_PULO
	move_and_slide()

func receber_dano(quantidade: int) -> void:
	if invulneravel:
		return
	vidas -= quantidade
	vida_alterada.emit(vidas)
	if vidas <= 0:
		morreu.emit()
		return
	invulneravel = true
	timer_invulneravel.start()
	_piscar()

func descartar_lixo(tipo_aceito: int) -> bool:
	var idx := inventario.find(tipo_aceito)
	if idx == -1:
		return false
	inventario.remove_at(idx)
	descarte_feito.emit(tipo_aceito, true)
	return true

func adicionar_lixo(tipo: int) -> void:
	inventario.append(tipo)
	lixo_coletado.emit(tipo)

func _fim_invulnerabilidade() -> void:
	invulneravel = false
	sprite.modulate.a = 1.0

func _piscar() -> void:
	var tween := create_tween().set_loops(5)
	tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)


func _on_descarte_feito(tipo: int, acertou: bool) -> void:
	pass # Replace with function body.


func _on_morreu() -> void:
	pass # Replace with function body.


func _on_lixo_coletado(tipo: int) -> void:
	pass # Replace with function body.


func _on_vida_alterada(vidas_atuais: int) -> void:
	pass # Replace with function body.
