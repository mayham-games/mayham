extends Node

var goal = null
onready var goal_positions = [ $GoalPosition1, $GoalPosition2, $GoalPosition3, $GoalPosition4 ]


func init(players):
	goal = $Goal
	goal.init(players)

func _ready():
	pass

func move_goal():
	var index = randi() % goal_positions.size()
	goal.position = goal_positions[index].position

func award_points():
	goal.award_points()

func collect_players():
	return goal.collect_players()

func has_winner(winning_score):
	return goal.has_winner(winning_score)

func update_timer(time):
	$MatchTime.text = str(time)
