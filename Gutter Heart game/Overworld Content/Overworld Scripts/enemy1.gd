extends Interactable

var npc_data

func load_npc(path):
	var loader = EnemyDataLoader.new()
	npc_data = loader.load_enemy(path)


func _ready() -> void:
	load_npc("res://Overworld Content/Overworld Dialogue/TutorialGuyOverworld.json")
	DialogueManager.inDialogue.connect(start_battle)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is OverworldPLayer:
		DialogueManager.start_dialogue(npc_data.dialogue)


func start_battle(inDialogue):
	if inDialogue:
		return
	get_tree().change_scene_to_file("res://Battle Content/Battle Scenes/battle_scene_general.tscn")
	
