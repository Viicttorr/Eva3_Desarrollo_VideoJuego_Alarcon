extends Area2D

var transicion_activa := false

func activar_transicion():
	transicion_activa = true

func _on_body_entered(body: Node2D) -> void:
	if transicion_activa and body is CharacterBody2D:
		$Timer_transicion.start()
		
func _on_timer_timeout():
	get_tree().change_scene_to_file("res://Escenas/escena_principal-2.tscn")
	
