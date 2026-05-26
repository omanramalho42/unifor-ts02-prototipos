extends CharacterBody2D

const VELOCIDADE := 180.0
const PULO_ALTURA := 16.0
const PULO_DURACAO := 0.4
const LIMITE_SLOTS := 3

var pulando: bool = false
var inventario: Array[Dictionary] = []
var ultima_direcao: String = "down"
var coletavel_proximo: Node = null
var lixeira_proxima: Node = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

signal lixo_coletado(tipo: int, textura: Texture2D)
signal descarte_feito(tipo: int, textura: Texture2D, acertou: bool)
signal inventario_cheio

func _ready() -> void:
	add_to_group("player")

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
		if _pode_coletar(coletavel_proximo.textura):
			coletavel_proximo.coletar()
		else:
			inventario_cheio.emit()

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
	var y_inicial := sprite.position.y
	var tween := create_tween()
	tween.tween_property(sprite, "position:y", y_inicial - PULO_ALTURA, PULO_DURACAO / 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "position:y", y_inicial, PULO_DURACAO / 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_fim_pulo)

func _fim_pulo() -> void:
	pulando = false

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

func proxima_textura_descartavel(tipo_aceito: int) -> Texture2D:
	for item in inventario:
		if item.tipo == tipo_aceito:
			return item.textura
	return null

func _texturas_distintas() -> Array:
	var ts := []
	for item in inventario:
		if not ts.has(item.textura):
			ts.append(item.textura)
	return ts

func _pode_coletar(textura: Texture2D) -> bool:
	var distintas := _texturas_distintas()
	return distintas.has(textura) or distintas.size() < LIMITE_SLOTS


func _on_descarte_feito(tipo: int, textura: Texture2D, acertou: bool) -> void:
	pass


func _on_lixo_coletado(tipo: int, textura: Texture2D) -> void:
	pass
