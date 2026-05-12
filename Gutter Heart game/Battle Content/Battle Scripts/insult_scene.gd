class_name Insult extends Node2D


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


func _ready() -> void:
	
	spawnTime = beatManagerRef.get_song_time()
	hitTime = spawnTime + (beatManagerRef.get_bps() * beatAmount) 
	
	global_position = startPos

	#beatManagerRef.newBeat.connect(play_approach_SFX)
	play_approach_SFX()


func _process(delta: float) -> void:
	var currentTime = beatManagerRef.get_song_time()
	
	
	var travelTime = hitTime - spawnTime
	var progress = (currentTime - spawnTime) / travelTime
	progress = clamp(progress, 0.0, 1.1)
	
	global_position = startPos.lerp(hitPos, progress)
	%TimingLabel.text = str(progress).pad_decimals(2)
	

	if progress >= 1.1:
		playerDefendingRef.take_damage(self)

	elif progress >= 0.9 and !isAddedToPlayer:
		playerDefendingRef.add_hittable_insult(self) ## HERE CAN BE DESTROYED by player
		isAddedToPlayer = true 
	
	
func play_approach_SFX():
	
	if currBeat >= beatAmount:
		return
	%SpawnSFX.play()
	%SpawnSFX.pitch_scale -= 0.1
	currBeat += 1


## happens when an insult reaches a player
func damage_player(hp: int = 1):
	queue_free()
