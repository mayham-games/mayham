extends Node

# onready vars
# game rules
onready var num_players = 2
onready var time_limit = 180 # 3 min
onready var time_remaining = time_limit
onready var winning_score = 50
onready var _goal_max = 20
onready var _goal_min = 10
onready var goal_interval = _goal_max - _goal_min
onready var goal_move_time = goal_interval
onready var field = ResourceLoader.load("res://FlatMap.tscn")
onready var fantasy = ResourceLoader.load("res://Mortal Engines.tscn")

var _timer = null
var _map = null

func _ready():
	# Add the players
	var game = fantasy
	_map = game.instance()
	add_child(_map)
	var playerController = ResourceLoader.load("res://PlayerController.tscn")
	var players = []
	for i in range(num_players):
		var playerControl = playerController.instance()
		playerControl.init(i+1)
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
	#if _map.has_winner(winning_score) or time_remaining <= 0:
		#end_game()
	pass

#This is a work in progress... not completed
func end_game():
	var score_board = _map.collect_players()
