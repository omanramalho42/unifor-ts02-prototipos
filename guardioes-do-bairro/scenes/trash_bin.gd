extends Area2D

enum TipoLixo { PAPEL, METAL, PLASTICO, VIDRO, ORGANICO }

@export var tipo: TipoLixo = TipoLixo.PAPEL
@export var textura: Texture2D
@export var duracao_min: float = 1.0
@export var duracao_max: float = 2.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt: Label = $Prompt

signal lixo_depositado(tipo_aceito: int, acertou: bool)
signal progresso_descarte(textura_lixo: Texture2D, fracao: float)
signal descarte_terminou(textura_lixo: Texture2D)

var _player_proximo: Node = null
var _descartando: bool = false
var _progresso: float = 0.0
var _duracao_atual: float = 1.0
var _textura_lixo: Texture2D = null

func _ready() -> void:
	if textura:
		sprite.texture = textura
	prompt.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	set_process(false)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.lixeira_proxima = self
		_player_proximo = body
		prompt.visible = true
		set_process(true)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.lixeira_proxima == self:
			body.lixeira_proxima = null
		if _descartando:
			_cancelar()
		_player_proximo = null
		prompt.visible = false
		set_process(false)

func _process(delta: float) -> void:
	if not _player_proximo:
		return
	if Input.is_action_pressed("interagir"):
		if not _descartando:
			_iniciar()
		if _descartando:
			_progresso += delta / _duracao_atual
			progresso_descarte.emit(_textura_lixo, clampf(_progresso, 0.0, 1.0))
			if _progresso >= 1.0:
				_completar()
	elif _descartando:
		_cancelar()

func _iniciar() -> void:
	if not _player_proximo or not _player_proximo.has_method("proxima_textura_descartavel"):
		return
	var textura_lixo: Texture2D = _player_proximo.proxima_textura_descartavel(tipo)
	if not textura_lixo:
		return
	_textura_lixo = textura_lixo
	_duracao_atual = randf_range(duracao_min, duracao_max)
	_progresso = 0.0
	_descartando = true

func _cancelar() -> void:
	var t := _textura_lixo
	_descartando = false
	_progresso = 0.0
	_textura_lixo = null
	descarte_terminou.emit(t)

func _completar() -> void:
	var acertou: bool = _player_proximo.descartar_lixo(tipo)
	var t := _textura_lixo
	_descartando = false
	_progresso = 0.0
	_textura_lixo = null
	descarte_terminou.emit(t)
	lixo_depositado.emit(tipo, acertou)


func _on_lixo_depositado(tipo_aceito: int, acertou: bool) -> void:
	pass
