extends Area2D

enum TipoPlataforma {FIJA}
@export var type: TipoPlataforma = TipoPlataforma.FIJA;

func _ready():
	monitorable = true
	monitoring = true
	actualizar_plataforma()

func actualizar_plataforma():
	match type:
		TipoPlataforma.FIJA:
			$Sprite2D.modulate = Color. TRANSPARENT
