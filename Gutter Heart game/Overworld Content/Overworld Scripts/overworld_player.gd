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

var interactionList = []
var canAct = [States.IDLE, States.WALKING]

func _on_state_changed(prevState):
	pass


func _ready() -> void:
	state = States.IDLE
	DialogueManager.inDialogue.connect(lock_movement)
	DialogueManager.canAdvance = true
	%AnimationTree.active = true



func lock_movement(isLocked):
	if get_tree() != null:
		await get_tree().process_frame
		
	if isLocked:
		state = States.LOCKED
	else: # here the player can move again
		state = States.IDLE
	

func _process(delta: float) -> void:
	pass


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


	if Input.is_action_just_pressed("Interact") and is_on_floor() and state in canAct:
		
		try_interact()




	face_forward()
	apply_gravity(delta)
	move_and_slide()





func face_forward():
	if facingDir >= 0: # right
		%PlayerSprite.flip_h = false
		%InteractionCollisionShape2D.position.x = 75
	else: # left
		%PlayerSprite.flip_h = true
		%InteractionCollisionShape2D.position.x = -75
	

func apply_gravity(delta):
	
	if not is_on_floor():
		velocity += get_gravity() * delta



func try_interact():
	if interactionList.is_empty():
		return
	
	
	if interactionList[-1] is Interactable:
		interactionList[-1].perform_interaction()






func _on_interaction_area_2d_area_entered(area: Area2D) -> void:
	
	var interactable = area.get_parent().get_parent()
	
	if interactable is Interactable:
		interactionList.append(interactable)


func _on_interaction_area_2d_area_exited(area: Area2D) -> void:
	var interactable = area.get_parent().get_parent()

	interactionList.erase(interactable)
