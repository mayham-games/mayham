extends Node

signal action_start
signal action_jump
signal action_left
signal action_right
signal action_dash
signal action_stop
signal action_attack

var player_num = 0

onready var player = preload("res://Player.tscn")

func _ready():
	var playerDoll = player.instance()
	playerDoll.position.x += 100 * (player_num - 5)
	add_child(playerDoll)
	print("PC ready ", player_num)
	
func _input(event):
	if event.is_action_pressed("ui_start"):
		emit_signal("action_start")
	if event.is_action_pressed("ui_jump"):
		emit_signal("action_jump")
	if event.is_action_pressed("ui_dash"):
		emit_signal("action_dash")
	if event.is_action_pressed("ui_left"):
		emit_signal("action_left")
	elif event.is_action_pressed("ui_right"):
		emit_signal("action_right")
	if event.is_action_released("ui_right") or event.is_action_released("ui_left"):
		emit_signal("action_stop")
	if event.is_action_pressed("ui_attack"):
		emit_signal("action_attack")

func _process(delta):
	if Input.is_action_pressed("ui_left"):
		emit_signal("action_left")
	elif Input.is_action_pressed("ui_right"):
		emit_signal("action_right")