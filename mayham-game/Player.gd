extends KinematicBody2D

const UP_DIR = Vector2(0, -1)
const LEFT_DIR = Vector2(-1, 0)
const RIGHT_DIR = Vector2(1, 0)
const GRAVITY = 20
const SPEED = 200
const JUMP_HEIGHT = -550
const WALL_JUMP_DECAY = 0.85
const MAX_WALL_JUMP = 5
const MAX_DASH = 1
const TERMINAL_GRAVITY = 1000
const MOMENTUM_DECAY = 0.95
const MOMENTUM_TERM = 0.85
const MOMENTUM_STEPS = 5
const DASH_SPEED = 800

#Cooldowns
const WALL_JUMP_COOL_DOWN = 0.35
const DASH_COOL_DOWN = 0.25

#States
const NO_STATE = 0
const GROUNDED_STATE = 1
const DASH_STATE = 2
const MOVING_STATE = 4
const COOL_STATE = 8

var motion = Vector2()
var wall_jump_cnt = 0
var wall_jump_decay = 1.0
var input_cool_down = 0
var momentum = Vector2()
var momentum_step_cnt = 0
var curr_state = NO_STATE
var last_direction = Vector2()
var dash_cnt = 0
var controller

onready var sprite = $Sprite
onready var sprite_scale = sprite.scale.x

func _ready():
	controller = get_tree().get_root().get_node("World").find_node("PlayerController")
	controller.connect("p1_start", self, "_on_player_start")
	controller.connect("p1_dash", self, "_on_player_dash")
	controller.connect("p1_jump", self, "_on_player_jump")
	controller.connect("p1_left", self, "_on_player_left")
	controller.connect("p1_right", self, "_on_player_right")
	controller.connect("p1_stop", self, "_on_player_stop")
	
func _is_state(state):
	return (curr_state & state) == state

func _is_not_state(state):
	return (curr_state & state) == 0

func _enter_state(state):
	curr_state = curr_state | state
	
func _exit_state(state):
	curr_state = curr_state & ~state
	
func _on_player_start():
	if _is_state(GROUNDED_STATE):
		print("player is on the ground")
	else:
		print("player is in the air")
		
	if _is_state(DASH_STATE):
		print("player is dashing")
	else:
		print("player is not dashing ", dash_cnt)
	
	if _is_state(MOVING_STATE):
		print("player is moving")
	else:
		print("player is not moving")
		
	if _is_state(COOL_STATE):
		print("player is cooled")
	else:
		print("player is in cool down ", input_cool_down)
	
func _on_player_dash():
	if _is_state(COOL_STATE) and dash_cnt < MAX_DASH:
		input_cool_down = DASH_COOL_DOWN
		_enter_state(DASH_STATE)
		_exit_state(COOL_STATE)
		dash_cnt += 1
	
func _on_player_jump():
	if _is_state(COOL_STATE) and _is_state(GROUNDED_STATE):
		motion.y = JUMP_HEIGHT
		_exit_state(GROUNDED_STATE)
	
	elif _is_not_state(GROUNDED_STATE) and is_on_wall() and wall_jump_cnt < MAX_WALL_JUMP:
		wall_jump_decay = pow(WALL_JUMP_DECAY, wall_jump_cnt)
		motion.x = -2 * sign(motion.x) * SPEED
		motion.y = JUMP_HEIGHT * wall_jump_decay
		wall_jump_cnt += 1
		input_cool_down = WALL_JUMP_COOL_DOWN
		_exit_state(COOL_STATE)
		_exit_state(DASH_STATE)
		_exit_state(MOVING_STATE)
		momentum.x = motion.x
	
func _on_player_left():
	if _is_state(COOL_STATE)  and !_is_state(DASH_STATE):
		motion.x = -SPEED
		last_direction = LEFT_DIR
		sprite.scale.x = -sprite_scale
		_enter_state(MOVING_STATE)

func _on_player_right():
	if _is_state(COOL_STATE) and !_is_state(DASH_STATE):
		motion.x = SPEED
		last_direction = RIGHT_DIR
		sprite.scale.x = sprite_scale
		_enter_state(MOVING_STATE)


func _on_player_stop():
	if !_is_state(DASH_STATE):
		motion.x = 0
	
	_exit_state(MOVING_STATE)

func _physics_process(delta):
	momentum *= MOMENTUM_DECAY
	
	if momentum != Vector2() and (_is_state(GROUNDED_STATE) or _is_state(COOL_STATE)):
		momentum_step_cnt += 1
	else:
		momentum_step_cnt = 0
		
	if momentum_step_cnt > MOMENTUM_STEPS:
		momentum = Vector2()
		momentum_step_cnt = 0
	
	if _is_not_state(COOL_STATE):
		input_cool_down = max(0.0, input_cool_down - delta)
	
	if input_cool_down <= 0.0:
		_enter_state(COOL_STATE)
	
	if _is_state(COOL_STATE) and _is_state(DASH_STATE):
		_exit_state(DASH_STATE)
		momentum = Vector2()
	
	if _is_state(DASH_STATE):
		motion = last_direction * DASH_SPEED
	elif _is_not_state(MOVING_STATE):
		motion.x = 0
	
	if _is_state(GROUNDED_STATE):
		if _is_not_state(DASH_STATE):
			input_cool_down = 0.0
			dash_cnt = 0
			_enter_state(COOL_STATE)
		if wall_jump_cnt > 0:
			wall_jump_cnt = 0
			wall_jump_decay = 1.0
	else:
		motion.y = min(TERMINAL_GRAVITY, motion.y + GRAVITY)
	
	motion += momentum
	
	if _is_not_state(DASH_STATE):
		if _is_state(COOL_STATE):
			motion.x = sign(motion.x) * min(abs(motion.x), SPEED)
		else:
			motion.x = sign(motion.x) * min(abs(motion.x), 2*SPEED)
	
	var movement = move_and_slide(motion, UP_DIR)
	
	if is_on_floor() and _is_not_state(GROUNDED_STATE):
		_enter_state(GROUNDED_STATE)
	elif !is_on_floor() and _is_state(GROUNDED_STATE):
		_exit_state(GROUNDED_STATE)
	
	
	
	if is_on_wall() and _is_state(DASH_STATE):
		input_cool_down = 0.0
		_exit_state(DASH_STATE)
		momentum = Vector2()
	
	var angle = 0.0
	if motion.x != 0:
		angle = PI / 28 * sign(last_direction.x)
	
	if movement.y != 0:
		angle *= 1.5
	
	rotate(angle)
	