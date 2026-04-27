extends CanvasLayer

@onready var cronometro: Label = $Control/Cronometro
@onready var pontuacao: Label = $Control/Pontuacao
@onready var inventario: HBoxContainer = $Control/Inventario
@onready var vidas: HBoxContainer = $Control/Vidas

# Conta quantos itens de cada tipo o player tem
# Índices: 0=PAPEL, 1=METAL, 2=PLASTICO, 3=VIDRO, 4=ORGANICO
var contagem_inventario: Array[int] = [0, 0, 0, 0, 0]

func atualizar_vidas(quantidade: int) -> void:
	for i in vidas.get_child_count():
		var coracao := vidas.get_child(i) as CanvasItem
		if coracao:
			coracao.visible = i < quantidade

func atualizar_pontuacao(pontos: int) -> void:
	pontuacao.text = "Pontos: %d" % pontos

func atualizar_cronometro(segundos: float) -> void:
	var minutos := int(segundos) / 60
	var segs := int(segundos) % 60
	cronometro.text = "%02d:%02d" % [minutos, segs]

func atualizar_inventario(tipo: int) -> void:
	if tipo < 0 or tipo >= contagem_inventario.size():
		return
	contagem_inventario[tipo] += 1
	_refresh_slot(tipo)

func remover_inventario(tipo: int) -> void:
	if tipo < 0 or tipo >= contagem_inventario.size():
		return
	contagem_inventario[tipo] = max(0, contagem_inventario[tipo] - 1)
	_refresh_slot(tipo)

func _refresh_slot(tipo: int) -> void:
	if tipo >= inventario.get_child_count():
		return
	var slot := inventario.get_child(tipo) as CanvasItem
	if not slot:
		return
	if contagem_inventario[tipo] > 0:
		slot.modulate = Color.WHITE
	else:
		slot.modulate = Color(1, 1, 1, 0.3)
