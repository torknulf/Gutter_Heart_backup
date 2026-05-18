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
	
	load_enemy("res://Battle Content/Combat Dialogue/TutorialGuyCombat.json")
	DialogueManager.display_text(get_current_prompt())
	DialogueManager.canAdvance = false
	
	update_player_alternatives()
	
	
	
	DialogueManager.nameLabel.visible = false

	
	%MetronomeSFX.volume_db = -80
	%MetronomeSFXFirst.volume_db = -80



func _process(delta: float) -> void:
	
	# To continue to enemy turn after pressing away enemy response
	if Input.is_action_just_pressed("Interact"):
		if turnState == TurnStates.RESPONSE:
			if enemyCurrProg == enemyMaxProg and !DialogueManager.isTyping:
				#DialogueManager.queueOverworld = true
				GameState.npcStates["tutorial_guy"]["fought"] = true
				DialogueManager.nameLabel.visible = true
				get_tree().change_scene_to_file("res://Overworld Content/Overworld Scenes/Overworld Stages/overworld.tscn")
				
				DialogueManager._ready()
			
			elif enemyCurrProg != enemyMaxProg and !DialogueManager.isTyping:
				turnState = TurnStates.ENEMYTURN
	
	elif Input.is_action_just_pressed("ToggleMute"):
		if %MetronomeSFX.volume_db != 0:
			%MetronomeSFX.volume_db = 0
			%MetronomeSFXFirst.volume_db = 0
		else:
			%MetronomeSFX.volume_db = -80
			%MetronomeSFXFirst.volume_db = -80

	# PROGRESS BAR
	%ProgFilling.size.x = 48 * enemyCurrProg
	




## --- TURN FUNCTIONS ---


func start_enemy_turn() -> void:
	#print("ENEMY TURN")
	%InsultSpawner.initialize_attack()
	%TurnTransition.play("transition_to_enemyturn")



func start_player_turn() -> void:
	
	update_player_alternatives()
	
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
	if enemyCurrProg >= enemy_data["combat_states"].size():
		on_battle_won()


func on_wrong_appeal(appeal):
	var state = get_current_state()
	DialogueManager.display_text(state["wrong_response"][str(appeal)])


func on_battle_won():
	pass



func update_player_alternatives():
	var state = get_current_state()
	var alts = ["Compliment", "Criticize", "Relate", "Oppose"]

	## Add alternative appeals as player alternatives if they are specified
	if "alt_appeals" in state.keys():
		alts = []
		for i in state["alt_appeals"]:
			alts.append(state["alt_appeals"][i])
	
	var index = 0
	for button : Button in %PlayerAlternatives.get_children():
		button.text = alts[index]
		index += 1




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
	return enemy_data["combat_states"][enemyCurrProg]


func get_current_prompt():
	var state = get_current_state()
	return state["prompt"]
