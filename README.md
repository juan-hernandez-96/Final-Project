**Hood's Grand Adventure!**

Hecho por: *Juan Pablo Hernández Arciniega*

En este juego controlas a Hood, un pequeño y amigable personaje en una aventura donde el objetivo es conseguir rupias. Saltaras de un nivel a otro por medio de distintas plataformas hasta llegar al fin y descubrir lo que te espera allí!

- ***Assests usados***

- Character sheet

![6e954e7b4487f85f814fd3ea5bc1a477](https://github.com/user-attachments/assets/fefa7b79-1739-404c-8061-767f23f7845a)


- Plataformas usadas dentro de los niveles

<img width="451" height="553" alt="bloques" src="https://github.com/user-attachments/assets/175760fe-048d-45c7-b634-5abe44b06b77" />
<img width="166" height="91" alt="rock" src="https://github.com/user-attachments/assets/cf5a7816-82d3-4bcb-8291-23b725af1777" />

- Rupia

<img width="860" height="831" alt="rupia" src="https://github.com/user-attachments/assets/ad0a74dd-8488-4f95-9730-7771578a3af2" />

- Portales

<img width="320" height="320" alt="portal2" src="https://github.com/user-attachments/assets/c38b5d87-63cd-4455-8284-ac5eecbaf8dd" />
<img width="480" height="480" alt="twiliportal" src="https://github.com/user-attachments/assets/57041382-3faa-4001-b310-6a2f9d4bc794" />

- Fondos

<img width="1727" height="970" alt="Forest-and-Trees-Free-Pixel-Backgrounds7" src="https://github.com/user-attachments/assets/cfc63da9-f15a-48c8-9f0e-7cfee3fe11dc" />
<img src="https://github.com/user-attachments/assets/0bafa99e-99b5-4572-8348-54a5f892374c" /> 
<img src="https://github.com/user-attachments/assets/b375be56-14ac-47e0-8ba2-e07212e9baa5" />
<img src="https://github.com/user-attachments/assets/46e1cfdd-f517-4b42-b265-f070490a0652" />
<img src="https://github.com/user-attachments/assets/25c1385f-a3ce-404d-83c6-24ba09a75eda" />
<img src="https://github.com/user-attachments/assets/5df944e4-59e5-4599-9ff3-7d84037ba331" />

Tambien se hicieron uso de efectos de sonido (que consistieron de un sonido de salto, un sonido cuando se obtiene una rupia y un sonido de muerte), así como tres pistas musicales, una para cada nivel del juego.

- ***Scripts empleados***

_Script de Hood: Script principal de personaje, en el se encuentran la mayoria de las funciones: movimiento del personaje (izquierda, derecha y salto), contador de puntos, así como la función JSON que permite guardas y cargar los datos del personaje (posición y puntaje), las funciones para el area de muerte y las funciones de entrada a los portales; acceso a los niveles del juego._

```gdscript
extends CharacterBody2D

@onready var jump = $jump
@onready var death: AudioStreamPlayer2D = $death
@onready var rupee_1: AudioStreamPlayer2D = $rupee1
@onready var rupees: Label = %rupees

var velocidad = 200
var brinco = -400
var gravedad = 1000
var rupee_counter = 0
var label_score: Label

func _ready():
	label_score = $label_score
	actualizar_label()
	label_score.text = "Score: %d" % [Global.score]
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
	Global.score += 100
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
	get_tree().change_scene_to_file("res://Scenes/nivel1.tscn")
	
func _on_portal_1_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Scenes/nivel1.tscn")
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("rupee"):
		rupee_1.play()
		set_rupee(Global.rupee_counter + 1)
		sumar_puntos(100)
		print("Score: ", Global.score)
		print(Global.rupee_counter)

func set_rupee(new_rupee_count: int):
	Global.rupee_counter = new_rupee_count
	rupees.text = "Rupees: " + str(Global.rupee_counter)

func _on_portal_2_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Scenes/nivel2.tscn")

func _on_portal_3_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Scenes/nivel3.tscn")

func _on_node_2d_7_body_entered(body: Node2D) -> void:
	pass
```

_El siguiente script fue usado dentro de una de las plataformas, la cual permite que en esta, el personaje pueda rebotar._

```gdscript
 extends Area2D

enum TipoPlataforma {REBOTE}
@export var type: TipoPlataforma = TipoPlataforma.REBOTE;
@export var fuerza_rebote := 2.0 

func _ready():
	monitorable = true
	monitoring = true
	actualizar_plataforma()

func actualizar_plataforma():
	match type:
		TipoPlataforma.REBOTE:
			$Sprite2D.modulate = Color. DIM_GRAY

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		match type:
			TipoPlataforma.REBOTE:
				if body.has_method("puede_rebotar"):
					body.puede_rebotar(fuerza_rebote)
				else: 
					body.velocity.y = body.brinco * fuerza_rebote
```

_Este script hace que la plataforma caiga una vez que el personaje se posicione sobre ella._

```gdscript
extends Area2D

enum TipoPlataforma {FRAGIL}
@export var tipo: TipoPlataforma = TipoPlataforma.FRAGIL

func _ready():
	actualizar_plataforma()
	monitorable = true
	monitoring = true
	
func actualizar_plataforma():
	match tipo:
		TipoPlataforma.FRAGIL:
			$Sprite2D
			
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		match  tipo:
			TipoPlataforma.FRAGIL:
				await get_tree().create_timer(.5).timeout
				queue_free()
```

_Este script hace que la plataforma se mueva de izquierda a derecha_

```gdscript
extends Area2D

enum TipoPlataforma {OSCILATORIA}
@export var type: TipoPlataforma = TipoPlataforma.OSCILATORIA;

func _ready():
	monitorable = true
	monitoring = true
	actualizar_plataforma()

func actualizar_plataforma():
	match type:
		TipoPlataforma.OSCILATORIA:
			oscilar()

func oscilar():
	var tween = create_tween()
	tween.tween_property(self,"position:x",position.x + 80,2)
	tween.tween_property(self,"position:x",position.x - 80,2)
	tween.set_loops() 

func _on_body_entered(body: Node2D) -> void:
	pass
```

_Y este scrpit permite que la plataforma se mueva hacia arriba y abajo_

```gdscript
extends Area2D

enum TipoPlataforma {OSCILATORIA}
@export var type: TipoPlataforma = TipoPlataforma.OSCILATORIA;

func _ready():
	monitorable = true
	monitoring = true
	actualizar_plataforma()

func actualizar_plataforma():
	match type:
		TipoPlataforma.OSCILATORIA:
			oscilar()

func oscilar():
	var tween = create_tween()
	tween.tween_property(self,"position:y",position.y - 100,2)
	tween.tween_property(self,"position:y",position.y + 100,2)
	tween.set_loops() 

func _on_body_entered(body: Node2D) -> void:
	pass 
```

-***Demostración*** 

Video 1-.


https://github.com/user-attachments/assets/1ec5bd46-d2db-4cda-867a-c742edb8f306


Video 2-.


https://github.com/user-attachments/assets/43583bbf-c1f0-4c6f-a044-2ae1a2488a65


-***Comentarios finales***

Reconozco que no ganaré un premio al mejor juego del años, pero he de decir que la experiencia fue grata y placentera. Usar las diferentes herramientas que el programa GoDOT proporciona fue un deleite, aunado a las herrmaientas que se nos proporcionaron durante las diferentes seciones de clases se puede inferir que el proposito final del proyecto se cumplió debidamente. Algo que me gustó de este trabajo fue la amplia ayuda que es posible encontrar en internet, basta con escribir precisamente que es lo que uno necesita en el buscador y uno puede estar seguro que encontrara una gran cantidad de contenido beneficioso para el aprendizaje.
