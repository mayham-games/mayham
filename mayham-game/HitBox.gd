extends Area2D

# Constants
var DASH_BOX = 'dash'
var PUNCH_BOX = 'punch'

var time_to_death = 0.5
var power = 0
var box_type = 'base'
var _color = Color(0,0,0)

func init(start_pos, strength, life_time=0.5, size=1, color = Color(1,1,1)):
	time_to_death = life_time
	position += start_pos
	power = strength
	scale *= abs(size)
	_color = color

func _ready():
	connect("body_entered", self, "on_body_entered")
	connect("area_entered", self, "on_area_entered")

func _process(delta):
	time_to_death -= delta
	if time_to_death <= 0:
		queue_free()
	
func on_body_entered(body):
	if body.get_class() == "KinematicBody2D":
		if body != get_parent():
			body.position_hit(power, position + get_parent().position)
			
func on_area_entered(area):
	pass

