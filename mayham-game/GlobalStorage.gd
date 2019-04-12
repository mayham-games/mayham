extends Node

onready var players = []
onready var player_controllers = []

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func init_players(num_players):
	var playerController = ResourceLoader.load("res://PlayerController.tscn")
	var colors = makeColors(num_players)
	for i in range(num_players):
		var playerControl = playerController.instance()
		playerControl.init(i+1, colors[i])
		player_controllers.append(playerControl)
		players.append(playerControl.get_player())
		
func makeColors(num_players):
	var colors = []
	for i in range(num_players):
		var color = _random_color()
		while not checkColor(color, colors):
			color = _random_color()
		colors.append(color)
	return colors

func checkColor(color, colorArray):
	for i in range(colorArray.size()):
		if color == colorArray[i]:
			return false
	return true

func _random_color():
	randomize()
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