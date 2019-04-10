extends "res://HitBox.gd"

onready var _anim = $PunchAnim
#onready var _sprite = $PunchSprite
var alpha = 0.5

func _ready():
	# Godot auto calls the parent's ready function before calling this one
	box_type = PUNCH_BOX

func init(start_pos, strength, life_time=0.5, size=1, color = Color(1,1,1)):
	.init(start_pos, strength, life_time, size, color)
	#_sprite.modulate = Color(_color[0], _color[1], _color[2], alpha)
	_anim.modulate = color
	_anim.scale.x *= size
	_anim.play()
	

func on_area_entered(area):
	# duck type check if area is a fireball
	if 'fire_generator' in area:
		if area.fire_generator != get_parent():
			area.fire_generator = get_parent()
			area.fire_direction *= -1
			area.core.rotation *= -1
			area.tail.rotation *= -1
	elif 'box_type' in area:
		if area.box_type == DASH_BOX:
			queue_free()

