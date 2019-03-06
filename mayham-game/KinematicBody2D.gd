extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#Func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

var motion = Vector2()


func _physics_process(delta):
	
	if Input.is_action_pressed("ui_right"):
		motion.x = 100
	
	pass