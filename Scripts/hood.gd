extends CharacterBody2D

@onready var jump = $jump
@onready var death: AudioStreamPlayer2D = $death
@onready var rupee_1: AudioStreamPlayer2D = $rupee1
@onready var rupees: Label = %rupees

var score : int = 0
var velocidad = 200
var brinco = -400
var gravedad = 1000
var rupee_counter = 0
var label_score: Label

func _ready():
	label_score = $label_score
	label_score.text = "Score: %d" % [Global.score]
	rupees.text = "Rupees: " + str(Global.rupee_counter)
	$Node2D/AnimationPlayer.play("idle2")
	add_to_group("jugador")

func _physics_process(delta):
	var direccion = Input.get_axis("ui_left","ui_right")
	velocity.x = direccion * velocidad
	
	if not is_on_floor(): 
		velocity.y += gravedad * delta
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor(): 
		velocity.y = brinco
		jump.play()
	
	move_and_slide()

	if Input.is_action_just_pressed("Save"):
		guardar_datos_json()
	if Input.is_action_just_pressed("Load"):
		cargar_datos_json()

func sumar_puntos(cantidad : int):
	Global.score += cantidad
	actualizar_label()

func actualizar_label():
	label_score.text = "Points: %d" % [Global.score]

func guardar_datos_json():
	var estado_objetos = []
	for rupee in get_tree().get_nodes_in_group("rupee"):
		estado_objetos.append({
			"nombre": rupee.name,
			"recolectada": not rupee.is_inside_tree(),
			"posicion": {
				"x": "%.8f" % rupee.global_position.x,
				"y": "%.8f" % rupee.global_position.y
			} if rupee.is_inside_tree() else {"x": "0.00000000", "y": "0.00000000"},
			"parent_path": rupee.get_parent().get_path() if rupee.is_inside_tree() else ""
		})
	
	var datos = {
		"jugador": {
			"posicion": {"x": "%.8f" % global_position.x, "y": "%.8f" % global_position.y},
			"score": Global.score,
			"rupee_counter": Global.rupee_counter
		},
		"objetos": estado_objetos
	}
	
	var json_string = JSON.stringify(datos, "\t")
	var archivo = FileAccess.open("user://partida_guardada.json", FileAccess.WRITE)
	archivo.store_string(json_string)
	archivo.close()
	print("Datos guardados en JSON!")

func cargar_datos_json():
	if not FileAccess.file_exists("user://partida_guardada.json"):
		print("No hay archivo JSON guardado.")
		return
	
	var archivo = FileAccess.open("user://partida_guardada.json", FileAccess.READ)
	var json_string = archivo.get_as_text()
	archivo.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		print("Error al parsear JSON: ", json.get_error_message())
		return
	
	var datos = json.get_data()
	
	for rupee in get_tree().get_nodes_in_group("rupee"):
		rupee.queue_free()
	
	global_position = Vector2(
		float(datos["jugador"]["posicion"]["x"]),
		float(datos["jugador"]["posicion"]["y"])
	)
	
	Global.score = datos["jugador"]["score"]
	Global.rupee_counter = datos["jugador"]["rupee_counter"]
	
	actualizar_label()
	rupees.text = "Rupees: " + str(Global.rupee_counter)
	
	for objeto in datos["objetos"]:
		if !objeto["recolectada"]:
			var nueva_rupee = preload("res://Scenes/rupee.tscn").instantiate()
			nueva_rupee.name = objeto["nombre"]
			
			var parent_node = get_node_or_null(objeto["parent_path"])
			if parent_node:
				parent_node.add_child(nueva_rupee)
				nueva_rupee.global_position = Vector2(
					float(objeto["posicion"]["x"]),
					float(objeto["posicion"]["y"])
				)
			else:
				printerr("No se encontró el nodo padre:", objeto["parent_path"])
	
	print("Datos cargados con precisión!")

func _on_death_zone_body_entered(body: Node2D) -> void:
	death.play(.15)
	await get_tree().create_timer(.25).timeout
	get_tree().reload_current_scene()
	
func _on_portal_1_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Scenes/nivel1.tscn")
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("rupee"):
		rupee_1.play()
		set_rupee(rupee_counter + 1)
		print(rupee_counter)

func set_rupee(new_rupee_count: int):
	Global.rupee_counter = new_rupee_count
	rupees.text = "Rupees: " + str(Global.rupee_counter)

func _on_portal_2_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Scenes/nivel2.tscn")
