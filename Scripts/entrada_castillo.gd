extends Area2D

func _on_body_entered(body):
	if body is Player and Global.tiene_llave:
		$Timer_entradaCastillo.start()
		
		
func _on_timer_timeout():
	get_tree().call_deferred("change_scene_to_file","res://Escenas/menu_victoria.tscn")
	
	
	
	
		
