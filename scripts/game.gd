extends Node2D
var score = 0
var game_running: bool
var game_over: bool
var leaves: Array = []
var high_score: int
var timer: float = 0
var acorn_timer: float = 0
@export var leaf_scene: PackedScene = preload("res://tscn/leafs.tscn")
@export var acorn_scene: PackedScene = preload("res://tscn/acorn.tscn")
@export var spawning_interval: float = 2.5
@export var acorn_spawning_interval: float = 11


func _ready() -> void:
	randomize()
	new_game()

func new_game():
	game_running = false
	game_over = false
	$overlay/score.text = "Score: 0"
	$overlay/score.hide()
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
	$overlay/score.show()
	$startscreen.hide()

func _process(delta: float):
	if game_running:
		acorn_timer += delta
		timer+=delta
		if timer >= spawning_interval:
			timer = 0
			spawn_leaves()
		if acorn_timer >= acorn_spawning_interval:
			acorn_timer = 0
			spawn_acorns()
			
	$catchingnet.game_running = game_running
		
func on_caught():
	score += 1
	$overlay/score.text = str(score)
	$scored.play()
	if score % 10 == 0 and score < 30:
		spawning_interval -= 0.5
	
func spawn_leaves():
	var leaf = leaf_scene.instantiate()
	var screen_width = get_viewport_rect().size.x
	leaf.position.x = randi_range(0, int(screen_width)) - int(global_position.x)
	leaf.position.y = -1
	leaf.caught.connect(on_caught)
	add_child(leaf)

func spawn_acorns():
	var acorn = acorn_scene.instantiate()
	var screen_width = get_viewport_rect().size.x
	acorn.position.x = randi_range(0, int(screen_width)) - int(global_position.x)
	acorn.position.y = -1
	acorn.acorn.connect(on_acorn_caught)
	add_child(acorn)

func on_acorn_caught():
	if $catchingnet.SPEED < 500:
		$catchingnet.SPEED += 30
		print($catchingnet.SPEED)
