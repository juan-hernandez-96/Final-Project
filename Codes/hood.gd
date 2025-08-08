extends CharacterBody2D

@onready var jump = $jump
@onready var death: AudioStreamPlayer2D = $death


var velocidad = 200
var brinco = -400
var gravedad = 1000

func _ready():
	add_to_group("jugador")
	$Node2D/AnimationPlayer.play("idle2")

func _physics_process(delta):
	var direccion = Input.get_axis("ui_left","ui_right")
	velocity.x = direccion * velocidad
	
	if not is_on_floor(): 
		velocity.y += gravedad * delta
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor(): 
		velocity.y = brinco
		jump.play()
	
	move_and_slide()

func _on_death_zone_body_entered(body: Node2D) -> void:
	death.play(.15)
	await get_tree().create_timer(.25).timeout
	get_tree().reload_current_scene()
	
