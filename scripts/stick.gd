extends Area2D
@export var falling_speed: float = 200
signal stick
func _process(delta: float):
	position.y += falling_speed * delta
	if position.y > get_viewport_rect().size.y:
		queue_free()
func _on_area_entered(_area: Area2D):
	stick.emit()
	queue_free()
