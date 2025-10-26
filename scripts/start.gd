extends Node2D

signal start_custom(time_limit: float, target: int, fall_speed: float, movement_speed: float)
signal start_sigma
@export var time_limit_var: float = 20
@export var target: int = 10
@export var falling_speed: float
@export var movement_speed: float

func _on_start_custom_pressed() -> void:
	if $Custom_game/time_limit.text != "":
		time_limit_var = float($Custom_game/time_limit.text)
	if $Custom_game/target.text != "":
		target = int($Custom_game/target.text)
	falling_speed = $Custom_game/falling_speed.value
	movement_speed = $Custom_game/movement_speed.value
	emit_signal("start_custom", time_limit_var, target, falling_speed, movement_speed)


func _on_start_pressed() -> void:
	start_sigma.emit()
