extends Control


func _on_startbtn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/collectible.tscn")


func _on_creditsbtn_pressed() -> void:
	pass # Replace with function body.


func _on_quitgamebtn_pressed() -> void:
	get_tree().quit()
