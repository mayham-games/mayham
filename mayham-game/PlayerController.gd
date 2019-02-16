extends Node

signal p1_start
signal p1_jump
signal p1_left
signal p1_right
signal p1_dash
signal p1_stop


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
func _input(event):
	if event.is_action_pressed("ui_start"):
		emit_signal("p1_start")
	if event.is_action_pressed("ui_jump"):
		emit_signal("p1_jump")
	if event.is_action_pressed("ui_dash"):
		emit_signal("p1_dash")
	if event.is_action_pressed("ui_left"):
		emit_signal("p1_left")
	elif event.is_action_pressed("ui_right"):
		emit_signal("p1_right")
	if event.is_action_released("ui_right") or event.is_action_released("ui_left"):
		emit_signal("p1_stop")

func _process(delta):
	if Input.is_action_pressed("ui_left"):
		emit_signal("p1_left")
	elif Input.is_action_pressed("ui_right"):
		emit_signal("p1_right")