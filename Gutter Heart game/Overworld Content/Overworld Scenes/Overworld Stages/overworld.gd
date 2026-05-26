class_name OverworldScene extends RunnableScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
	
	GameState.inCombat = false
	var textBox = get_tree().get_first_node_in_group("TextBox")
	textBox.visible = false
