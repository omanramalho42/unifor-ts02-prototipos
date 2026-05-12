extends CharacterBody2D

const VELOCIDADE := 180.0
const PULO_ALTURA := 16.0
const PULO_DURACAO := 0.4

@export var vidas_max: int = 3

var vidas: int = 3
var invulneravel: bool = false
var pulando: bool = false
var inventario: Array[Dictionary] = []
var ultima_direcao: String = "down"
var tween_piscar: Tween
var coletavel_proximo: Node = null
var lixeira_proxima: Node = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer_invulneravel: Timer = $InvulnerabilidadeTimer

signal vida_alterada(vidas_atuais: int)
signal morreu
signal lixo_coletado(tipo: int, textura: Texture2D)
signal descarte_feito(tipo: int, textura: Texture2D, acertou: bool)

func _ready() -> void:
	add_to_group("player")
	vidas = vidas_max
	timer_invulneravel.one_shot = true
	timer_invulneravel.wait_time = 1.0
	timer_invulneravel.timeout.connect(_fim_invulnerabilidade)

func _physics_process(_delta: float) -> void:
	var direcao := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direcao * VELOCIDADE
	if Input.is_action_just_pressed("ui_accept") and not pulando:
		_pular()
	if Input.is_action_just_pressed("interagir"):
		_interagir()
	move_and_slide()
	_atualizar_animacao()

func _interagir() -> void:
	if coletavel_proximo and is_instance_valid(coletavel_proximo):
		coletavel_proximo.coletar()
		return
	if lixeira_proxima and is_instance_valid(lixeira_proxima):
		lixeira_proxima.depositar(self)

func _atualizar_animacao() -> void:
	var movendo := velocity.length() > 0.0
	if movendo:
		if absf(velocity.x) >= absf(velocity.y):
			ultima_direcao = "right" if velocity.x > 0.0 else "left"
		else:
			ultima_direcao = "down" if velocity.y > 0.0 else "up"
	var prefixo := "walk_" if movendo else "idle_"
	sprite.play(prefixo + ultima_direcao)
	sprite.flip_h = ultima_direcao == "left"

func _pular() -> void:
	pulando = true
	invulneravel = true
	var y_inicial := sprite.position.y
	var tween := create_tween()
	tween.tween_property(sprite, "position:y", y_inicial - PULO_ALTURA, PULO_DURACAO / 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "position:y", y_inicial, PULO_DURACAO / 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_fim_pulo)

func _fim_pulo() -> void:
	pulando = false
	if not timer_invulneravel.time_left > 0:
		invulneravel = false

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
	for i in inventario.size():
		if inventario[i].tipo == tipo_aceito:
			var textura: Texture2D = inventario[i].textura
			inventario.remove_at(i)
			descarte_feito.emit(tipo_aceito, textura, true)
			return true
	descarte_feito.emit(tipo_aceito, null, false)
	return false

func adicionar_lixo(tipo: int, textura: Texture2D) -> void:
	inventario.append({"tipo": tipo, "textura": textura})
	lixo_coletado.emit(tipo, textura)

func _fim_invulnerabilidade() -> void:
	if not pulando:
		invulneravel = false
	sprite.modulate.a = 1.0

func _piscar() -> void:
	if tween_piscar and tween_piscar.is_valid():
		tween_piscar.kill()
	tween_piscar = create_tween().set_loops(5)
	tween_piscar.tween_property(sprite, "modulate:a", 0.3, 0.1)
	tween_piscar.tween_property(sprite, "modulate:a", 1.0, 0.1)


func _on_descarte_feito(tipo: int, textura: Texture2D, acertou: bool) -> void:
	pass


func _on_morreu() -> void:
	pass


func _on_lixo_coletado(tipo: int, textura: Texture2D) -> void:
	pass


func _on_vida_alterada(vidas_atuais: int) -> void:
	pass
