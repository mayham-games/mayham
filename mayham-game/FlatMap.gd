extends Node

var goal = null
onready var goal_positions = [ $GoalPosition1, $GoalPosition2, $GoalPosition3, $GoalPosition4 ]
onready var timelabel = $MatchTime

func init(players):
	goal = $Goal
	goal.init(players)

func _ready():
	timelabel.add_color_override("font_color",Color(0,0,0,1))
	timelabel.add_color_override("font_color_shadow",Color(1,1,1,1))

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
