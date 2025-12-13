extends Control

func _on_button_victoria_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/menu_principal.tscn")
	
	
func _on_quit_victoria_pressed() -> void:
	get_tree().quit()
