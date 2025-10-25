extends Area2D

@export var fall_speed : float = 150

signal caught



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += fall_speed * delta
	if position.y > get_viewport_rect().size.y:
		queue_free()

func _on_area_entered(_area: Area2D):
	caught.emit()
	queue_free()
