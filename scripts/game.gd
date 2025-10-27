extends Node2D
var score = 0
var game_running: bool
var game_over: bool
var leaves: Array = []
var high_score: int
var timer: float = 0
var acorn_timer: float = 0
var stick_timer: float = 0
var leaf_speed = 150
var acorn_speed = 200
var time_left: float
var game_won: bool = false
var custom_game: bool = false
var stick_collected: int = 0
var base_leaf_speed = 150
var base_acorn_speed = 200
var base_net_speed = 0
const save_path = "user://score_save.save"
const MAX_LEAF_SPEED = 400
const MAX_ACORN_SPEED = 500
const MAX_NET_SPEED = 700
@export var leaf_scene: PackedScene = preload("res://tscn/leafs.tscn")
@export var acorn_scene: PackedScene = preload("res://tscn/acorn.tscn")
@export var stick_scene: PackedScene = preload("res://tscn/stick.tscn")
@export var spawning_interval: float = 2.5
@export var acorn_spawning_interval: float = 9.5
@export var stick_spawning_interval: float = 2
@export var score_target: int
@export var time_limit: float

func _ready() -> void:
	randomize()
	score_target = 20
	time_limit = 60
	time_left = time_limit
	base_net_speed = $catchingnet.SPEED
	if not DisplayServer.is_touchscreen_available():
		print("No TouchScreen")
		$touch_control.hide()
	$startscreen.start_sigma.connect(start_game)
	$endscreen.restart.connect(new_game)
	$startscreen.start_custom.connect(start_custom)
	$endscreen.hide()
	$overlay.hide()
	$catchingnet.hide()
	$startscreen.show()
	load_score()
	game_won = false

func new_game():
	game_running = false
	game_over = false
	
	score = 0
	stick_collected = 0
	custom_game = false
	leaf_speed = base_leaf_speed
	acorn_speed = base_acorn_speed
	$catchingnet.SPEED = base_net_speed
	spawning_interval = 2.5
	acorn_spawning_interval = 9.5
	stick_spawning_interval = 2
	$endscreen.hide()
	$overlay/score.text = "Score: 0"
	$overlay/time_left.text = "Time Left: " + str(int(time_left)) + " seconds"
	$overlay/target.text = "Target: " + str(score_target)
	$overlay/sticks.text = "Sticks: 0/5"
	$overlay.hide()
	$catchingnet.hide()
	$startscreen.show()
	game_won = false

func start_game():
	score = 0
	stick_collected = 0
	game_won = false
	game_running = true
	game_over = false
	score_target = randi_range(10, 60)
	time_limit = randf_range(30, 240)
	time_left = time_limit
	leaf_speed = base_leaf_speed
	acorn_speed = base_acorn_speed
	$catchingnet.SPEED = base_net_speed
	spawning_interval = 2.5
	acorn_spawning_interval = 9.5
	$overlay/score.text = "Score: 0"
	$overlay/time_left.text = "Time Left: " + str(int(time_left)) + " seconds"
	$overlay/target.text = "Target: " + str(score_target)
	$overlay/sticks.text = "Sticks: 0/5"
	$bg.play()
	$catchingnet.show()
	$overlay.show()
	$startscreen.hide()


func start_custom(time_limit_custom: float, target_custom: int, fall_speed_custom: float, movement_speed_custom: float):
	leaf_speed = base_leaf_speed + fall_speed_custom * 50
	acorn_speed = base_acorn_speed + fall_speed_custom * 50
	$catchingnet.SPEED = base_net_speed + movement_speed_custom * 100
	score_target = target_custom
	time_limit = time_limit_custom
	time_left = time_limit
	stick_collected = 0
	score = 0
	custom_game = true
	$overlay/score.text = "Score: 0"
	$overlay/time_left.text = "Time Left: " + str(int(time_left)) + " seconds"
	$overlay/target.text = "Target: " + str(score_target)
	$overlay/sticks.text = "Sticks: 0/5"
	$startscreen.hide()
	$overlay.show()
	$catchingnet.show()
	$bg.play()
	game_running = true
	game_over = false

func stop_game():
	game_running = false
	game_over = true
	$bg.stop()
	if game_won:
		$endscreen/end_message.text = "You Won!!!!"
	else:
		$endscreen/end_message.text = "You lost \n Better Luck Next Time"
	$endscreen.show()
	if score > high_score:
		high_score = score
		save()
	$endscreen/score.text = "Your Score: " + str(score) + "\n" + "High Score: " + str(high_score)


func _input(event: InputEvent):
	if not game_running:
		if event.is_action_pressed("ui_accept"):
			start_game()


func _process(delta: float):
	if game_over:
		return
	if game_running:
		acorn_timer += delta
		timer += delta
		stick_timer += delta
		if timer >= spawning_interval:
			timer = 0
			spawn_leaves()
		if acorn_timer >= acorn_spawning_interval:
			acorn_timer = 0
			spawn_acorns()
		if stick_timer >= stick_spawning_interval:
			stick_timer = 0
			spawn_sticks()
		if time_left > 0:
			time_left -= delta
			$overlay/time_left.text = "Time Left: " + str(int(time_left)) + " seconds"
		else:
			game_won = false
			stop_game()
		if score >= score_target:
			game_won = true
			stop_game()
		if stick_collected >= 5:
			game_won = false
			stop_game()
	$catchingnet.game_running = game_running

func on_caught():
	score += 1
	$overlay/score.text = "Score: " + str(score)
	$scored.play()
	if score % 10 == 0 and score < 30 and not custom_game:
		spawning_interval = max(0.5, spawning_interval - 0.5)
		leaf_speed = min(MAX_LEAF_SPEED, leaf_speed + 25)

func on_acorn_caught():
	if $catchingnet.SPEED < MAX_NET_SPEED:
		$catchingnet.SPEED += 100
	if not custom_game:
		acorn_speed = min(MAX_ACORN_SPEED, acorn_speed + 25)
		acorn_spawning_interval = max(3.0, acorn_spawning_interval - 0.5)
	$scored.play()
	score += 5
	$overlay/score.text = "Score: " + str(score)
	
func on_stick_caught():
	if score > 0:
		score -= 1
	stick_collected += 1
	$overlay/score.text = "Score: " + str(score)
	$overlay/sticks.text = "Sticks: " + str(stick_collected) + "/5"
	$stick_collected.play()
	
func spawn_leaves():
	var leaf = leaf_scene.instantiate()
	leaf.set("game_running", true)
	leaf.set("fall_speed", leaf_speed)
	var screen_width = get_viewport_rect().size.x
	leaf.position.x = randi_range(0, int(screen_width))
	leaf.position.y = -1
	leaf.caught.connect(on_caught)
	add_child(leaf)

func spawn_acorns():
	var acorn = acorn_scene.instantiate()
	acorn.set("fall_speed", acorn_speed)
	var screen_width = get_viewport_rect().size.x
	acorn.position.x = randi_range(0, int(screen_width))
	acorn.position.y = -1
	acorn.acorn.connect(on_acorn_caught)
	add_child(acorn)

func spawn_sticks():
	var stick = stick_scene.instantiate()
	var screen_width = get_viewport_rect().size.x
	stick.position.x = randi_range(0, int(screen_width))
	stick.position.y = -1
	stick.stick.connect(on_stick_caught)
	add_child(stick)

func save():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(high_score)
	
func load_score():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		high_score = file.get_var()
	else:
		high_score = 0
