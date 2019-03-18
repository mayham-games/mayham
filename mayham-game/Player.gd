extends KinematicBody2D

#------------ Ezra Changed ------------------
const FIREBALL_SCENE = preload("Fireball.tscn")
var _attackTimer = null
#------------ Ezra Changed ------------------

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
const HIT_COOL_DOWN = 0.1	# Jordan

#States
const NO_STATE = 0
const GROUNDED_STATE = 1
const DASH_STATE = 2
const MOVING_STATE = 4
const COOL_STATE = 8
const HIT_STATE = 16		# Jordan

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
#------------ DJ Changed -----------------
var _score = 0							#|
var _number = 0							#|
#-----------------------------------------

onready var sprite = $PlayerSprite
onready var sprite_scale = sprite.scale.x

#---------------- Jordan -----------------
var hit_stun = 0
var hit_momentum = Vector2()
var hit_slow = Vector2()
onready var anim = $PlayerAnim
onready var anim_scale = anim.scale.x
#------------ end Jordan -----------------

#------------ DJ Changed -----------------
onready var score_label = $ScoreLabel	#|
										#|
func init(number, position_x):			#|
	_number = number					#|
	self.position.x += position_x		#|
#-----------------------------------------

func _ready():
	controller = get_parent()
	controller.connect("action_start", self, "_on_player_start")
	controller.connect("action_dash", self, "_on_player_dash")		# comment this line out and
	#controller.connect("action_dash", self, "_hit_test")			# this line in to test getting hit
	controller.connect("action_jump", self, "_on_player_jump")
	controller.connect("action_left", self, "_on_player_left")
	controller.connect("action_right", self, "_on_player_right")
	controller.connect("action_stop", self, "_on_player_stop")
	#---------------- Jordan -----------------
	sprite.hide()
	anim.show()
	score_label.add_color_override("font_color",Color(1,1,1,1))
	score_label.add_color_override("font_color_shadow",Color(0,0,0,1))
	#------------ end Jordan -----------------
	controller.connect("action_attack", self, "_on_player_attack") #----------------- Ezra Insert
	print(position)
	#(630, 178)

	#------------ Ezra Changed ------------------
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	#------------ Ezra Changed ------------------

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
		anim.stop()		# ------------- Jordan
		momentum.x = motion.x

func _on_player_left():
	if _is_state(COOL_STATE)  and !_is_state(DASH_STATE):
		motion.x = -SPEED
		last_direction = LEFT_DIR
		sprite.scale.x = -sprite_scale
		#---------------- Jordan -----------------
		anim.scale.x = -anim_scale
		if not anim.is_playing():
			anim.play()
		_enter_state(MOVING_STATE)
		#------------ end Jordan -----------------

func _on_player_right():
	if _is_state(COOL_STATE) and !_is_state(DASH_STATE):
		motion.x = SPEED
		last_direction = RIGHT_DIR
		sprite.scale.x = sprite_scale
		#---------------- Jordan -----------------
		anim.scale.x = anim_scale
		if not anim.is_playing():
			anim.play()
		_enter_state(MOVING_STATE)
		#------------ end Jordan -----------------


func _on_player_stop():
	if !_is_state(DASH_STATE):
		motion.x = 0
		anim.stop()		# ------------- Jordan
	_exit_state(MOVING_STATE)

#------------ Ezra Changed ------------------
func _on_player_attack():
	if timer.is_stopped():
		create_fireball()
		restart_timer()
#------------ Ezra Changed ------------------

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

	if input_cool_down <= 0.0 and _is_not_state(HIT_STATE):			# tweaked by Jordan
		_enter_state(COOL_STATE)

	if _is_state(COOL_STATE):
		momentum = Vector2()

	if _is_state(COOL_STATE) and _is_state(DASH_STATE):
		_exit_state(DASH_STATE)
		momentum = Vector2()

	if _is_state(DASH_STATE):
		motion = last_direction * DASH_SPEED
	elif _is_not_state(MOVING_STATE) and _is_not_state(HIT_STATE):	# tweaked by Jordan
		motion.x = 0

	if _is_state(GROUNDED_STATE):
		if _is_not_state(DASH_STATE):
			input_cool_down = 0.0
			dash_cnt = 0
			#_enter_state(COOL_STATE)
		if wall_jump_cnt > 0:
			wall_jump_cnt = 0
			wall_jump_decay = 1.0
	else:
		motion.y = min(TERMINAL_GRAVITY, motion.y + GRAVITY)

	motion += momentum

	#---------------- Jordan -----------------
	motion.x += hit_momentum.x

	if _is_state(HIT_STATE):
			hit_stun = max(0.0, hit_stun - delta)

	if hit_stun <= 0.0:
		_exit_state(HIT_STATE)
		hit_momentum = Vector2()

	if _is_state(HIT_STATE):
		print(hit_momentum)
		hit_momentum.x -= hit_slow.x*delta
		if hit_momentum.y != 0:
			hit_momentum.y -= hit_slow.y*delta

	#motion.y -= hit_momentum.y
	#------------ end Jordan -----------------

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



#rotate(angle)

#---------------- Jordan -----------------
func vector_hit(power, vector):
	vector = vector.normalized()
	hit_stun = HIT_COOL_DOWN*(power/100)
	_enter_state(HIT_STATE)
	_exit_state(COOL_STATE)
	anim.stop()
	hit_momentum = vector*(2*power^2)
	hit_slow = hit_momentum*(100/(HIT_COOL_DOWN*power))
	motion.y = hit_momentum.y

func position_hit(power, pos):
	var vector = Vector2(position - pos).normalized()
	hit_stun = HIT_COOL_DOWN*(power/100)
	_enter_state(HIT_STATE)
	_exit_state(COOL_STATE)
	anim.stop()
	hit_momentum = vector*(2*power^2)
	hit_slow = hit_momentum*(100/(HIT_COOL_DOWN*power))
	motion.y = hit_momentum.y

func _hit_test():
	# vector hit test
	var vec = Vector2(rand_range(-1,1),rand_range(-1,0))
	vector_hit(200, vec)

	# position hit test
	#var vec = position + Vector2(100,100)
	#position_hit(500, vec)
#------------ end Jordan -----------------

#------------ DJ Changed -----------------
func get_number():						#|
	return _number						#|
										#|
func get_score():						#|
	return _score						#|
										#|
func _update_score_label():				#|
	score_label.text = str(_score)		#|
										#|
func increment_score_by(number):		#|
	_score += number					#|
	_update_score_label()				#|
#-----------------------------------------

#------------ Ezra Changed -----------------
func create_fireball():
	var fireball = FIREBALL_SCENE.instance()
	get_parent().add_child(fireball)
	fireball.position = position + Vector2(50 * sign(last_direction.x), 0)

func restart_timer():
	timer.set_wait_time(1)
	timer.start()

func _on_Timer_timeout():
	print("timer expires")
	timer.stop()

func _hit():
	print("hit")
	motion.y = JUMP_HEIGHT/8
	motion.x = JUMP_HEIGHT*3
#------------ Ezra Changed -----------------
