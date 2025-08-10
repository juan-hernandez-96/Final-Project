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
