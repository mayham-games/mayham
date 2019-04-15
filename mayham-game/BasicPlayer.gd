extends KinematicBody2D

## Direction Vectors
# Constants
const UP_DIR = Vector2(0, -1)
const DOWN_DIR = Vector2(0, 1)
const LEFT_DIR = Vector2(-1, 0)
const RIGHT_DIR = Vector2(1, 0)
const NO_DIR = Vector2(0, 0)

## Physics
# Constants
const GRAVITY_ACCEL = 20 # Change in y velocity due to gravity
const TERMINAL_GRAVITY_VELOCITY = 1000 # maximum speed that gravity can cause the player to move downwards
const GROUND_SPEED = 200 # speed that the player moves on the ground
const JUMP_STRENGTH = -550 # metric for calculating jump height and duration
const MASS = 425 # mass metric for push back calculations
const DASH_SPEED = 800 # speed that the player moves when dashing
const DASH_POWER = 100 # strength of the hit when the player is dashing
const WALL_JUMP_SPEED = 400 # speed the player moves away from a wall when wall jumping
const WALL_JUMP_DECAY = 0.85
const TERMINAL_HIT_VELOCITY = 1500 # max knockback velocity
# Variables
var curr_velocity = Vector2(0, 0)

## Player Specific Mechanics
# Constants
const MAX_WALL_JUMP_CNT = 5 # Max number of times a player can wall jump before needing to touch the ground again
const MAX_DASH_CNT = 2 # Max number of times a player can dash before needing to touch the ground
const MAX_JUMP_CNT = 2 # Max number of times a player can jump until needing to touch the ground
const ATTACK_POWER = 150 # Strength of a players attack
const ATTACK_COOLDOWN = 0.15 # number of secs until input from controller will be accepted after attacking
const ATTACK_OFFSET = Vector2(40, 0) # how far away from the player the punch hitbox should appear
const STUN_COOLDOWN = 0.05 # constant for number of secs until input from controller will be accepted after getting hit
const WALL_JUMP_COOLDOWN = 0.15 # number of secs until input from controller will be accepted after wall jumping
const DASH_COOLDOWN = 0.25 # number of secs until input from controller will be accepted after dashing
const SPECIAL_COOLDOWN = 1.0 # number of secs until the player can use its special can be used again
const FIREBALL_SCENE = preload("Fireball.tscn")
const FIREBALL_SPEED = 400
const FIREBALL_POWER = 200
const FIREBALL_SCALE = 2
const PUNCH_BOX_SCENE = preload("res://PunchBox.tscn")
const DASH_BOX_SCENE = preload("res://DashBox.tscn")

# Variables
var wall_jump_cnt = 0
var wall_jump_dir = NO_DIR
var jump_cnt = 1
var dash_cnt = 0
var last_input_direction = RIGHT_DIR
var _score = 0
var _number = 0
var cooldown_time = 0
var stun_cooldown = 0		# timer for secs until input from controller will be accepted after getting hit
var hit_momentum = Vector2()		# knock back applied after getting hit
var special_cooldown_timer = 0 
var hit_slow = Vector2()		# decay factor for hit_momentum

# ART / ANIMATION
onready var _bubble = $Bubble
onready var _sprite = $PlayerAnim
onready var _sprite_scale = _sprite.scale.x
onready var _trail = $Trail

const P_BLUE  = Color( 0.0, 0.7, 1.0, 1 )
const P_RED   = Color( 1.0, 0.3, 0.6, 1 )
const P_GREEN = Color( 0.0, 0.8, 0.4, 1 )
const P_PURP  = Color( 0.6, 0.2, 1.0, 1 )
onready var _player_color = P_BLUE

# Sound Effects
onready var sfx = $Sfx
onready var s_jmp = ResourceLoader.load("res://sounds/jump7.wav")
onready var s_hit = ResourceLoader.load("res://sounds/hit4.wav")
onready var s_atk = ResourceLoader.load("res://sounds/atk3.wav")
onready var s_dsh = ResourceLoader.load("res://sounds/dash5.wav")

# Nodes
onready var score_label = $ScoreLabel
onready var special_meter = $SpecialMeter

## State Spaces **see achitecture documents for explanation on states
# Constants
enum INPUT_STATE {
	control,
	hit,
	cooldown
}
enum WORLD_STATE {
	grounded,
	airborne,
	air_walled,
	air_capped
}
enum ACTION_STATE {
	idle,
	move,
	attack,
	dash,
	wall_jump
	knock_back
}

# Variables
var curr_input_state = INPUT_STATE.control
var curr_world_state = WORLD_STATE.airborne
var curr_action_state = ACTION_STATE.idle

## Controller
# Constants
enum ACTIONS {
	left,
	right,
	stop,
	jump,
	dash,
	attack,
	special
}
# Variables
var controller
var player_number = 0
var input_queue = Array()

func _ready():
	controller = get_parent()
	controller.connect("action_start", self, "_on_player_start")
	controller.connect("action_dash", self, "_on_player_dash")
	controller.connect("action_jump", self, "_on_player_jump")
	controller.connect("action_left", self, "_on_player_left")
	controller.connect("action_right", self, "_on_player_right")
	controller.connect("action_stop", self, "_on_player_stop")
	controller.connect("action_attack", self, "_on_player_attack")
	controller.connect("action_special", self, "_on_player_special")

	_sprite.connect("animation_finished", self, "_animation")
	_animation()

	print(position)
	score_label.add_color_override("font_color",Color(1,1,1,1))
	score_label.add_color_override("font_color_shadow",Color(0,0,0,1))
	
	# Start the game without a special avaliable
	special_cooldown_timer = SPECIAL_COOLDOWN
	special_meter.visible = true
	special_meter.value = (1 - special_cooldown_timer / SPECIAL_COOLDOWN) * special_meter.max_value
	special_meter.update()

func init(number, position_x, color = P_BLUE):
	_number = number
	self.position.x += position_x
	self.position.y = 700
	set_color(color)

func _on_player_start():
	print("START")
	_print_debug()

func _print_debug():
	print("Input state:")
	match curr_input_state:
		INPUT_STATE.control:
			print("\tcontrol")
		INPUT_STATE.cooldown:
			print("\tcooldown ", cooldown_time)
		INPUT_STATE.hit:
			print("\thit ", stun_cooldown, " ", hit_momentum)
	
	print("World state:")
	match curr_world_state:
		WORLD_STATE.grounded:
			print("\tgrounded")
		WORLD_STATE.airborne:
			print("\tairborne")
		WORLD_STATE.air_walled:
			print("\tair_walled")
		WORLD_STATE.air_capped:
			print("\tair_capped")
	
	print("Action state:")
	match curr_action_state:
		ACTION_STATE.idle:
			print("\tidle")
		ACTION_STATE.move:
			print("\tmove")
		ACTION_STATE.wall_jump:
			print("\twall_jump")
		ACTION_STATE.attack:
			print("attack")
		ACTION_STATE.dash:
			print("\tdash")
		ACTION_STATE.knock_back:
			print("\tknock_back")


func _on_player_dash():
	input_queue.append(ACTIONS.dash)

func _on_player_jump():
	input_queue.append(ACTIONS.jump)

func _on_player_left():
	input_queue.append(ACTIONS.left)

func _on_player_right():
	input_queue.append(ACTIONS.right)

func _on_player_attack():
	input_queue.append(ACTIONS.attack)
	
func _on_player_special():
	input_queue.append(ACTIONS.special)

func _on_player_stop():
	input_queue.append(ACTIONS.stop)

func _execute_player_dash():
	if dash_cnt < MAX_DASH_CNT and (curr_action_state == ACTION_STATE.idle or curr_action_state == ACTION_STATE.move):
		curr_action_state = ACTION_STATE.dash
		curr_input_state = INPUT_STATE.cooldown
		dash_cnt += 1
		cooldown_time += DASH_COOLDOWN
		var dash_box = DASH_BOX_SCENE.instance()
		add_child(dash_box)
		dash_box.init(NO_DIR, DASH_POWER, DASH_COOLDOWN)
		sfx.stream = s_dsh
		sfx.play(0)
		_animation("dash")

func _execute_player_jump():
	if curr_world_state == WORLD_STATE.air_walled and wall_jump_cnt < MAX_WALL_JUMP_CNT:
		curr_action_state = ACTION_STATE.wall_jump
		curr_input_state = INPUT_STATE.cooldown
		wall_jump_dir = last_input_direction
		last_input_direction = -last_input_direction
		wall_jump_cnt += 1
		cooldown_time += WALL_JUMP_COOLDOWN
		sfx.stream = s_jmp
		sfx.play(0)
	elif jump_cnt < MAX_JUMP_CNT:
		curr_velocity.y = JUMP_STRENGTH
		jump_cnt += 1
		sfx.stream = s_jmp
		sfx.play(0)

func _execute_player_left():
	if curr_action_state == ACTION_STATE.idle or curr_action_state == ACTION_STATE.move:
		curr_action_state = ACTION_STATE.move
		_sprite.scale.x = -_sprite_scale
	
	last_input_direction = LEFT_DIR

func _execute_player_right():
	if curr_action_state == ACTION_STATE.idle or curr_action_state == ACTION_STATE.move:
		curr_action_state = ACTION_STATE.move
		_sprite.scale.x = _sprite_scale
	
	last_input_direction = RIGHT_DIR

func _execute_player_attack():
	curr_action_state = ACTION_STATE.attack
	cooldown_time += ATTACK_COOLDOWN
	curr_input_state = INPUT_STATE.cooldown
	var punch_box = PUNCH_BOX_SCENE.instance()
	add_child(punch_box)
	punch_box.init(sign(last_input_direction.x) * ATTACK_OFFSET, ATTACK_POWER, ATTACK_COOLDOWN, _sprite.scale.x/_sprite_scale, _player_color)
	sfx.stream = s_atk
	sfx.play(0)
	_animation("attack")

func _execute_player_special():
	if special_cooldown_timer == 0:
		create_fireball()
		
		curr_action_state = ACTION_STATE.attack
		cooldown_time += ATTACK_COOLDOWN
		curr_input_state = INPUT_STATE.cooldown
		
		special_cooldown_timer = SPECIAL_COOLDOWN
		special_meter.visible = true
		special_meter.value = (1 - special_cooldown_timer / SPECIAL_COOLDOWN) * special_meter.max_value
		_animation("fire")


func _execute_player_stop():
	if curr_action_state == ACTION_STATE.move:
		curr_action_state = ACTION_STATE.idle

func _update_world_state():
	if curr_world_state == WORLD_STATE.grounded and !is_on_floor():
		if is_on_ceiling():
			curr_world_state = WORLD_STATE.air_capped
		elif is_on_wall():
			curr_world_state = WORLD_STATE.air_walled
		else:
			curr_world_state = WORLD_STATE.airborne
	elif !is_on_floor():
		if curr_world_state != WORLD_STATE.air_capped and is_on_ceiling():
			curr_world_state = WORLD_STATE.air_capped
		elif curr_world_state != WORLD_STATE.air_walled and is_on_wall() and !is_on_ceiling():
			curr_world_state = WORLD_STATE.air_walled
		elif curr_world_state != WORLD_STATE.airborne and !is_on_ceiling() and !is_on_wall():
			curr_world_state = WORLD_STATE.airborne
	elif curr_world_state != WORLD_STATE.grounded and is_on_floor():
		curr_world_state = WORLD_STATE.grounded
		wall_jump_cnt = 0
		wall_jump_dir = NO_DIR
		dash_cnt = 0
		jump_cnt = 0

func _physics_process(delta):
	# update control state	
	if curr_input_state == INPUT_STATE.hit or curr_input_state == INPUT_STATE.cooldown:
		cooldown_time = max(cooldown_time - delta, 0)
		stun_cooldown = max(stun_cooldown - delta, 0)
		if cooldown_time <= 0 and stun_cooldown <= 0:
			curr_input_state = INPUT_STATE.control
			curr_action_state = ACTION_STATE.idle
			hit_momentum = Vector2()
			
	if special_cooldown_timer != 0:
		special_cooldown_timer = max(special_cooldown_timer - delta, 0)
		special_meter.value = min(1 - special_cooldown_timer / SPECIAL_COOLDOWN, 1) * special_meter.max_value
		special_meter.update()
	elif special_meter.visible:
		special_meter.visible = false

	# update world state
	_update_world_state()

	# update control state
	if curr_input_state == INPUT_STATE.control:
		var action = -1
		while !input_queue.empty():
			action = input_queue.pop_front()
			#print("Handle:", action)
			match action:
				ACTIONS.left:
					_execute_player_left()
				ACTIONS.right:
					_execute_player_right()
				ACTIONS.stop:
					_execute_player_stop()
				ACTIONS.jump:
					_execute_player_jump()
				ACTIONS.dash:
					_execute_player_dash()
				ACTIONS.attack:
					_execute_player_attack()
				ACTIONS.special:
					_execute_player_special()
	else:
		# Remove all actions when not able to control
		# not doing this allows for action buffering which create some cool movement options
		while !input_queue.empty():
			input_queue.pop_front()

	# apply state effects
	if curr_action_state == ACTION_STATE.wall_jump:
		curr_velocity.x = -WALL_JUMP_SPEED * sign(wall_jump_dir.x)
		curr_velocity.y = JUMP_STRENGTH * pow(WALL_JUMP_DECAY, wall_jump_cnt)
	elif curr_action_state == ACTION_STATE.dash:
		curr_velocity = last_input_direction * DASH_SPEED
	elif curr_action_state == ACTION_STATE.move:
		if curr_world_state == WORLD_STATE.grounded:
			curr_velocity.x = last_input_direction.x * GROUND_SPEED
		else:
			curr_velocity.x += last_input_direction.x * GROUND_SPEED

		curr_velocity.x = sign(curr_velocity.x) * min(abs(curr_velocity.x), GROUND_SPEED)
	elif curr_action_state == ACTION_STATE.idle:
		curr_velocity.x = NO_DIR.x
	elif curr_action_state == ACTION_STATE.knock_back:
		curr_velocity = hit_momentum
		hit_momentum.x -= hit_slow.x*delta
		hit_momentum.y -= hit_slow.y*delta
		
		if curr_world_state == WORLD_STATE.air_walled:
			curr_velocity.x *= -1
			hit_momentum.x *= -1
		if  curr_world_state == WORLD_STATE.air_capped or curr_world_state == WORLD_STATE.grounded:
			curr_velocity.y *= -1
			hit_momentum.y *= -1
	
	if curr_world_state != WORLD_STATE.grounded and curr_action_state != ACTION_STATE.dash:
		curr_velocity.y = min(TERMINAL_GRAVITY_VELOCITY, curr_velocity.y + GRAVITY_ACCEL)

	
	# move
	move_and_slide(curr_velocity, UP_DIR)
	
	# wrap-around screen
	if position.x < 0:
		position.x = get_viewport().size.x
	elif position.x > get_viewport().size.x:
		position.x = 0
	
	if position.y < 0:
		position.y = get_viewport().size.y
	elif position.y > get_viewport().size.y:
		position.y = 0

	_update_world_state()

func get_number():
	return _number

func get_score():
	return _score

func _update_score_label():
	score_label.text = str(_score)

func increment_score_by(number):
	_score += number
	_update_score_label()

func vector_hit(power, vector):
	sfx.stream = s_hit
	sfx.play(0)
	if curr_world_state == WORLD_STATE.grounded:
		vector.y = abs(vector.y)*-1 - 1.0
	#print(vector)
	vector = vector.normalized()
	stun_cooldown = STUN_COOLDOWN*(power/10)
	curr_input_state = INPUT_STATE.hit
	curr_action_state = ACTION_STATE.knock_back
	hit_momentum = (vector*10*(power) + curr_velocity).clamped(TERMINAL_HIT_VELOCITY)
	hit_slow = hit_momentum*(10/(STUN_COOLDOWN*power))
	#curr_velocity.y = hit_momentum.y

func position_hit(power, pos):
	var vector = Vector2(position - pos).normalized()
	vector_hit(power, vector)

func _hit_test():
	# vector hit test
	#var vec = Vector2(rand_range(-1,1),rand_range(-1,0))
	#vector_hit(100, vec)

	# position hit test
	var vec = position + Vector2(100,100)
	position_hit(100, vec)

func create_fireball():
	var fireball = FIREBALL_SCENE.instance()
	get_parent().get_parent().add_child(fireball)
	fireball.init(self, last_input_direction.x, FIREBALL_SPEED, FIREBALL_POWER, FIREBALL_SCALE, _player_color)
	fireball.position = position + Vector2(10 * sign(last_input_direction.x), 0)

func set_color(color):
	_player_color = color
	_bubble.modulate = color
	_trail.modulate = color
	
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

func _animation(anim = ""):
	#print (anim,_sprite.animation, _sprite.is_playing()) 
	if anim == "attack":
		_sprite.play("attack")
	elif anim == "fire":
		_sprite.play("fire")
	elif anim == "fire":
		_sprite.play("fire")
	elif anim == "dash":
		_sprite.play("dash")
	else:
		_sprite.play("idle")
