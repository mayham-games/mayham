extends Node

signal action_start
signal action_jump
signal action_left
signal action_right
signal action_dash
signal action_stop

var playerDoll = null
var number = 0

func init(num):
	number = num

func _ready():
	var position_x = 100 * (number - 5)
	var player = ResourceLoader.load("res://Player.tscn")
	playerDoll = player.instance()
	add_child(playerDoll)
	playerDoll.init(number, position_x)
	print("PC ready ", number)
	
func _input(event):
	if event.is_action_pressed("p" + str(player_num) + "_start"):
		emit_signal("action_start")
	if event.is_action_pressed("p" + str(player_num) + "_jump"):
		emit_signal("action_jump")
	if event.is_action_pressed("p" + str(player_num) + "_dash"):
		emit_signal("action_dash")
	if event.is_action_pressed("p" + str(player_num) + "_left"):
		emit_signal("action_left")
	elif event.is_action_pressed("p" + str(player_num) + "_right"):
		emit_signal("action_right")
	if event.is_action_released("p" + str(player_num) + "_right") or event.is_action_released("p" + str(player_num) + "_left"):
		emit_signal("action_stop")

func _process(delta):
	if Input.is_action_pressed("p" + str(player_num) + "_left"):
		emit_signal("action_left")
	elif Input.is_action_pressed("p" + str(player_num) + "_right"):
		emit_signal("action_right")

func get_player():
	return playerDoll
