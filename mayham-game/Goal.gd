extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var players_in_goal = null
var players_not_in_goal = null

var color = _random_color()

onready var core = $Fire/particles_main
onready var tail = $Fire/particles_tail
onready var ring = $RingAnim/Ring
onready var aura = $Aura

func init(players):
	var player_list = ResourceLoader.load("res://PlayerLinkedList.gd")
	players_in_goal = player_list.new()
	players_not_in_goal = player_list.new()
	for player in players:
		players_not_in_goal.push_back(player)
	print("init:")
	print_lists()

func print_lists():
	print("players_in_goal:")
	players_in_goal.print_list()
	print("players_not_in_goal:")
	players_not_in_goal.print_list()

func _ready():
	connect("body_entered", self, "_on_Goal_entered")
	connect("body_exited", self, "_on_Goal_exited")

	set_color(_random_color())
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _on_Goal_entered(body):
	if body.is_class("KinematicBody2D"):
		var player = players_not_in_goal.pop_by_number(body.get_number())
		players_in_goal.push_back(player)
		print("_on_Goal_entered:")
		print_lists()

func _on_Goal_exited(body):
	if body.is_class("KinematicBody2D"):
		var player = players_in_goal.pop_by_number(body.get_number())
		players_not_in_goal.push_back(player)
		print("_on_Goal_exited:")
		print_lists()

func _on_Goal_moved():
	players_not_in_goal.push_all(players_in_goal.pop_all())
	var intersecting_players = get_overlapping_bodies()
	for player in intersecting_players:
		if player.is_class("KinematicBody2D"):
			players_in_goal.push(players_not_in_goal.pop_by_number(player.get_number()))

func move_to_position(position):
	pass

func award_points():
	players_in_goal.add_point_to_all()

func collect_players():
	players_not_in_goal.push_all(players_in_goal.pop_all())
	return players_not_in_goal.pop_all_ordered_by_highest_score()

func has_winner(winning_score):
	return players_in_goal.has_winner(winning_score) or players_not_in_goal.has_winner(winning_score)

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
