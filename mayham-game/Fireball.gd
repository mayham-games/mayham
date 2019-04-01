# Fireball.gd
extends Area2D

var fireball_speed = 300
var fire_direction = 0
var fire_power = 100
var fire_generator

func _ready():
	set_process(true)
	connect("body_entered", self, "on_body_entered")
	
func init(generator, direction, speed, power):
	fire_direction = -1 * direction
	fireball_speed = speed
	fire_power = power
	fire_generator = generator

func _process(delta):
	var speed_x = -1
	var speed_y = 0
	var motion = Vector2(speed_x * sign(fire_direction), speed_y) * fireball_speed
	position += motion * delta

func _on_VisibilityNotifier2D_exit_screen():
	queue_free()

func on_body_entered( body ):
	queue_free()
	print(body.get_class())
	if body.get_class() == "KinematicBody2D" and body != fire_generator:
		body.position_hit(fire_power, position)
