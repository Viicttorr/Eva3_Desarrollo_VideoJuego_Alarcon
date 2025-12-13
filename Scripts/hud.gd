extends CanvasLayer

@onready var numero: RichTextLabel = $Numero

func _process(_delta):
	var texto = "PLAYER "
	for i in range(Global.vidas):
		texto += "[img=32x32]res://Sprite/corazon/Corazon_vida.png[/img]"
	numero.bbcode_text = texto
