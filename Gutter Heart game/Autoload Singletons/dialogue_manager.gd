extends Node

var textLabel: Label
var nameLabel: RichTextLabel

var fullText = ""
var currIndex = 0 # shows one letter at a time

var isTyping = false

var lineIndex = 0 # for overworld dialogue mostly? which line nr to read


signal inDialogue

var queuedTimeline = null

var currentNPC
var currTimelineName


var queueBattle: bool
var queueOverworld: bool

var canAdvance: bool = true

func _ready() -> void:
	textLabel = get_tree().get_first_node_in_group("TextLabel")
	nameLabel = get_tree().get_first_node_in_group("NameLabel")
	






## to go through an enitre dialogue sequence
func start_dialogue(npcData, timelineName):
	currentNPC =  npcData
	currTimelineName = timelineName
	
	lineIndex = 0
	process_text_type(currentNPC["timelines"][currTimelineName][lineIndex])
	
	inDialogue.emit(true) 
	textLabel.get_parent().get_parent().get_parent().visible = true


## mostly for overworld dialogue
func process_text_type(timeline : Dictionary):
	_ready()
	
	if "text" in timeline.keys():
		pass #print("text")
	
	if "choices" in timeline.keys():
		show_choices(timeline["choices"])
		canAdvance = false
	
	if "start_battle" in timeline.keys():
		pass
	
	if "next_timeline" in timeline.keys():
		queuedTimeline = timeline["next_timeline"]

	
	if "name" in timeline.keys(): # this is the line-specific name
		DialogueManager.nameLabel.text = timeline["name"]
	
	elif "name" in currentNPC.keys(): # this is the general name
		DialogueManager.nameLabel.text = currentNPC["name"]


	display_text(timeline["text"])


## to show only 1 text screen
func display_text(text : String):
	_ready() # JUST TEMPORARY FOR SCENE SWITCH TO WORK
	
	

	fullText = text
	textLabel.text = fullText
	textLabel.visible_characters = 0

	currIndex = 0
	isTyping = true

	start_typing()



func start_typing():
	while currIndex < fullText.length() and isTyping:
		currIndex += 1
		textLabel.visible_characters = currIndex
		await get_tree().create_timer(0.03).timeout
	
	textLabel.visible_characters = fullText.length()
	isTyping = false


func skip_text():
	if isTyping:
		
		textLabel.visible_characters = fullText.length()
		
		isTyping = false



func _unhandled_key_input(event: InputEvent) -> void:
	
	textLabel = get_tree().get_first_node_in_group("TextLabel")
	
	if textLabel.get_parent().get_parent().get_parent().visible == false:
		return # here the textbox is invisible, so no dialogue is there
	
	
	if event.is_action_pressed("Interact") and canAdvance: ## AND IF IN DIALOGUE
		advance_dialogue()



func next_line():
	lineIndex += 1

	if lineIndex >= currentNPC["timelines"][currTimelineName].size():
		
		if queuedTimeline != null:
			start_dialogue(currentNPC, queuedTimeline)
			queuedTimeline = null
		else:
			end_dialogue()

	else:
		process_text_type(currentNPC["timelines"][currTimelineName][lineIndex])


func advance_dialogue():
	if isTyping:
		finish_current_line()

	else: # typing is finished
		next_line()
	
	
func finish_current_line():
	isTyping = false
	textLabel.visible_characters = fullText.length()
	
	
	
func end_dialogue():
	if queuedTimeline != null:
		return
	
	elif queueBattle:
		queueBattle = false
		textLabel.get_parent().get_parent().get_parent().visible = true
		get_tree().change_scene_to_file("res://Battle Content/Battle Scenes/battle_scene_general.tscn")
	
	elif queueOverworld:
		queueOverworld = false
		get_tree().change_scene_to_file("res://Overworld Content/Overworld Scenes/Overworld Stages/overworld.tscn")
		
	
	inDialogue.emit(false) 
	textLabel.get_parent().get_parent().get_parent().visible = false
	



func show_choices(choices):  # argument should be a list of choices 
	var choiceContainer = get_tree().get_first_node_in_group("ChoiceContainer")
	choiceContainer.visible = true
   
	for child in choiceContainer.get_children():
		child.queue_free()

	for choice_data in choices:
		var button = Button.new()

		button.text = choice_data["text"]
		button.add_theme_font_size_override("font_size", 64) 

		button.pressed.connect(
			func():
				choiceContainer.visible = false
				on_choice_selected(choice_data)
		)

		choiceContainer.add_child(button)


func on_choice_selected(choice_data):
	if "effect" in choice_data.keys():
		handle_effect(choice_data["effect"])
	
	if "next_timeline" in choice_data.keys():
		queuedTimeline = choice_data["next_timeline"]
	
	advance_dialogue()
	canAdvance = true
	
	
func handle_effect(effect):
	if effect == "combat":
		queueBattle = true



func update_appeal_text(altAppeals):
	if altAppeals == null:
		#display standard appeals
		return 
	
	for i in len(altAppeals):
		pass
		
		
		
