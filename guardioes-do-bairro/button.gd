extends Button

func _ready():
	pass
	
func on_button_toggled():
	if(button_pressed):
		WebSocket._writeWebSocket("ON\n")
	else:
		WebSocket._writeWebSocket("OFF\n")
