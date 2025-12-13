extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		get_parent().get_node("Area_transicion").activar_transicion()
