extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 20
const SPEED = 200
const JUMP_HEIGHT = -500

var motion = Vector2()

func _physics_process(delta):
	motion.y += GRAVITY
	
	if Input.is_action_pressed("ui_2right"):
		motion.x = SPEED
	elif Input.is_action_pressed("ui_2left"):
		motion.x = -SPEED
	else:
		motion.x = 0
		
	if is_on_floor():
		if Input.is_action_pressed("ui_2up"):
			motion.y = JUMP_HEIGHT
		
	motion = move_and_slide(motion, UP)
	pass
	
	#https://godotengine.org/qa/13995/get-keys-from-inputmap-gdscript