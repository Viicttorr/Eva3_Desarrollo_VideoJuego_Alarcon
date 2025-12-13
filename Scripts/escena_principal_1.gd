extends Node2D

func _ready():
	for child in get_children():
		if child is Enemy:
			child.direction = 1 if randf() > 0.5 else -1
