extends Node

signal action_start
signal action_jump
signal action_left
signal action_right
signal action_dash
signal action_stop
signal action_attack
signal action_special

# Input Controls
# Constants
const ACTION_JUMP = "jump"
const ACTION_ATTACK = "attack"
const ACTION_SPECIAL = "special"
const ACTION_DASH = "dash"
const ACTION_LEFT = "left"
const ACTION_RIGHT = "right"
const ACTION_START = "start"

const INPUT_TYPE = "type"
const INPUT_BUTTON = "button"
const INPUT_MOTION = "motion"

const BUTTON_INDEX = "button_index"
const MOTION_AXIS = "axis"
const MOTION_AXIS_VALUE = "axis_value"

const P_BLUE  = Color( 0.0, 0.7, 1.0, 1 )

const DEFAULT_CONTROLS = {
	ACTION_JUMP : {
		INPUT_TYPE : INPUT_BUTTON,
		BUTTON_INDEX : JOY_XBOX_A
	},
	ACTION_ATTACK : {
		INPUT_TYPE : INPUT_BUTTON,
		BUTTON_INDEX : JOY_XBOX_B
	},
	ACTION_DASH : {
		INPUT_TYPE : INPUT_BUTTON,
		BUTTON_INDEX : JOY_XBOX_X
	},
	ACTION_SPECIAL : {
		INPUT_TYPE : INPUT_BUTTON,
		BUTTON_INDEX : JOY_XBOX_Y
	},
	ACTION_LEFT : {
		INPUT_TYPE : INPUT_MOTION,
		MOTION_AXIS : JOY_AXIS_0,
		MOTION_AXIS_VALUE : -1.0
	},
	ACTION_RIGHT : {
		INPUT_TYPE : INPUT_MOTION,
		MOTION_AXIS : JOY_AXIS_0,
		MOTION_AXIS_VALUE : 1.0
	},
	ACTION_START : {
		INPUT_TYPE : INPUT_BUTTON,
		BUTTON_INDEX : JOY_START
	}
}

var playerDoll = null
var number = 0
var color = P_BLUE

func init(num, col = P_BLUE):
	number = num
	color = col
	_setupInputEvents(DEFAULT_CONTROLS)

func _ready():
	var position_x = 100 * (number + 10) # (number - 5)
	var player = ResourceLoader.load("res://Player.tscn")
	playerDoll = player.instance()
	add_child(playerDoll)
	playerDoll.init(number, position_x, color)
	print("PC ready ", number)

func _setupInputEvents(controls):
	for action in controls.keys():

		var control_input = controls[action]

		if control_input.has(INPUT_TYPE):

			# We only want to create the event if we know how to handle that type and we have all
			# the necessary information for its input type
			if control_input[INPUT_TYPE] == INPUT_BUTTON and control_input.has(BUTTON_INDEX):

				var eventButton = InputEventJoypadButton.new()
				eventButton.set_device(number - 1)
				eventButton.set_button_index(control_input[BUTTON_INDEX])
				eventButton.set_pressed(true)

				if not InputMap.has_action("p" + str(number) + "_" + action):
					InputMap.add_action("p" + str(number) + "_" + action)
				InputMap.action_add_event("p" + str(number) + "_" + action, eventButton)

			elif control_input[INPUT_TYPE] == INPUT_MOTION and control_input.has(MOTION_AXIS) and control_input.has(MOTION_AXIS_VALUE):

				var eventAxis = InputEventJoypadMotion.new()
				eventAxis.set_device(number - 1)
				eventAxis.set_axis(control_input[MOTION_AXIS])
				eventAxis.set_axis_value(control_input[MOTION_AXIS_VALUE])

				if not InputMap.has_action("p" + str(number) + "_" + action):
					InputMap.add_action("p" + str(number) + "_" + action)
				InputMap.action_add_event("p" + str(number) + "_" + action, eventAxis)

func _input(event):
	if event.is_action_pressed("p" + str(number) + "_start"):
		emit_signal("action_start")
	if event.is_action_pressed("p" + str(number) + "_jump"):
		emit_signal("action_jump")
	if event.is_action_pressed("p" + str(number) + "_dash"):
		emit_signal("action_dash")
	if event.is_action_pressed("p" + str(number) + "_left"):
		emit_signal("action_left")
	elif event.is_action_pressed("p" + str(number) + "_right"):
		emit_signal("action_right")
	if event.is_action_released("p" + str(number) + "_right") or event.is_action_released("p" + str(number) + "_left"):
		emit_signal("action_stop")
	if event.is_action_pressed("p" + str(number) + "_attack"):
		emit_signal("action_attack")
	if event.is_action_pressed("p" + str(number) + "_special"):
		emit_signal("action_special")

func _process(delta):
	if Input.is_action_pressed("p" + str(number) + "_left"):
		emit_signal("action_left")
	elif Input.is_action_pressed("p" + str(number) + "_right"):
		emit_signal("action_right")

func get_player():
	return playerDoll
