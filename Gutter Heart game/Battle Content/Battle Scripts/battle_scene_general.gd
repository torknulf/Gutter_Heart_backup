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


## COMPLIMENT
enum Appeals {COMPLIMENT, CRITICIZE, RELATE, OPPOSE}


var enemy_data : Dictionary




func load_enemy(path):
	var loader = EnemyDataLoader.new()
	enemy_data = loader.load_enemy(path)


func _ready() -> void:
	turnState = TurnStates.PLAYERTURN
	%BeatManager.start_counting_beat()
	
	%InsultSpawner.enemyAttackEnded.connect(on_enemy_attack_ended)
	
	load_enemy("res://Battle Content/Combat Dialogue/shifting_rat.json")
	DialogueManager.display_text(get_current_prompt())
	DialogueManager.canAdvance = false
	
	
	

	
	



func _process(delta: float) -> void:
	
	# To continue to enemy turn after pressing away enemy response
	if Input.is_action_just_pressed("Interact"):
		if turnState == TurnStates.RESPONSE:
			if enemyCurrProg == enemyMaxProg and !DialogueManager.isTyping:
				DialogueManager.queueOverworld = true
			
			elif enemyCurrProg != enemyMaxProg and !DialogueManager.isTyping:
				turnState = TurnStates.ENEMYTURN
	
	
	# PROGRESS BAR
	%ProgFilling.size.x = 48 * enemyCurrProg
	




## --- TURN FUNCTIONS ---


func start_enemy_turn() -> void:
	print("ENEMY TURN")
	%InsultSpawner.initialize_attack()
	%TurnTransition.play("transition_to_enemyturn")



func start_player_turn() -> void:
	DialogueManager.display_text(get_current_prompt())
	%TurnTransition.play("transition_to_playerturn")
	%PlayerContainer.visible = true


## triggers when turnState has been changed!
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

func show_response(appeal):
	var state = get_current_state()
	turnState = TurnStates.RESPONSE
	
	if str(appeal) == state["correct_appeal"]:
		on_correct_appeal()
	
	else:
		on_wrong_appeal(appeal)
	


func on_correct_appeal():
	var state = get_current_state()
	DialogueManager.display_text(state["success_response"])
	
	enemyCurrProg += 1
	
	## Win condition check
	if enemyCurrProg >= enemy_data["states"].size():
		on_battle_won()


func on_wrong_appeal(appeal):
	var state = get_current_state()
	DialogueManager.display_text(state["wrong_response"][str(appeal)])


func on_battle_won():
	pass



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

func get_current_state() -> Dictionary:
	return enemy_data["states"][enemyCurrProg]

func get_current_prompt():
	var state = get_current_state()
	return state["prompt"]
