extends Interactable

var npc_data


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_npc("res://Overworld Content/Overworld Dialogue/TutorialGuyOverworld.json")
	#DialogueManager.inDialogue.connect(start_battle)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_npc(path):
	var loader = EnemyDataLoader.new()
	npc_data = loader.load_enemy(path)
	
	
	
	
	
func perform_interaction():
	var currentTimeline = choose_timeline()
	if !currentTimeline: # failsafe in case the key is incorrect
		return
	
	DialogueManager.start_dialogue(npc_data, currentTimeline)
	GameState.npcStates["tutorial_guy"]["talk_count"] += 1



## Logic for which dialogue timeline is chosen
func choose_timeline():
	
	if !GameState.npcStates["tutorial_guy"]["fought"]:
		if GameState.npcStates["tutorial_guy"]["talk_count"] < 1:
			
			return "first"
			
		else:
			return "repeat"
			
			
	else:
		return "after_battle"
