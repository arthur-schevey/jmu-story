extends KinematicBody

const ACCELERATION = 60
const MAX_SPEED = 2
const FRICTION = 60
const ROLL_SPEED = 3

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector3.ZERO
var input_vector = Vector3.ZERO
var ground_vector = Vector2(input_vector.x, input_vector.z)
var roll_vector = Vector3.LEFT

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	animationTree.active = true

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()
	

func move_state(delta):
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	ground_vector = Vector2(input_vector.x, input_vector.z)
	
	if input_vector != Vector3.ZERO:
		roll_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", ground_vector)
		animationTree.set("parameters/Run/blend_position", ground_vector)
		animationTree.set("parameters/Attack/blend_position", ground_vector)
		animationTree.set("parameters/Roll/blend_position", ground_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector3.ZERO, FRICTION * delta)
		
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
#
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attack_state():
	velocity = Vector3.ZERO
	animationState.travel("Attack")
	
func move():
	velocity = move_and_slide(velocity)
	
func roll_animation_finished():
	state = MOVE
#
func attack_animation_finished():
	state = MOVE
