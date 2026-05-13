extends Node

var textLabel: Label

var fullText = ""
var currIndex = 0 # shows one letter at a time

var isTyping = false

var lineIndex = 0 # for overworld dialogue mostly? which line nr to read

var currentDialogue

signal inDialogue

func _ready() -> void:
	textLabel = get_tree().get_first_node_in_group("TextLabel")
	






## to go through an enitre dialogue sequence
func start_dialogue(dialogue):
	currentDialogue = dialogue
	lineIndex = 0
	display_text(currentDialogue[lineIndex])
	inDialogue.emit(true) 
	textLabel.get_parent().get_parent().visible = true




## to show only 1 text screen
func display_text(text : String):
	
	textLabel = get_tree().get_first_node_in_group("TextLabel") # JUST TEMPORARY FOR SCENE SWITCH TO WORK

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
	if event.is_action_pressed("Interact"):
		advance_dialogue()



func next_line():
	lineIndex += 1

	if lineIndex >= currentDialogue.size():
		end_dialogue()

	else:
		display_text(currentDialogue[lineIndex])


func advance_dialogue():
	if isTyping:
		finish_current_line()

	else: # typing is finished
		next_line()
	
	
func finish_current_line():
	isTyping = false
	textLabel.visible_characters = fullText.length()
	
	
	
func end_dialogue():
	inDialogue.emit(false) 
	textLabel.get_parent().get_parent().visible = false
