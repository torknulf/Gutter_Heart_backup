class_name BattleScene extends RunnableScene

var playerHP: int = 10 ## unused atm
var playerMaxHP: int = 10

var enemyMaxProg: int = 3 
var enemyCurrProg: int = 0 # if currprog reaches maxprog, battle is won!


enum TurnStates {PREPROMPT, PLAYERTURN, OBSERVATION, RESPONSE, ENEMYTURN}
var turnState:
	set(state):
		var prevState = turnState
		turnState = state  
		_on_turn_state_changed(prevState) 


## COMPLIMENT
enum Appeals {COMPLIMENT, CRITICIZE, RELATE, OPPOSE}


var enemy_data : Dictionary


var wasLastWrong: bool = false
var doneReadingArray: bool = false


func load_enemy(path):
	var loader = EnemyDataLoader.new()
	enemy_data = loader.load_enemy(path)


func _ready() -> void:
	super._ready()
	if not is_inside_game():
		return
	print("PARENT: ", get_parent())
	
	GameState.inCombat = true
	DialogueManager._ready()
	if DialogueManager.nameLabel != null:
		DialogueManager.nameLabel.visible = false
	%BeatManager.start_counting_beat()
	%InsultSpawner.enemyAttackEnded.connect(on_enemy_attack_ended)
	load_enemy("res://Battle Content/Combat Dialogue/TutorialGuyCombat.json")
	enemyMaxProg = enemy_data["combat_states"].size()
	%MetronomeSFX.volume_db = -80
	%MetronomeSFXFirst.volume_db = -80
	%PlayerAlternatives.visible = false
	%TextBubble.visible = true

	var gameScene = get_tree().get_first_node_in_group("GameScene")
	#await gameScene.hasFadedOut
	
	turnState = TurnStates.PREPROMPT
	
	start_player_turn()

	update_player_alternatives()
	
	%PlayerDefending.updateHP.connect(update_player_hp)


	




func _process(delta: float) -> void:
	#print(turnState)
	# To continue to enemy turn after pressing away enemy response
	if Input.is_action_just_pressed("Interact"):
		if turnState == TurnStates.OBSERVATION:
			if !DialogueManager.isTyping:
				print("back to playerturn")
				turnState = TurnStates.PLAYERTURN
		
	elif Input.is_action_just_pressed("ToggleMute"):
		if %MetronomeSFX.volume_db != 0:
			%MetronomeSFX.volume_db = 0
			%MetronomeSFXFirst.volume_db = 0
		else:
			%MetronomeSFX.volume_db = -80
			%MetronomeSFXFirst.volume_db = -80

	# PROGRESS BAR (144 is the width of the container)
	%ProgFilling.size.x = (144 / enemyMaxProg) * enemyCurrProg 
	




## --- TURN FUNCTIONS ---


func start_enemy_turn() -> void:
	#print("ENEMY TURN")
	%InsultSpawner.initialize_attack()
	%TurnTransition.play("spotlight_transition_to_enemyturn")



func start_player_turn() -> void:
	
	update_player_alternatives()
	
	if %PlayerTurn.visible == false:
		%TurnTransition.play("spotlight_transition_to_playerturn")
		await %TurnTransition.animation_finished
		%TextBubble.visible = true
		
	
	var state = get_current_state() 
	if "pre_prompt" in state.keys() and turnState == TurnStates.PREPROMPT and !wasLastWrong:
		read_through_text_array(guarantee_array(state["pre_prompt"]))
		%PlayerAlternatives.visible = false
		%ObserveButton.disabled = true
	
	else:
		turnState = TurnStates.PLAYERTURN
		print("Start await")
		await DialogueManager.doneWriting
		print("Done await")
		%PlayerAlternatives.visible = true
		%ObserveButton.disabled = false



## triggers when turnState has been changed!
func _on_turn_state_changed(prevState) -> void: 
	print(turnState, prevState)
	
	if prevState == null or prevState == turnState:
		return


	
	match turnState:
		TurnStates.PREPROMPT:
			start_player_turn()
			print("HIDE APPEALS ", prevState)
				
			
		TurnStates.PLAYERTURN:
			if prevState != TurnStates.OBSERVATION:
				DialogueManager.display_text(get_current_prompt())
			
			else:
				%PlayerAlternatives.visible = true
			
			if %PlayerAlternatives.visible == false:
				print("Start 2nd await")
				await DialogueManager.doneWriting
				
			print("MAKE APPEALS VISIBLE")
			%PlayerAlternatives.visible = true
			%ObserveButton.disabled = false
			%ObservationTextLabel.visible = false

		TurnStates.OBSERVATION:
			%PlayerAlternatives.visible = false
			%ObserveButton.disabled = true
			%ObservationTextLabel.visible = true
			var state = get_current_state()
			DialogueManager.display_observation_text(state, enemy_data)

		TurnStates.RESPONSE:
			pass
			%PlayerAlternatives.visible = false
			%ObserveButton.disabled = true

		TurnStates.ENEMYTURN:
			start_enemy_turn()
			%TextBubble.visible = false


## triggers after the last round of insults 
func on_enemy_attack_ended() -> void:
	turnState = TurnStates.PREPROMPT
	



## --- PLAYER INPUT ---


func select_appeal(appeal):
	if turnState != TurnStates.PLAYERTURN:
		return
	
	DialogueManager.playChoiceSFX.emit()
	
	show_response(appeal)
	


## --- TEXT UPDATES & PROGRESS LOGIC ---

func read_through_text_array(array: Array):
	
	print(turnState, " READ ARRAY")

	
	for line in array:
		text_bubble_randpos()
		DialogueManager.display_text(line)
		#if array.size() <= 1: 
		#	break
		await DialogueManager.advancePressed
		DialogueManager.playNextTextSFX.emit()
		
	
	
	
	## Win condition check
	if enemyCurrProg >= enemy_data["combat_states"].size() and turnState == TurnStates.RESPONSE:
		on_battle_won()
	


	# for pre_prompt
	if turnState == TurnStates.PREPROMPT:
		turnState = TurnStates.PLAYERTURN
		
	# for after an answer
	elif turnState == TurnStates.RESPONSE:
		turnState = TurnStates.ENEMYTURN
	

func show_response(appeal):
	var state = get_current_state()
	turnState = TurnStates.RESPONSE
	
	if str(appeal) == state["correct_appeal"]:
		on_correct_appeal()
	
	else:
		on_wrong_appeal(appeal)
	


func on_correct_appeal():
	var state = get_current_state()
	wasLastWrong = false
	
	read_through_text_array(guarantee_array(state["success_response"]))
	
	enemyCurrProg += 1
	



func on_wrong_appeal(appeal):
	var state = get_current_state()
	wasLastWrong = true
	
	read_through_text_array(guarantee_array(state["wrong_response"][str(appeal)]))




func on_battle_won():
	if enemyCurrProg == enemyMaxProg:
		#DialogueManager.queueOverworld = true
		GameState.npcStates["tutorial_guy"]["fought"] = true
		if DialogueManager.nameLabel:
			DialogueManager.nameLabel.visible = true
		SceneManager.load_scene("res://Overworld Content/Overworld Scenes/Overworld Stages/overworld.tscn")
		
		DialogueManager._ready()



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



func _on_observe_button_pressed() -> void:
	if turnState == TurnStates.PLAYERTURN and !DialogueManager.isTyping:
		turnState = TurnStates.OBSERVATION



## --- GETTERS ---

func get_turnstate():
	return turnState


func get_current_state() -> Dictionary:
	return enemy_data["combat_states"][enemyCurrProg]


func get_current_prompt():
	#DialogueManager.canAdvance = false
	
	print("GET CURRENT PROMPT")
	
	var state = get_current_state()
	if wasLastWrong and "prompt_repeat" in state.keys():
		return state["prompt_repeat"]
	
	return state["prompt"]



## --- FUNCTIONALITY ---

func guarantee_array(text):
	if text is Array:
		return text
	return [text]


## returns randomly selected predetermined position for textbubble
## SHOULD ALSO FLIP THE TAIL DEPENDING ON SIDE
func text_bubble_randpos(): 
	randomize()
	
	if %TextBubble == null:
		return
	## Add DialogueManager.get_bubble_pos() for JSON key to define pos
	var positions: Array = [
		Vector2(1377, 109), Vector2(1450, 269), Vector2(1422, 438), # Right side
		Vector2(316, 106), Vector2(434, 247), Vector2(366, 360) # Left side
		]
	
	var index = randi_range(0, positions.size()-1)
	%TextBubble.position = positions[index]
	
	
	
func play_spotlight_SFX(turnOn: bool = false):
	if turnOn:
		%SpotlightSFX.pitch_scale = 0.6
	else:
		%SpotlightSFX.pitch_scale = 0.7
	
	%SpotlightSFX.play()



func update_player_hp(newHP):
	%HPLabel.text = "HP = " + str(newHP) + "/5"
