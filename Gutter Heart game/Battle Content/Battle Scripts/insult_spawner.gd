class_name InsultSpawner extends Node2D

@export var insultRef: PackedScene

var spawnRounds: int = 0

var isSpawning: bool = false

#var spawnDirs = ["UP", "DOWN", "LEFT", "RIGHT"]

var spawnQueue = []


signal enemyAttackEnded

func _ready() -> void:
	randomize()
	%BeatManager.newBeat.connect(spawn_first_in_queue)
	%BeatManager.newBar.connect(_on_signal_new_bar)
	

func _process(delta: float) -> void:
	pass
	
	





func spawn_first_in_queue():
	if !isSpawning or spawnQueue == []:
		return
	
	
	if spawnQueue[0] == 1:
		spawn_insult()
	spawnQueue.remove_at(0)
	
	



func choose_insult_dir():
	if !isSpawning:
		return
	
	var dir 
	var randInt = randi() % 4  # radnom int between 0 and 3
	
	match randInt:
		0:
			dir = Vector2.RIGHT
		1:
			dir = Vector2.LEFT
		2:
			dir = Vector2.UP
		3:
			dir = Vector2.DOWN
	
	return dir



func generate_insult_queue():
	randomize()
	
	var insultQueue = []
	insultQueue.resize(%BeatManager.currSong.beatsPerMeasure)
	var insultAmount = randi_range(2, %BeatManager.currSong.beatsPerMeasure) # should be length of list
	
	for i in insultAmount:
		insultQueue[i] = 1
	
	insultQueue.shuffle()
	
	return insultQueue






func spawn_insult():
	var dir = choose_insult_dir()
	
	var insultInstance: Insult = insultRef.instantiate()
	
	# these two magic numbers are just eyed distances
	insultInstance.startPos = 250 * dir
	insultInstance.hitPos = 80 * dir
	insultInstance.approachDir = dir
	insultInstance.beatManagerRef = %BeatManager
	insultInstance.playerDefendingRef = %PlayerDefending
	
	get_parent().add_child(insultInstance)
	



# happens whenever a new bar occurs. Mainly toggles on/off spawning between rhythm game attacking/defending rounds
func _on_signal_new_bar(barStart: bool):
	if $"../..".turnState != $"../..".TurnStates.ENEMYTURN:
		return
	#print("BEAT", isSpawning)
	
	if !barStart and !isSpawning:
		return # to avoid start of attack mid-bar
	
	
	if isSpawning:
		isSpawning = false
	
	elif !isSpawning:
		spawnRounds -= 1
		
		if spawnRounds > 0:
			isSpawning = true
			spawnQueue = generate_insult_queue()
			#print(spawnQueue)

		else:
			isSpawning = false 
			enemyAttackEnded.emit()
			## END TURN
	
	
func initialize_attack():
	isSpawning = true
	spawnRounds = 5
