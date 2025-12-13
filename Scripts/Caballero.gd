extends CharacterBody2D

class_name Player

const SPEED = 120.0
const JUMP_VELOCITY = -300.0
const LIMITE_CAIDA := 300
var bloque_empujable: RigidBody2D = null
var bloque_can_agarre: bool = false
var bloque_agarrado: bool = false
var cont_saltos := 2
var enemigo_objetivo: Node = null
var estado: String = "Idle"
var muerto = false
var puede_recibir_daño = true
var recibiendo_daño = false
var ultima_direccion := 1


#Inicio del personaje
func _ready():
	$Sprite_derecha.visible = true
	$Sprite_izquierda.visible = false
	$Sprite_push_R.visible = false
	$Sprite_push_L.visible = false

#Contacto con RigidBody	
func _on_Area_push_body_entered(body):
	if body is RigidBody2D and body.is_in_group("Bloque_piedra"):
		bloque_empujable = body
		bloque_can_agarre = true
		
		
#No hay Contacto con RigidBody
func _on_Area_push_body_exited(body: Node2D) -> void:
	if body == bloque_empujable:
		bloque_empujable = null
		bloque_can_agarre = false
		bloque_agarrado = false

		$Joint_agarre.node_a = NodePath("")
		$Joint_agarre.node_b = NodePath("")

		$Sprite_push_L.stop()
		$Sprite_push_L.visible = false
		$Sprite_push_R.stop()
		$Sprite_push_R.visible = false

		# Reactiva sprite base
		if $Sprite_izquierda.visible:
			$Sprite_izquierda.visible = true
		elif $Sprite_derecha.visible:
			$Sprite_derecha.visible = true
	
			
#Funcion para el Salto y el Doble Salto
func doble_salto():
	if estado != "Attack":
		if Input.is_action_just_pressed("ui_accept") and cont_saltos > 0 and not bloque_agarrado:
			velocity.y = JUMP_VELOCITY
			cont_saltos -= 1
			if cont_saltos == 1:
				if $Sprite_izquierda.visible:
					$Sprite_izquierda.play("jump")
				elif $Sprite_derecha.visible:
					$Sprite_derecha.play("jump")
			elif cont_saltos == 0:
				if $Sprite_izquierda.visible:
					$Sprite_izquierda.play("jump")
				elif $Sprite_derecha.visible:
					$Sprite_derecha.play("jump")

#Funcion Atacar				
func atacar():
	estado = "Attack"
	if $Sprite_izquierda.visible:
		$Sprite_izquierda.play("Attack")
		await $Sprite_izquierda.animation_finished
	elif $Sprite_derecha.visible:
		$Sprite_derecha.play("Attack")
		await $Sprite_derecha.animation_finished
		
	estado = "Idle"

	if enemigo_objetivo != null and enemigo_objetivo.has_method("recibir_daño"):
		enemigo_objetivo.recibir_daño(15)
			
func set_enemigo_objetivo(enemigo):
	enemigo_objetivo = enemigo

func clear_enemigo_objetivo(enemigo):
	if enemigo_objetivo == enemigo:
		enemigo_objetivo = null
		
		
func recibir_daño():
	if muerto or not puede_recibir_daño:
		return
	Global.vidas -= 1
	puede_recibir_daño = false
	recibiendo_daño = true

	if $Sprite_izquierda.visible:
		$Sprite_izquierda.play("Hit")
	elif $Sprite_derecha.visible:
		$Sprite_derecha.play("Hit")

	if Global.vidas == 0:
		morir()
		
	else:
		# invulnerabilidad por "x" segundos
		await get_tree().create_timer(1).timeout
		puede_recibir_daño = true
		
func _on_Sprite_izquierda_animation_finished():
	recibiendo_daño = false

func _on_Sprite_derecha_animation_finished():
	recibiendo_daño = false

func morir():
	muerto = true
	if $Sprite_izquierda.visible:
		$Sprite_izquierda.play("Dead")
		await $Sprite_izquierda.animation_finished
	elif $Sprite_derecha.visible:
		$Sprite_derecha.play("Dead")
		await $Sprite_derecha.animation_finished

	get_tree().call_deferred("change_scene_to_file","res://Escenas/menu_gameOver.tscn")
				


#Funcion General	
func _physics_process(delta: float) -> void:
	if muerto:
		return
		
	if recibiendo_daño:
		return
		
	var direction := Input.get_axis("m_left", "m_right")
				
	
	if global_position.y > LIMITE_CAIDA:
		if Global.vidas > 1:
			Global.vidas -= 1
			get_tree().call_deferred("reload_current_scene")
		else:
			get_tree().call_deferred("change_scene_to_file","res://Escenas/menu_gameOver.tscn")
	
	if is_on_floor():# Reinicia contador de saltos
		cont_saltos = 2
		
	# Aplica gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	#Atacar
	if Input.is_action_just_pressed("atacar") and estado != "Attack":
		atacar()
		

	# Saltar
	if estado != "Attack":
		if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not bloque_agarrado:
			velocity.y = JUMP_VELOCITY

	# Dirección horizontal
	if direction != 0:
		
		if direction < 0:
			ultima_direccion = -1
		elif direction > 0:
			ultima_direccion = 1
			
		if bloque_agarrado:
			velocity.x = direction * (SPEED/5)
		else:
			velocity.x = direction * SPEED
		# Voltear sprite si no empuja o agarra
		if not bloque_agarrado and not bloque_empujable and is_on_floor():
			if estado != "Attack":
				if $Sprite_izquierda.visible:
					$Sprite_izquierda.play("walk")
				elif $Sprite_derecha.visible:
					$Sprite_derecha.play("walk")
		if direction < 0 and not bloque_agarrado and not bloque_empujable:
			$Sprite_derecha.visible = false
			$Sprite_izquierda.visible = true
		elif direction > 0 and not bloque_agarrado and not bloque_empujable:
			$Sprite_derecha.visible = true
			$Sprite_izquierda.visible = false 	
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		#Idle si no empuja o agarra
		if not bloque_agarrado and not bloque_empujable:
			if estado != "Attack":
				if $Sprite_izquierda.visible:
					$Sprite_izquierda.play("idle")
				elif $Sprite_derecha.visible:
					$Sprite_derecha.play("idle")
		
	# Caida si no se empuja o agarra
	if not bloque_agarrado and not is_on_floor() and not bloque_empujable:
		if estado != "Attack":
			if velocity.y > 0:
				if $Sprite_izquierda.visible:
					$Sprite_izquierda.play("fall")
				elif $Sprite_derecha.visible:
					$Sprite_derecha.play("fall")
	
	#Desactiva sprite empuje sobre el bloque			
	if not is_on_floor() and bloque_empujable != null:
		if $Sprite_push_L.visible:
			$Sprite_push_L.visible = false
			$Sprite_izquierda.visible = true
		elif $Sprite_push_R.visible:
			$Sprite_push_R.visible = false
			$Sprite_derecha.visible = true
	
	#Activa sprite idle al caer junto al bloque		
	if is_on_floor() and bloque_empujable != null:
		if $Sprite_derecha.visible:
			$Sprite_derecha.play("idle")
		elif $Sprite_izquierda.visible:
			$Sprite_izquierda.play("idle")
	
	#Para agarra un bloque		
	if Input.is_action_just_pressed("agarre") and bloque_can_agarre:
		$Joint_agarre.node_a = get_path()
		$Joint_agarre.node_b = $Joint_agarre.get_path_to(bloque_empujable)
		bloque_agarrado = true

		if $Sprite_izquierda.visible:
			$Sprite_izquierda.visible = false
			$Sprite_push_L.visible = true
			$Sprite_push_L.play("push")
		elif $Sprite_derecha.visible:
			$Sprite_derecha.visible = false
			$Sprite_push_R.visible = true
			$Sprite_push_R.play("push")
		
					
	if Input.is_action_just_released("agarre") and bloque_agarrado:
		$Joint_agarre.node_a = NodePath("")
		$Joint_agarre.node_b = NodePath("")
		bloque_agarrado = false

		$Sprite_push_L.stop()
		$Sprite_push_L.visible = false
		$Sprite_push_R.stop()
		$Sprite_push_R.visible = false
		
		if ultima_direccion == -1:
			$Sprite_izquierda.visible = true
			$Sprite_izquierda.play("idle")
			$Sprite_derecha.visible = false
		else:
			$Sprite_derecha.visible = true
			$Sprite_derecha.play("idle")
			$Sprite_izquierda.visible = false
			

	doble_salto()
	move_and_slide()
