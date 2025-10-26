extends CharacterBody2D


var SPEED = 300.0
var game_running = false




func _physics_process(_delta: float):
	var direction_horiz := Input.get_axis("ui_left", "ui_right")
	var direction_vert := Input.get_axis("ui_up", "ui_down")
	if game_running:
		if direction_horiz:
			velocity.x = direction_horiz * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		if direction_vert:
			velocity.y = direction_vert * SPEED
		else:
			velocity.y = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
