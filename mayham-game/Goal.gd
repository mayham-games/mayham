extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var player_list = preload("res://PlayerLinkedList.gd")

var players_in_goal = null
var players_not_in_goal = null

func init(players):
	players_in_goal = player_list.new()
	players_not_in_goal = player_list.new()
	for player in players:
		players_not_in_goal.push_back(player)

func _ready():
	connect("body_entered", self, "_on_Goal_entered")
	connect("body_exited", self, "_on_Goal_exited")

	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _on_Goal_entered(body):
	if body.is_class("StaticBody2D"):
		return
	var player = players_not_in_goal.pop_by_number(body.get_number())
	players_in_goal.push_back(player)

func _on_Goal_exited(body):
	var player = players_in_goal.pop_by_number(body.get_number())
	players_not_in_goal.push_back(player)

func _on_Goal_moved():
	players_not_in_goal.push_all(players_in_goal.pop_all())

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
