# Fireball.gd
extends Area2D

var fireball_speed = 300
var fire_direction = 0
var fire_power = 100
var fire_generator

onready var core = $CollisionShape2D_1/Particles2D
onready var tail = $CollisionShape2D_1/Particles2D_tail

func _ready():
	set_process(true)
	connect("body_entered", self, "on_body_entered")
	connect("area_entered", self, "on_area_entered")
	
func init(generator, direction, speed, power, size):
	fire_direction = -1 * direction
	fireball_speed = speed
	fire_power = power
	fire_generator = generator
	core.rotation *= direction
	tail.rotation *= direction
	scale *= size

func _process(delta):
	var speed_x = -1
	var speed_y = 0
	var motion = Vector2(speed_x * sign(fire_direction), speed_y) * fireball_speed
	position += motion * delta

func _on_VisibilityNotifier2D_exit_screen():
	queue_free()

func on_body_entered( body ):
	if body.get_class() == "KinematicBody2D" and body != fire_generator:
		body.position_hit(fire_power, position)
		queue_free()
		
func on_area_entered(area):
	# duck type check if area is a fireball
	if 'fire_generator' in area:
		if area.fire_generator != fire_generator:
			queue_free()
