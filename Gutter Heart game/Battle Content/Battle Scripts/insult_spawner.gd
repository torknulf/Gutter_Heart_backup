class_name InsultSpawner extends Node2D

@export var insultRef: PackedScene

@export var usePremadeInsultPatterns: bool = true

var spawnRounds: int = 0

var isSpawning: bool = false

var spawnQueue = []

var difficultyLevel = 0

signal enemyAttackEnded

var lastInsult = 0
var lastDir = Vector2.UP # just placeholder direction

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
		var repeatDir: bool
		if lastInsult == 1:
			repeatDir = true
		else:
			repeatDir = false
		
		spawn_insult(repeatDir)
	
	lastInsult = spawnQueue[0]
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
	
	
	lastDir = dir
	
	return dir



func generate_insult_queue():
	randomize()
	var insultQueue = []


	if usePremadeInsultPatterns:
		var patterns: Array
		match %BeatManager.currSong.beatsPerMeasure:
			3: patterns = [[1, 1, 1], [1, 0, 1], [1, 1, 0]]
			
			4: 
				patterns = [[1, 0, 1, 1, 1], [1, 0, 1, 0, 1], [1, 1, 1, 0, 1]]#, [1, 1, 0, 1], [1, 0, 1, 0], [1, 0, 1, 1]]
				if difficultyLevel >= 1:
					var hardPatterns = [[1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 0, 1, 0, 1, 1, 1], [1, 1, 1, 0, 1, 1, 1, 0, 1]]
					for pattern in hardPatterns:
						patterns.append(pattern)
			
			5: pass
			
			6: patterns = [[1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 0, 1], [1, 0, 1, 1, 1, 1, 1], [1, 0, 1, 0, 1, 1, 1]]
		
		var index = randi_range(0, patterns.size()-1)
		insultQueue = patterns[index]
		
		
		
	
	else:
		insultQueue.resize(%BeatManager.currSong.beatsPerMeasure)
		var insultAmount = randi_range(2, %BeatManager.currSong.beatsPerMeasure) # should be length of list
		
		for i in insultAmount:
			insultQueue[i] = 1

		insultQueue.shuffle()
	
	
	return insultQueue






func spawn_insult(repeatDir: bool = false):
	
	var dir
	
	if repeatDir:
		dir = lastDir
	else: 
		dir = choose_insult_dir()
	
	var insultInstance: Insult = insultRef.instantiate()
	
	var hitPos = 150
	var startPos = 450
	
	# these two magic numbers are just eyed distances
	insultInstance.startPos = startPos * dir
	insultInstance.hitPos = hitPos * dir
	insultInstance.approachDir = dir
	insultInstance.beatAmount = %BeatManager.currSong.beatsPerMeasure
	insultInstance.beatManagerRef = %BeatManager
	insultInstance.playerDefendingRef = %PlayerDefending
	
	
	
	get_parent().add_child(insultInstance)
	



# happens whenever a new bar occurs. Mainly toggles on/off spawning between rhythm game attacking/defending rounds
func _on_signal_new_bar(barStart: bool):
	if $"../..".turnState != $"../..".TurnStates.ENEMYTURN:
		return
	#print("BEAT", isSpawning)
	
	if !barStart and !isSpawning or spawnQueue != []:
		return # to avoid start of attack mid-bar
	
	
	if isSpawning:
		isSpawning = false
	
	elif !isSpawning:
		spawnRounds -= 1
		
		if spawnRounds > 0:
			isSpawning = true
			lastInsult = 0
			spawnQueue = generate_insult_queue()
			spawn_first_in_queue()

		else:
			isSpawning = false 
			spawnQueue = []
			enemyAttackEnded.emit()
			## END TURN
	
	
func initialize_attack():
	isSpawning = true
	spawnRounds = 5



func change_difficulty(diffLevel):
	difficultyLevel = int(diffLevel)
