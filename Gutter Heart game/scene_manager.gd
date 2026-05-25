extends Node

var gameScene: Node

var currSceneNode: Node2D

var sceneToLoad: String

var newSpawnPos : Vector2 = Vector2.ZERO

var currentlyTransitioning: bool = false


func load_scene(newScenePath: String, spawnPos: Vector2 = Vector2.ZERO):
	sceneToLoad = newScenePath
	
	newSpawnPos = spawnPos
	
	get_scene_refs()
	
	disable_input() # to freeze input everywhere
	
	gameScene.fade_out()



func get_scene_refs():
	gameScene = get_tree().get_first_node_in_group("GameScene")
	
	currSceneNode = gameScene.get_node("ViewportContainer/Viewport/current_scene")

	gameScene.hasFadedOut.connect(transition_scene)
	gameScene.hasFadedOut.connect(enable_input)




func transition_scene():
	var newSceneInstance = load(sceneToLoad).instantiate()
	
	clean_current_nodes()
	await get_tree().process_frame # to let nodes actually disappear completely


	if newSceneInstance is OverworldScene:
		#newSceneInstance.spawnPos = newSpawnPos
		currSceneNode.call_deferred("add_child", newSceneInstance)
		print("SceneManager: loading world") 
		
		
	elif newSceneInstance is BattleScene:
		currSceneNode.call_deferred("add_child", newSceneInstance)
		print("SceneManager: loading combat")

	gameScene.fade_in()



func clean_current_nodes():
	# clean playable scene nodes
	for child in currSceneNode.get_children():
		child.queue_free() 







func enable_input():
	currentlyTransitioning = false
	print("INPUT ENABLED")
	
func disable_input():
	currentlyTransitioning = true
	print("INPUT DISABLED")
	
func is_input_disabled() -> bool:
	return currentlyTransitioning
