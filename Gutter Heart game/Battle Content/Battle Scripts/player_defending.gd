class_name PlayerDefending extends Node2D

@export var perfectSFXAudio: Array[AudioStream]
@export var okSFXAudio: Array[AudioStream]

var hittableInsults = {Vector2.RIGHT: [], Vector2.LEFT: [], Vector2.UP: [], Vector2.DOWN: []}

# ok hits fill 5, perfect hits fill 15, damage takes 50 off
var resolve: int = 0
var maxResolve: int = 100

var maxHP: int = 5
var hp: int = 5

signal updateHP
signal updateResolve
signal hasDied

signal comboShake # for screen shake

var isInvincible: bool = false


var currCombo: int = 0

func _ready() -> void:
	hp = maxHP


func _physics_process(delta: float) -> void:
	%ResolveLabel.text = "Resolve: " + str(resolve) + "/100"
	
	
	
	if %HitzoneVisibilityTimer.time_left != 0:
		return
		
	

	# add cooldown timer check, in case you have missed a hit
	if Input.is_action_just_pressed("input_right"):
		try_hit(Vector2.RIGHT)
		%PlayerSprite.rotation = deg_to_rad(-90)
	elif Input.is_action_just_pressed("input_left"):
		try_hit(Vector2.LEFT)
		%PlayerSprite.rotation = deg_to_rad(90)
	elif Input.is_action_just_pressed("input_up"):
		try_hit(Vector2.UP)
		%PlayerSprite.rotation = deg_to_rad(180)
	elif Input.is_action_just_pressed("input_down"):
		try_hit(Vector2.DOWN)
		%PlayerSprite.rotation = deg_to_rad(0)




func try_hit(hitDir: Vector2):
	%PlayerAnimation.stop()
	%PlayerAnimation.play("Wrench_Swing")

	if %EnemyTurn.visible == false:
		return
	
	%Hitzone.visible = true
	%WrenchSwingSFX.play()
	%HitzoneVisibilityTimer.start()
	
	if hittableInsults[hitDir] != []:
		var insult = hittableInsults[hitDir][0]
		update_combo(insult.perfTiming)
		update_resolve(insult.perfTiming)
		remove_hittable_insult(insult, true, currCombo)
		%InsultHitSFX.stream = select_hit_SFX(insult)
		%InsultHitSFX.play()
		


func take_damage(insult: Insult):
	if isInvincible:
		%PlayerIFrameHurtSFX.play()
		remove_hittable_insult(insult)
		return
	
	
	var lostHP = 1

	lose_hp(lostHP)
	remove_hittable_insult(insult)
	%PlayerHurtSFX.play()
	
	if resolve == maxResolve:
		update_resolve(0)

	

	
	


func add_hittable_insult(insult: Insult):
	hittableInsults[insult.approachDir].append(insult)



func remove_hittable_insult(insult: Insult, isHit: bool = false, combo: int = 0):
	hittableInsults[insult.approachDir].remove_at(0) # should always be the oldest object that gets removed?
	insult.start_breaking(isHit, combo)
	
	if isHit:
		play_combo_SFX(combo)
	
	


func _on_hitzone_visibility_timer_timeout() -> void:
	%Hitzone.visible = false



func update_combo(isHitPerfect):
	var shakeFactor = currCombo
	
	if isHitPerfect:
		if currCombo < 10:
			currCombo += 1
		
	
	else:
		if currCombo - 5 < 0:
			currCombo = 0
		else:
			currCombo -= 5
		shakeFactor *= 0.8


	if currCombo < 3: # weak
		shakeFactor = 2
	elif currCombo < 6: # medium
		shakeFactor = 2.6
	else: # strong
		shakeFactor = 3.5
	
	comboShake.emit(shakeFactor)
	print("SHAKE: ", shakeFactor)


func update_resolve(isHitPerfect):
	var amount
	if isHitPerfect:
		amount = 2 * currCombo

	else:
		amount = 2
	
	if resolve + amount >= maxResolve:
		if hp == maxHP:
			resolve = maxResolve
			updateResolve.emit(resolve)
			return
		resolve = 0
		updateResolve.emit(resolve)
		gain_hp()
		return
	
	resolve += amount
	
	updateResolve.emit(resolve)



func lose_hp(amount: int = 1):
	if isInvincible:
		return
	
	if hp - amount <= 0:
		hp = 0
		hasDied.emit()
	elif amount == 0: # hit with max resolve
		isInvincible = true
		%HurtAnimation.play("Player_Hurt")
		%PlayerIFrameHurtSFX.play()
	else:
		hp -= amount
	
	currCombo = 0
	comboShake.emit(4)
	updateHP.emit(hp)
	isInvincible = true
	%HurtAnimation.play("Player_Hurt")


func gain_hp(amount: int = 1):
	if hp + amount >= maxHP:
		hp = maxHP
	else:
		hp += 1
	%HealSFX.play()
	updateHP.emit(hp)







func select_hit_SFX(insult: Insult):
	var sfxIndex: int = 0
	
	match insult.approachDir:
		Vector2.DOWN: sfxIndex = 0
		
		Vector2.LEFT: sfxIndex = 1
		
		Vector2.RIGHT: sfxIndex = 2
		
		Vector2.UP: sfxIndex = 3
	
	if insult.perfTiming:
		%InsultHitSFX.volume_db = 19
		return perfectSFXAudio[sfxIndex]
	
	%InsultHitSFX.volume_db = 13
	return okSFXAudio[sfxIndex]
	
	

func _on_hurt_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Player_Hurt":
		isInvincible = false


func _on_player_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Wrench_Swing":
		%PlayerAnimation.play("Idle")


func play_combo_SFX(combo):
	var comboScaler: float = 0.4 
	%ComboSFX.pitch_scale = 1 + comboScaler * combo
	%ComboSFX.volume_db = -12 + comboScaler * combo 
	
	%ComboSFX.play()
	
	
	
