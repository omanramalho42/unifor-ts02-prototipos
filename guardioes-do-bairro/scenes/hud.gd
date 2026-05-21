extends CanvasLayer

@onready var cronometro: Label = $Control/Cronometro
@onready var pontuacao: Label = $Control/Pontuacao
@onready var inventario: HBoxContainer = $Control/Inventario

const TAMANHO_SLOT := Vector2(48, 48)

# Texture2D → { "slot": Control, "contagem": int }
var slots: Dictionary = {}

func atualizar_pontuacao(pontos: int) -> void:
	pontuacao.text = "Pontos: %d" % pontos

func atualizar_cronometro(segundos: float) -> void:
	var minutos := int(segundos) / 60
	var segs := int(segundos) % 60
	cronometro.text = "%02d:%02d" % [minutos, segs]

func atualizar_inventario(_tipo: int, textura: Texture2D) -> void:
	if not textura:
		return
	if slots.has(textura):
		slots[textura].contagem += 1
		_atualizar_label(textura)
	else:
		var slot := _criar_slot(textura)
		inventario.add_child(slot)
		slots[textura] = {"slot": slot, "contagem": 1}
		_atualizar_label(textura)

func remover_inventario(_tipo: int, textura: Texture2D) -> void:
	if not slots.has(textura):
		return
	slots[textura].contagem -= 1
	if slots[textura].contagem <= 0:
		slots[textura].slot.queue_free()
		slots.erase(textura)
	else:
		_atualizar_label(textura)

func _criar_slot(textura: Texture2D) -> Control:
	var box := VBoxContainer.new()
	box.custom_minimum_size = TAMANHO_SLOT
	var rect := TextureRect.new()
	rect.texture = textura
	rect.custom_minimum_size = TAMANHO_SLOT
	rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	box.add_child(rect)
	var label := Label.new()
	label.name = "Contagem"
	box.add_child(label)
	var barra := ProgressBar.new()
	barra.name = "Barra"
	barra.custom_minimum_size = Vector2(48, 6)
	barra.min_value = 0.0
	barra.max_value = 1.0
	barra.step = 0.01
	barra.show_percentage = false
	barra.visible = false
	box.add_child(barra)
	return box

func _atualizar_label(textura: Texture2D) -> void:
	var box: Control = slots[textura].slot
	var label := box.get_node("Contagem") as Label
	label.text = "x%d" % slots[textura].contagem

func atualizar_progresso_descarte(textura: Texture2D, fracao: float) -> void:
	if not textura or not slots.has(textura):
		return
	var barra := slots[textura].slot.get_node_or_null("Barra") as ProgressBar
	if not barra:
		return
	barra.value = fracao
	barra.visible = true

func esconder_barra_descarte(textura: Texture2D) -> void:
	if not textura or not slots.has(textura):
		return
	var barra := slots[textura].slot.get_node_or_null("Barra") as ProgressBar
	if not barra:
		return
	barra.value = 0.0
	barra.visible = false
