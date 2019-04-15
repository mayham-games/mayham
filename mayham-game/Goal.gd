extends Area2D

var color = _random_color()

onready var core = $Fire/particles_main
onready var tail = $Fire/particles_tail
onready var ring = $RingAnim/Ring
onready var aura = $Aura


func _ready():
	set_color(_random_color())

func move_to_position(position):
	pass

func award_points():
	#players_in_goal.add_point_to_all()
	var player_bodies = get_overlapping_bodies()
	for body in player_bodies:
		if body.is_class("KinematicBody2D"):
			body.increment_score_by(1)

func has_winner(winning_score):
	var player_bodies = get_overlapping_bodies()
	for body in player_bodies:
		if body.is_class("KinematicBody2D"):
			if body.get_score() > winning_score:
				return true

func change_color():
	set_color(_random_color())

func _random_color():
	randomize()
	var colors = [Color(0.7,0.0,1.0), Color(0.4,1.0,0.4), Color(0.0,0.7,1.0), Color(0.8,0.8,0.8)]
	var rand = randi()%colors.size()
	return colors[rand]
	
	var list = [1.0, 0.7, 0.0]
	if randi()%2 == 0:
		list = [1.0, 0.5, 0.2]
	var x = randi()%list.size()
	var c1 = list[x]
	list.remove(x)
	x = randi()%list.size()
	var c2 = list[x]
	list.remove(x)
	var c3 = list[0]
	return Color(c1,c2,c3)
	
func set_color(color):
	var x = 2
	var y = 0
	var a = 0.7
	
	#var core_col = Color( (color[0]*x-y)/(x+y), (color[1]*x-y)/(x+y), (color[2]*x-y)/(x+y), a )
	core.modulate = Color( color[0], color[1], color[2], a)
	tail.modulate = Color( color[0], color[1], color[2], a)
	ring.modulate = Color( color[0], color[1], color[2], a*0.75)
	ring.position = position
	aura.modulate = Color( color[0], color[1], color[2], a*0.5)
