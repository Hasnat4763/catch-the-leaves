extends Area2D
signal acorn

@export var fall_speed : float = 150

func _process(delta: float) -> void:
	position.y += fall_speed * delta
	if position.y > get_viewport_rect().size.y:
		queue_free()

func _on_area_entered(_area: Area2D) -> void:
	acorn.emit()
	queue_free()
