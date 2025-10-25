extends Node2D
var score = 0
var game_running: bool
var game_over: bool
var leaves: Array = []
var high_score: int
var timer: float = 0
@export var leaf_scene: PackedScene = preload("res://tscn/leafs.tscn")
@export var spawining_interval: float = 1


func _ready() -> void:
	new_game()


func new_game():
	game_running = false
	game_over = false
	$CanvasLayer/score.text = "Score: 0"
	$CanvasLayer/score.hide()
	$startscreen/start.start_sigma.connect(start_game)

func _input(event: InputEvent):
	if not game_running:
		if event.is_action_pressed("ui_accept"):
			start_game()
	if game_running:
		if event.is_action_pressed("ui_cancel"):
			get_tree().quit()

func start_game():
	game_running = true
	game_over = false
	$CanvasLayer/score.show()
	$startscreen.hide()


func _process(delta: float) -> void:
	if game_running:
		timer+=delta
		if timer >= spawining_interval:
			timer = 0
			spawn_leaves()
			
	$catchingnet.game_running = game_running
		
func on_caught():
	score += 1
	$CanvasLayer/score.text = str(score)
	$scored.play()
	
	
func spawn_leaves():
	var leaf = leaf_scene.instantiate()
	leaf.position.x = randf_range(0, get_viewport_rect().size.x)
	leaf.position.y = -20
	leaf.caught.connect(on_caught)
	add_child(leaf)
	
