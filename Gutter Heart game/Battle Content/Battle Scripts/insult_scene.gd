class_name Insult extends Node2D

@export var spawnSFXAudio: Array[AudioStream]

var spawnTime # the time when the insult spawns
var hitTime # the time when the insult hits the player


var startPos 
var hitPos

var approachDir # gets direction in InsultSpawner script

var beatAmount : int = 4
var currBeat:= 0

var beatManagerRef : BeatManager # number of beats until the Insult hits
var playerDefendingRef : PlayerDefending

var isAddedToPlayer = false

var perfTiming: bool = false


func _ready() -> void:
	
	spawnTime = beatManagerRef.get_song_time()
	hitTime = spawnTime + (beatManagerRef.get_bps() * beatAmount) 
	
	global_position = startPos

	#beatManagerRef.newBeat.connect(play_approach_SFX)
	play_approach_SFX()
	

	


func _physics_process(delta: float) -> void:
	var currentTime = beatManagerRef.get_song_time()
	
	
	var travelTime = hitTime - spawnTime
	var progress = (currentTime - spawnTime) / travelTime
	progress = clamp(progress, 0.0, 1.1)
	
	global_position = startPos.lerp(hitPos, progress)
	#global_position = global_position.move_toward(hitPos, progress)
	#global_position *= 1.1/progress 
	#global_position = clamp(global_position, startPos, hitPos)
	

	
	
	
	
	%TimingLabel.text = str(progress).pad_decimals(2)
	

	if progress >= 1.1:
		playerDefendingRef.take_damage(self)

#perfect timing logic
	elif progress >= 1.05:
		perfTiming = false
	elif progress >= 0.90:
		perfTiming = true

	elif progress >= 0.7 and !isAddedToPlayer:
		playerDefendingRef.add_hittable_insult(self) ## HERE CAN BE DESTROYED by player
		isAddedToPlayer = true 
	
	
func play_approach_SFX():
	
	if currBeat >= beatAmount:
		return
	
	%SpawnSFX.volume_db = 0
	%SpawnSFX.stream = select_spawn_SFX()
	%SpawnSFX.play()

	currBeat += 1


func select_spawn_SFX():
	var sfxIndex: int = 0
	
	match approachDir:
		Vector2.DOWN: sfxIndex = 0
		
		Vector2.LEFT: sfxIndex = 1
		
		Vector2.RIGHT: sfxIndex = 2
		
		Vector2.UP: sfxIndex = 3

	return spawnSFXAudio[sfxIndex]


## happens when an insult reaches a player
func damage_player(hp: int = 1):
	queue_free()
