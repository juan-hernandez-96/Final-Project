extends Area2D

func _ready():
	oscilar()
	
func oscilar():
	var tween = create_tween()
	tween.tween_property(self,"position:y",position.y + 5,2)
	tween.tween_property(self,"position:y",position.y - 5,2)
	tween.set_loops() 

func _on_area_entered(area: Area2D) -> void:
		queue_free()
