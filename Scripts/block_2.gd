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
