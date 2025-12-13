extends Control
	
func _on_button_principal_start_pressed() -> void:
	Global.vidas = 3
	Global.nivel = 1
	get_tree().change_scene_to_file("res://Escenas/escena_principal-1.tscn")
	
	
func _on_quit_principal_pressed() -> void:
	get_tree().quit()
