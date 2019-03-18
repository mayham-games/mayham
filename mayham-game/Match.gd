extends Node

# public vars
# game rules
var time_remaining = 0

# onready vars
# game rules
onready var num_players = 2
# onready var time_limit = 180 # 3 min
onready var time_limit = 5 # 5 seconds, temporary
onready var winning_score = 50
onready var goal_interval = 20

var _timer = null
var _map = null
var _players = []

func _ready():
	# Add the players
	var game = ResourceLoader.load("res://FlatMap.tscn")
	_map = game.instance()
	add_child(_map)
	_players = _init_players()
	_map.init(_players)
	_init_timer()


func _on_Timer_timeout():
	_map.award_points()
	time_remaining -= 1
	_map.update_timer(time_remaining)


func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if _map.has_winner(winning_score) or time_remaining <= 0:
		_end_game()

func _init_players():
	var playerController = ResourceLoader.load("res://PlayerController.tscn")
	var players = []
	for i in range(num_players):
		var playerControl = playerController.instance()
		playerControl.init(i+1)
		add_child(playerControl)
		players.append(playerControl.get_player())
	return players
	
func _init_timer():
	time_remaining = time_limit
	
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()

func _reset_match():
	# for each player
	for player in _players:
		player.reset_score()
	# set score to 0
	# set time_remaining to time_limit
	time_remaining = time_limit
	# start timer again
	_timer.start()
	pass
	
func _show_scoreboard(score_board):
	# set the scoreboard to visible
	# ensure that the rankings are correct
	pass

func _end_game():
	var score_board = _map.collect_players()
	# pause the timer
	_timer.stop()
	# show the score_board
	_show_scoreboard(score_board)
	# If "play again" button is hit or "start"
	# reset the match
