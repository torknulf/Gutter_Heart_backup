class_name Insult extends Node2D

var spawnSFXAudio: Array # from songData, order is DOWN, LEFT, RIGHT, UP 
var spawnSFXVolume

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

# wobble
@export var wobbleSpeed: float = 10.0
@export var wobbleAmount: float = 5.0

var isBreaking: bool = false

func _ready() -> void:
	randomize()
	
	spawnTime = beatManagerRef.get_song_time()
	hitTime = spawnTime + (beatManagerRef.get_bps() * beatAmount) 
	
	
	startPos += Vector2(randf(), randf()) * 40
	global_position = startPos 

	%SpawnSFX.volume_db = spawnSFXVolume
	#beatManagerRef.newBeat.connect(play_approach_SFX)
	play_approach_SFX()
	

	
func _physics_process(delta: float) -> void:
	if isBreaking:
		return
	
	
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
		start_breaking()

#perfect timing logic
	elif progress >= 1.05:
		perfTiming = false
	elif progress >= 0.90:
		perfTiming = true

	elif progress >= 0.75   and !isAddedToPlayer:
		playerDefendingRef.add_hittable_insult(self) ## HERE CAN BE DESTROYED by player
		isAddedToPlayer = true 

	apply_wobble()


	
	
	
func play_approach_SFX():
	
	if currBeat >= beatAmount:
		return
	
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
func start_breaking(isHit: bool = false, combo: int = 0):
	isBreaking = true
	%AnimationPlayer.play("break")
	
	if isHit:
		
		print("COMBO: ", combo)
		if combo >= 1:
			
			var comboSpriteScaler: float = 0.3
			%Sprite2D.scale = Vector2(1 + comboSpriteScaler * combo, 1 + comboSpriteScaler * combo)
		
		play_combo_SFX(combo)


func play_combo_SFX(combo):
	var comboScaler: float = 0.1
	%HitBreakSFX.pitch_scale = 1 + comboScaler * combo
	%HitBreakSFX.play()
	
	# to make volume higher with higher combos
	if combo > 3 and perfTiming:
		%ComboNoiseSFX.volume_db = -15 - (8 / (combo - 3))
		%ComboNoiseSFX.pitch_scale = combo 
		%ComboNoiseSFX.play()
	
	


func apply_wobble():
	var timeVal = Time.get_ticks_msec() / 1000.0 * wobbleSpeed + randf() 
	var wobble = sin(timeVal) * wobbleAmount
	
	%Sprite2D.offset = Vector2(wobble, wobble)



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "spawn":
		
		#Randomize which insult the animation starts on 
		randomize()
		var spawnTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
		var index = randi_range(0, spawnTimes.size()-1)
		%AnimationPlayer.play("fly")
		%AnimationPlayer.seek(spawnTimes[index], true)
	
	if anim_name == "break":
		queue_free()
