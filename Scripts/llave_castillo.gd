extends Area2D

func _on_body_entered(body):
	if body is Player:
		Global.tiene_llave = true
		var hud = get_tree().root.get_node("/root/Escena_Principal_2/HUD")
		hud.get_node("LlaveIcono").visible = true
		queue_free() # la llave desaparece al recogerla
