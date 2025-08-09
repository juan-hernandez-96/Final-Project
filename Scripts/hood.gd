extends CharacterBody2D

@onready var jump = $jump
@onready var death: AudioStreamPlayer2D = $death
@onready var rupee_label = %Label


var velocidad = 200
var brinco = -400
var gravedad = 1000

var rupee_counter = 0

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
	
func _on_portal_1_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Scenes/nivel1.tscn")
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("rupee"):
		set_rupee(rupee_counter + 1)
		print(rupee_counter)

func set_rupee(new_rupee_count: int):
	rupee_counter = new_rupee_count
	rupee_label.text = "Rupees: " + str(rupee_counter)
