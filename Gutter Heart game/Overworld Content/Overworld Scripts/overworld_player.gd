class_name OverworldPLayer extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

enum States {IDLE, WALKING, FALLING, LOCKED}
var state:
	set(newState):
		var prevState = state
		state = newState  
		_on_state_changed(prevState) 

var facingDir := 0.0

func _on_state_changed(prevState):
	pass


func _ready() -> void:
	state = States.IDLE
	DialogueManager.inDialogue.connect(lock_movement)
	DialogueManager.canAdvance = true
	%AnimationTree.active = true



func lock_movement(isLocked):
	if isLocked:
		state = States.LOCKED
	else: # here the player can move again
		state = States.IDLE
	
	




func _physics_process(delta: float) -> void:
	if state == States.LOCKED:
		return
	
	#print(state)


	var direction := Input.get_axis("input_left", "input_right")

	if direction:
		state = States.WALKING
		velocity.x = direction * SPEED
		facingDir = velocity.x
		
	else:
		state = States.IDLE
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY



	face_forward()
	apply_gravity(delta)
	move_and_slide()





func face_forward():
	if facingDir >= 0:
		%PlayerSprite.flip_h = false
	else:
		%PlayerSprite.flip_h = true
	

func apply_gravity(delta):
	
	if not is_on_floor():
		velocity += get_gravity() * delta
