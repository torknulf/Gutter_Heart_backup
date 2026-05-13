class_name OverworldPLayer extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

enum States {IDLE, WALKING, FALLING, LOCKED}
var state:
	set(newState):
		var prevState = state
		state = newState  
		_on_state_changed(prevState) 



func _on_state_changed(prevState):
	pass



func _ready() -> void:
	state = States.IDLE
	DialogueManager.inDialogue.connect(lock_movement)



func lock_movement(isLocked):
	if isLocked:
		state = States.LOCKED
	else: # here the player can move again
		state = States.IDLE
	
	




func _physics_process(delta: float) -> void:
	if state == States.LOCKED:
		return




	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("input_left", "input_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
