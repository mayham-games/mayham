extends Node

var goal = null
onready var goal_positions = [ $GoalPosition1, $GoalPosition2, $GoalPosition3, $GoalPosition4, $GoalPosition5 ]
onready var timelabel = $MatchTime

onready var mayham_particles = $ParticlesNode/MayhamParticles
onready var mayham_timer = $ParticlesNode/Timer
onready var announcer = $Announcer
onready var s_mayham = ResourceLoader.load("res://sounds/a_mayham2.wav")

func init(players):
	goal = $Goal
	goal.init(players)

func _ready():
	timelabel.add_color_override("font_color",Color(0,0,0,1))
	timelabel.add_color_override("font_color_shadow",Color(1,1,1,1))
	
	mayham_timer.connect("timeout",self, "stop_particles")
	mayham_particles.restart()
	mayham_particles.emitting = true
	mayham_timer.start()
	announcer.stream = s_mayham
	announcer.play(0)

func move_goal():
	var index = randi() % goal_positions.size()
	goal.position = goal_positions[index].position
	goal.change_color()


func award_points():
	goal.award_points()

func collect_players():
	return goal.collect_players()

func has_winner(winning_score):
	return goal.has_winner(winning_score)

func update_timer(time):
	$MatchTime.text = str(time)

func stop_particles():
	mayham_particles.emitting = false
