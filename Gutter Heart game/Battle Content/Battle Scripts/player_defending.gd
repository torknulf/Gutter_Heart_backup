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

var isInvincible: bool = false

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

		update_resolve(insult.perfTiming)
		remove_hittable_insult(insult)
		%InsultHitSFX.stream = select_hit_SFX(insult)
		%InsultHitSFX.play()


func take_damage(insult: Insult):
	if isInvincible:
		%PlayerIFrameHurtSFX.play()
		remove_hittable_insult(insult)
		return
	
	
	var lostResolve = 50
	if resolve - lostResolve <= 0:
		resolve = 0
	else:
		resolve -= lostResolve
	updateResolve.emit(resolve)
	lose_hp()
	
	%PlayerHurtSFX.play()
	remove_hittable_insult(insult)



func add_hittable_insult(insult: Insult):
	hittableInsults[insult.approachDir].append(insult)



func remove_hittable_insult(insult: Insult):
	hittableInsults[insult.approachDir].remove_at(0) # should always be the oldest object that gets removed?
	insult.queue_free()


func _on_hitzone_visibility_timer_timeout() -> void:
	%Hitzone.visible = false


func update_resolve(isHitPerfect):
	var amount
	if isHitPerfect:
		amount = 15
	else:
		amount = 5
	
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
	else:
		hp -= 1
	
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
