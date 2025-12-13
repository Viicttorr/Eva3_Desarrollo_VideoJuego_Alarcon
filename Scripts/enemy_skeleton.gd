extends CharacterBody2D

class_name Enemy

const SPEED = 100.0
const GRAVITY = 800.0
var direction = 1
var estado = "patrullar"
var objetivo: Player = null
var vida = 100
@onready var barra_vida = $BarraVida
var muerto = false
var jugador_objetivo = null
var tiene_llave = false


func _ready():
	barra_vida.max_value = vida
	barra_vida.value = vida
	
	$Sprite_skeleton_L.frame_changed.connect(_on_frame_changed)
	$Sprite_skeleton_R.frame_changed.connect(_on_frame_changed)


func _physics_process(delta):
	if muerto:
		return
	velocity.y += GRAVITY * delta

	if $RayCast2D.is_colliding():
		var obj = $RayCast2D.get_collider()
		if obj is Player and objetivo == null:
			estado = "perseguir"
			objetivo = obj
	
	match estado:
		"patrullar":
			patrullar()
		"perseguir":
			perseguir()
	
	
	actualizar_direccion_visual()		
	move_and_slide()
			
func patrullar():
	if direction == -1:
		actualizar_direccion_visual()		
		$Sprite_skeleton_L.play("Walk")
		velocity.x = direction * (SPEED/2)
		objetivo = null
			
	elif direction == 1:
		actualizar_direccion_visual()
		$Sprite_skeleton_R.play("Walk")
		velocity.x = direction * (SPEED/2)
		objetivo = null

func perseguir():
	if not objetivo:
		estado = "patrullar"
		return

	var dx = objetivo.global_position.x - global_position.x
	if abs(dx) > 5:
		direction = sign(dx)
	
	velocity.x = direction * (SPEED/1.33)

	# si el jugador se escapa deja de perseguir
	#if abs(objetivo.global_position.x - global_position.x) > 101:
	var distancia = global_position.distance_to(objetivo.global_position)
	if distancia > 150:
		estado = "patrullar"
		objetivo = null
		
		
func _on_AttackArea_body_entered(body):
	if body is Player:
		jugador_objetivo = body
		if direction == -1:
			$Sprite_skeleton_L.play("Attack")
		elif direction == 1:
			$Sprite_skeleton_R.play("Attack")
	
		
func _on_AttackArea_body_exited(body):
	if objetivo == null and direction == -1:
		estado = "perseguir"
		
	elif objetivo == null and direction == 1:
		estado = "perseguir"
		
	if body == jugador_objetivo:
		jugador_objetivo = null
		

func _on_area_deteccion_body_entered(body: Node2D) -> void:
	if body is StaticBody2D and direction == -1:
		direction = 1
		
	elif body is StaticBody2D and direction == 1:
		direction = -1
		

func actualizar_direccion_visual():
	if direction == -1:
		$Sprite_skeleton_L.visible = true
		$Sprite_skeleton_R.visible = false
		$RayCast2D.target_position = Vector2(-100, 0)
	else:
		$Sprite_skeleton_L.visible = false
		$Sprite_skeleton_R.visible = true
		$RayCast2D.target_position = Vector2(100, 0)
		
		
func recibir_daño(cantidad):
	if muerto:
		return
	vida -= cantidad
	barra_vida.value = vida
	barra_vida.visible = true
	
	if vida > 0:
		if $Sprite_skeleton_L.visible:
			$Sprite_skeleton_L.play("Hit")
		elif $Sprite_skeleton_R.visible:
			$Sprite_skeleton_R.play("Hit")
	else:
		morir()

func morir():
	muerto = true
	$Area_deteccion.monitoring = false
	
	if $Collision_skeleton:
		$Collision_skeleton.disabled = true
	
	if $Sprite_skeleton_L.visible:
		$Sprite_skeleton_L.play("Dead")
		await $Sprite_skeleton_L.animation_finished
	elif $Sprite_skeleton_R.visible:
		$Sprite_skeleton_R.play("Dead")
		await $Sprite_skeleton_R.animation_finished
		
	if tiene_llave:
		soltar_llave()
		
	queue_free()
	
func soltar_llave():
	var llave_scene = preload("res://Escenas/llave_castillo.tscn")
	var llave = llave_scene.instantiate()
	get_parent().add_child(llave)
	llave.global_position = global_position

# Cuando el jugador entra en el área de ataque
func _on_Area2D_body_entered(body):
	if body.has_method("set_enemigo_objetivo"):
		body.set_enemigo_objetivo(self)

func _on_Area2D_body_exited(body):
	if body.has_method("clear_enemigo_objetivo"):
		body.clear_enemigo_objetivo(self)
		
		
		
func _on_frame_changed():
	if $Sprite_skeleton_L.is_playing() and $Sprite_skeleton_L.animation == "Attack":
		if $Sprite_skeleton_L.frame == 4: # primer golpe
			aplicar_daño()
		elif $Sprite_skeleton_L.frame == 8: # segundo golpe
			aplicar_daño()

	if $Sprite_skeleton_R.is_playing() and $Sprite_skeleton_R.animation == "Attack":
		if $Sprite_skeleton_R.frame == 4: # primer golpe
			aplicar_daño()
		elif $Sprite_skeleton_R.frame == 8: # segundo golpe
			aplicar_daño()
		
func aplicar_daño():
	if jugador_objetivo != null and jugador_objetivo.has_method("recibir_daño"):
		jugador_objetivo.recibir_daño()
	
