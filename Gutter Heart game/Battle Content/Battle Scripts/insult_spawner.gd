class_name InsultSpawner extends Node2D

@export var insultRef: PackedScene

var spawnRounds: int = 0

var isSpawning: bool = false

#var spawnDirs = ["UP", "DOWN", "LEFT", "RIGHT"]

var spawnQueue = []


signal enemyAttackEnded

func _ready() -> void:
	randomize()
	%BeatManager.newBeat.connect(spawn_from_queue)
	%BeatManager.newBeat.connect(generate_insults)
	%BeatManager.newBar.connect(_on_signal_new_bar)
	

func _process(delta: float) -> void:
	pass
	
	





func spawn_from_queue():
	if !isSpawning:
		return
	
	
	for dir in spawnQueue:
		spawn_insult(dir)
	spawnQueue = []
	
	



func generate_insults():
	if !isSpawning:
		return
	
	var randInt = randi() % 10  # radnom int between 0 and 9
	
	if randInt in [0, 1]:
		spawnQueue.append(Vector2.RIGHT)
	elif randInt in [2, 3]:
		spawnQueue.append(Vector2.LEFT)
	elif randInt in [4, 5]:
		spawnQueue.append(Vector2.UP)
	elif randInt in [6, 7]:
		spawnQueue.append(Vector2.DOWN)
	
	# else: return




func spawn_insult(dir):
	var insultInstance: Insult = insultRef.instantiate()
	
	# these two magic numbers are just eyed distances
	insultInstance.startPos = 250 * dir
	insultInstance.hitPos = 80 * dir
	insultInstance.approachDir = dir
	insultInstance.beatManagerRef = %BeatManager
	insultInstance.playerDefendingRef = %PlayerDefending
	
	get_parent().add_child(insultInstance)
	








# happens whenever a new bar occurs. Mainly toggles on/off spawning between rhythm game attacking/defending rounds
func _on_signal_new_bar():
	if $"../..".turnState != $"../..".TurnStates.ENEMYTURN:
		return
	
	
	if isSpawning:
		isSpawning = false
	
	elif !isSpawning:
		spawnRounds -= 1
		
		if spawnRounds > 0:
			isSpawning = true
		else:
			isSpawning = false 
			enemyAttackEnded.emit()
			## END TURN
	
	
func initialize_attack():
	isSpawning = true
	spawnRounds = 5
