extends CharacterBody2D
# Movimiento resuelto: gravedad, aleteo y avance. El Taller 3 se escribe abajo.

@export var gravedad = 980.0   # px/s²
@export var impulso = 350.0    # px/s hacia arriba en cada aleteo
@export var avance = 120.0     # px/s hacia la derecha

@onready var sprite = $AnimatedSprite2D
@onready var sonido_aleteo = $Aleteo
@onready var sonido_golpe = $Golpe

var inicio = Vector2.ZERO
var muriendo = false

func _ready():
	inicio = global_position


func _physics_process(delta):
	if muriendo:
		return
		
	mover(delta)
	
	if is_on_floor():
		morir()
		return
		
	actualizar_animacion()
	inclinar()
	
	# Taller 3: aquí van la animación, la inclinación y el sonido.
	
	if Input.is_action_just_pressed("aletear"):
		sonido_aleteo.play()


func mover(delta):
	velocity.y += gravedad * delta
	if Input.is_action_just_pressed("aletear"):
		velocity.y = -impulso
	velocity.x = avance
	move_and_slide()
	
func actualizar_animacion():
	var vy = get_real_velocity().y
	print(sprite.animation)
	if vy < -1:                  # sube
		sprite.play("aletear")
		sprite.speed_scale = 1.0 + (-vy) / 350.0
	else:
		sprite.play("planear")
		sprite.speed_scale = 1.0
	
func inclinar():
	var grados = clampf(get_real_velocity().y * 0.15, -25, 90)
	sprite.rotation = deg_to_rad(grados)

func morir():
	muriendo = true
	velocity = Vector2.ZERO
	sprite.speed_scale = 1.0
	sprite.rotation = 0.0
	sprite.play("morir")
	sonido_golpe.play()
	await sprite.animation_finished
	global_position = inicio
	sprite.play("planear")
	muriendo = false
