class_name RunnableScene extends Node


func _ready():
	if not is_inside_game():
		call_deferred("bootstrap_into_game")



# Returns true if the scene is in a properly running game
func is_inside_game(): 
	return get_tree().get_first_node_in_group("GameScene") != null 


# For testing, so that this becomes the child of GameScene
func bootstrap_into_game(): 
	var gameScene = load("res://General Scenes/GameScene.tscn").instantiate()
	
	get_tree().root.add_child(gameScene)
	
	
	var currentSceneNode = gameScene.get_node("ViewportContainer/Viewport/current_scene")
	
	# place node as child of current_scene
	for child in currentSceneNode.get_children():
		child.queue_free() # to delete whatever is there to start with
	

	get_parent().call_deferred("remove_child", self)
	currentSceneNode.call_deferred("add_child", self)
	self._ready()
