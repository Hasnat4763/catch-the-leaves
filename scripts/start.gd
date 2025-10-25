extends Button

signal start_sigma



func _on_start() -> void:
	start_sigma.emit()


func _on_pressed() -> void:
	_on_start()
