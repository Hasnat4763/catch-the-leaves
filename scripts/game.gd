extends Node2D
var score = 0
var game_running: bool
var game_over: bool
var leaves: Array = []
var high_score: int
var timer: float = 0
var acorn_timer: float = 0
var leaf_speed = 150
@export var leaf_scene: PackedScene = preload("res://tscn/leafs.tscn")
@export var acorn_scene: PackedScene = preload("res://tscn/acorn.tscn")
@export var spawning_interval: float = 2.5
@export var acorn_spawning_interval: float = 9.5
@export var score_target: int
@export var time_limit: float
var time_left: float
var game_won: bool


func _ready() -> void:
	randomize()
	new_game()
	$startscreen/start.start_sigma.connect(start_game)
	$endscreen.restart.connect(new_game)

func new_game():
	game_running = false
	game_over = false
	score_target = randi_range(10, 60)
	time_limit = randf_range(30, 240)
	time_left = time_limit
	$endscreen.hide()
	$overlay/score.text = "Score: 0"
	$overlay/time_left.text = "Time Left: " + str(time_left)
	$overlay/target.text = "Target: " + str(score_target)
	$overlay.hide()
	$catchingnet.hide()
	$startscreen.show()


func start_game():
	game_running = true
	game_over = false
	$bg.play()
	$catchingnet.show()
	$overlay.show()
	$startscreen.hide()
	
func stop_game():
	game_running = false
	game_over = true
	$bg.stop()
	if game_won:
		$endscreen/end_message.text = "You Won!!!!"
	else:
		$endscreen/end_message.text = "You lost 😭 \n Better Luck Next Time"
	$endscreen.show()
	$endscreen/end_message.text = "Game Over"


func _input(event: InputEvent):
	if not game_running:
		if event.is_action_pressed("ui_accept"):
			start_game()
	if game_running:
		if event.is_action_pressed("ui_cancel"):
			get_tree().quit()


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
			
		if time_left > 0:
			time_left -= delta
			$overlay/time_left.text = "Time Left: " + str(time_left)
		else:
			stop_game()
			game_won = false
		
		if score_target <= score:
			game_won = true
			stop_game()
			
			
	$catchingnet.game_running = game_running
		
func on_caught():
	score += 1
	$overlay/score.text = "Score: " + str(score)
	$scored.play()
	if score % 10 == 0 and score < 30:
		spawning_interval -= 0.5
		leaf_speed += 25

func on_acorn_caught():
	if $catchingnet.SPEED < 700:
		$catchingnet.SPEED += 100
		print($catchingnet.SPEED)
	$scored.play()
	score+=5
	$overlay/score.text = "Score: " + str(score)
	
func spawn_leaves():
	var leaf = leaf_scene.instantiate()

	leaf.set("game_running", true)
	leaf.set("fall_speed", leaf_speed)
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
