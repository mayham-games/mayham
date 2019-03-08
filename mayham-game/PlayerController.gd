extends Node

signal action_start
signal action_jump
signal action_left
signal action_right
signal action_dash
signal action_stop

var player_num = 0

onready var player = preload("res://Player.tscn")

func _ready():
	var playerDoll = player.instance()
	playerDoll.position.x += 100 * (player_num - 5)
	add_child(playerDoll)
	print("PC ready ", player_num)
	
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