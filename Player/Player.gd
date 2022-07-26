extends KinematicBody2D

export (NodePath) var joystick_one_path;

var joystick_one;

const JOYSTICK_DEADZONE = 0.4;

const ACCELERATION = 400
const MAX_SPEED = 80
const FRICTION = 400

enum{
	MOVE,
	ROLL,
	ATTACK
}

var state  = MOVE

var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitBox

func _ready():
	joystick_one = get_node(joystick_one_path);
	animationTree.active = true
	swordHitbox.knockback_vector = Vector2.LEFT
	
func _process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			pass
		ATTACK:
			attack_state(delta)
			
func attack_animation_finished():
	state = MOVE
	
func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	input_vector = input_vector.normalized()
	
	if (joystick_one.joystick_vector.length() > JOYSTICK_DEADZONE/2):
		animationState.travel("Run")
		input_vector = - joystick_one.joystick_vector
	
	if input_vector != Vector2.ZERO:
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	velocity = move_and_slide(velocity)
	
	if(Input.is_action_just_pressed("attack")):
		state = ATTACK

 


func _on_hit_pressed():
	state = ATTACK
