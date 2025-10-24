extends CharacterBody2D


const SPEED = 500.0
var screen_size

func _ready():
	screen_size = get_viewport_rect().size


func _physics_process(delta: float) -> void:

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
