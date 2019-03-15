extends Node

var goal = null

func init(players):
	goal = $Goal
	goal.init(players)

func _ready():
	pass

func award_points():
	goal.award_points()

func collect_players():
	return goal.collect_players()

func has_winner(winning_score):
	return goal.has_winner(winning_score)

func update_timer(time):
	$MatchTime.text = str(time)
