# Fireball.gd
extends Area2D

const FIREBALL_SPEED = 300

func _ready():
	set_process(true)
	connect("body_entered", self, "on_body_entered")

func _process(delta):
	var speed_x = -1
	var speed_y = 0
	var motion = Vector2(speed_x, speed_y) * FIREBALL_SPEED
	position += motion * delta

func _on_VisibilityNotifier2D_exit_screen():
	queue_free()

func on_body_entered( body ):
	queue_free()
	if body == KinematicBody:
		body._hit()
