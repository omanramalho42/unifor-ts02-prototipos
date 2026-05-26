extends Control


func _on_startbtn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/street.tscn")


func _on_creditsbtn_pressed() -> void:
	get_tree().change_scene_to_file("res://prefabs/credits.tscn")

func _on_quitgamebtn_pressed() -> void:
	get_tree().quit()
