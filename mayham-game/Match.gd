extends Node

# onready vars
# game rules
onready var num_players = 5
onready var time_limit = 180 # 3 min
onready var time_remaining = time_limit
onready var winning_score = 50
onready var _goal_max = 20
onready var _goal_min = 10
onready var goal_interval = _goal_max - _goal_min
onready var goal_move_time = goal_interval
onready var field = ResourceLoader.load("res://FlatMap.tscn")
onready var fantasy = ResourceLoader.load("res://Mortal Engines.tscn")
onready var music = $Music

var _timer = null
var _map = null

func _ready():
	# Add the players
	var game = fantasy
	_map = game.instance()
	add_child(_map)
	var playerController = ResourceLoader.load("res://PlayerController.tscn")
	var players = []
	var colors = makeColors(num_players)
	for i in range(num_players):
		var playerControl = playerController.instance()
		playerControl.init(i+1, colors[i])
		add_child(playerControl)
		players.append(playerControl.get_player())
	_map.init(players)
	
	# set the time limit
	time_remaining = time_limit
	
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()
	
	# disable to turn off music
	music.play(0)

func _on_Timer_timeout():
	if goal_move_time == 0:
		goal_move_time = randi() % goal_interval + _goal_min
		_move_goal()
	else:
		goal_move_time -= 1
		time_remaining -= 1
		_map.award_points()
		_map.update_timer(time_remaining)

func _move_goal():
	_map.move_goal()

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if _map.has_winner(winning_score) or time_remaining <= 0:
		_end_game()
	pass

#This is a work in progress... not completed
func _end_game():
	var score_board = _map.collect_players()

func makeColors(num_players):
	var colors = []
	for i in range(num_players):
		var color = _random_color()
		while not checkColor(color, colors):
			color = _random_color()
		colors.append(color)
	return colors

func checkColor(color, colorArray):
	for i in range(colorArray.size()):
		if color == colorArray[i]:
			return false
	return true

func _random_color():
	randomize()
	var list = [1.0, 0.7, 0.0]
	if randi()%2 == 0:
		list = [1.0, 0.5, 0.2]
	var x = randi()%list.size()
	var c1 = list[x]
	list.remove(x)
	x = randi()%list.size()
	var c2 = list[x]
	list.remove(x)
	var c3 = list[0]
	return Color(c1,c2,c3)
