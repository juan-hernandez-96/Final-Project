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
