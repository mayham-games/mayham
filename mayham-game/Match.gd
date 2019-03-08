extends Node

# public vars
# game rules
var time_remaining = 0

# On ready vars
onready var game = preload("res://FlatMap.tscn")
onready var playerController = preload("res://PlayerController.tscn")
# game rules
onready var num_players = 2
onready var time_limit = 180 # 3 min

func _ready():
	
	# Add the players
	add_child(game.instance())
	for i in range(num_players):
		var playerControl = playerController.instance()
		playerControl.player_num = i + 1
		add_child(playerControl)
		
	# set the time limit
	time_remaining = time_limit

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
