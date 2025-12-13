extends Node2D

func _ready():
	for child in get_children():
		if child is Enemy:
			child.direction = 1 if randf() > 0.5 else -1
			
			
	var enemigos = []
	for child in get_children():
		if child is Enemy: # revisa cada hijo de la escena
			enemigos.append(child)
	if enemigos.size() > 0:
		var indice = randi() % enemigos.size()
		enemigos[indice].tiene_llave = true
