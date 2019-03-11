extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var players_in_goal = null
var players_not_in_goal = null

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

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
