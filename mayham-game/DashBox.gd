extends "res://HitBox.gd"

func _ready():
	# Godot auto calls the parent's ready function before calling this one
	box_type = DASH_BOX

func on_area_entered(area):
	# duck type check if area is a fireball
	if 'fire_generator' in area:
		if area.fire_generator != get_parent():
			queue_free()
