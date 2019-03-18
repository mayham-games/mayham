extends Node

var goal = null
onready var timelabel = $MatchTime		# Jordan

func init(players):
	goal = $Goal
	goal.init(players)

func _ready():
	timelabel.add_color_override("font_color",Color(0,0,0,1))			# Jordan
	timelabel.add_color_override("font_color_shadow",Color(1,1,1,1))	# was here
	pass

func award_points():
	goal.award_points()

func collect_players():
	return goal.collect_players()

func has_winner(winning_score):
	return goal.has_winner(winning_score)

func update_timer(time):
	$MatchTime.text = str(time)