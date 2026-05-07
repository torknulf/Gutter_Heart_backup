class_name InsultSpawner extends Node2D

@export var insultRef: PackedScene

#var spawnDirs = ["UP", "DOWN", "LEFT", "RIGHT"]

var spawnQueue = []

@export var spawnsAutomatically : bool = false


func _ready() -> void:
	randomize()
	%BeatManager.newBeat.connect(spawn_from_queue)
	%BeatManager.newBeat.connect(generate_insults)
	

func _process(delta: float) -> void:
	
	
	if Input.is_action_just_pressed("spawn_insult_right"):
		if Vector2.RIGHT not in spawnQueue:
			spawnQueue.append(Vector2.RIGHT)
	elif Input.is_action_just_pressed("spawn_insult_left"):
		if Vector2.LEFT not in spawnQueue:
			spawnQueue.append(Vector2.LEFT)
	elif Input.is_action_just_pressed("spawn_insult_up"):
		if Vector2.UP not in spawnQueue:
			spawnQueue.append(Vector2.UP)
	elif Input.is_action_just_pressed("spawn_insult_down"):
		if Vector2.DOWN not in spawnQueue:
			spawnQueue.append(Vector2.DOWN)
	
	





func spawn_from_queue():
	for dir in spawnQueue:
		spawn_insult(dir)
	spawnQueue = []
	
	



func generate_insults():
	if !spawnsAutomatically:
		return
	
	var randInt = randi() % 15 # radnom int between 0 and 14
	
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
	



func set_spawn_toggle(isSpawning: bool):
	spawnsAutomatically = isSpawning
