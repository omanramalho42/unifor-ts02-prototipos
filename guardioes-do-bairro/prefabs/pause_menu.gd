extends CanvasLayer

@onready var resume_btn = $menu_holder/pause_btn

func _ready() -> void:
	visible = false
	
func _process(delta) -> void:
	pass

func _on_pause_btn_pressed() -> void:
	get_tree().paused = false
	visible = false
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		visible = true
		get_tree().paused = true
		resume_btn.grab_focus()

func _on_quit_btn_pressed() -> void:
	get_tree().quit()
