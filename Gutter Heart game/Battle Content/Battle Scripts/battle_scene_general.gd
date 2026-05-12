class_name BattleScene extends Node

var playerHP: int = 10 ## unused atm
var playerMaxHP: int = 10

var enemyMaxProg: int = 3
var enemyCurrProg: int = 0 # if currprog reaches maxprog, battle is won!


enum TurnStates {PLAYERTURN, RESPONSE, ENEMYTURN}
var turnState:
	set(state):
		var prevState = turnState
		turnState = state  
		_on_turn_state_changed(prevState) 

enum Appeals {COMPLIMENT, CRITICIZE, RELATE, OPPOSE}


func _ready() -> void:
	turnState = TurnStates.PLAYERTURN
	%BeatManager.start_counting_beat()
	
	%InsultSpawner.enemyAttackEnded.connect(on_enemy_attack_ended)



func _process(delta: float) -> void:
	
	# To continue to enemy turn after pressing away enemy response
	if Input.is_action_just_pressed("Left_click"):
		if turnState == TurnStates.RESPONSE:
			turnState = TurnStates.ENEMYTURN
	
	
	# PROGRESS BAR
	%ProgFilling.size.x = 48 * enemyCurrProg
	




## --- TURN FUNCTIONS ---


func start_enemy_turn() -> void:
	print("ENEMY TURN")
	%InsultSpawner.initialize_attack()
	%TurnTransition.play("transition_to_enemyturn")



func start_player_turn() -> void:
	update_text()
	%TurnTransition.play("transition_to_playerturn")
	%PlayerContainer.visible = true


## triggers when the state has been changed!
func _on_turn_state_changed(prevState) -> void: 
	if !prevState or prevState == turnState:
		return
	
	match turnState:
		TurnStates.PLAYERTURN:
			start_player_turn()

		TurnStates.RESPONSE:
			%PlayerContainer.visible = false

		TurnStates.ENEMYTURN:
			start_enemy_turn()


## triggers after the last round of insults 
func on_enemy_attack_ended() -> void:
	turnState = TurnStates.PLAYERTURN
	



## --- PLAYER INPUT ---


func select_appeal(appeal):
	if turnState != TurnStates.PLAYERTURN:
		return
	
	show_response(appeal)

	turnState = TurnStates.RESPONSE




## --- TEXT UPDATES & PROGRESS LOGIC ---


func show_response(appeal): # this one needs major rework, I wanna make it CLEAN
	if enemyCurrProg == 0 and appeal == Appeals.COMPLIMENT:
		enemyCurrProg += 1
		%CombatText.text = str(appeal) + " is right!"
	
	elif enemyCurrProg == 1 and appeal == Appeals.CRITICIZE:
		enemyCurrProg += 1
		%CombatText.text = str(appeal) + " is right!"
	
	elif enemyCurrProg == 2 and appeal == Appeals.OPPOSE:
		enemyCurrProg += 1
		%CombatText.text = str(appeal) + " is right!"
	
	
	# here the wrong answer is picked
	else:
		%CombatText.text = str(appeal) + " is wrong"

	if enemyCurrProg == enemyMaxProg:
		%CombatText.text = "COMBAT WON"



func update_text():
	if enemyCurrProg == enemyMaxProg:
		%CombatText.text = "COMBAT WON"
	elif enemyCurrProg == 0:
		%CombatText.text = "First round \nCompliment"
	elif enemyCurrProg == 1:
		%CombatText.text = "Second round \nCriticize"
	elif enemyCurrProg == 2:
		%CombatText.text = "Third round \n Oppose"



## --- BUTTONS & TIMERS ---





func _on_compliment_button_pressed() -> void:
	select_appeal(Appeals.COMPLIMENT)

func _on_criticize_button_pressed() -> void:
	select_appeal(Appeals.CRITICIZE)

func _on_relate_button_pressed() -> void:
	select_appeal(Appeals.RELATE)

func _on_oppose_button_pressed() -> void:
	select_appeal(Appeals.OPPOSE)



## --- GETTERS ---

func get_turnstate():
	return turnState
