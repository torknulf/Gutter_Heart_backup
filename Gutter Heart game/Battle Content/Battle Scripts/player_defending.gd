class_name PlayerDefending extends Node2D


var hittableInsults = {Vector2.RIGHT: [], Vector2.LEFT: [], Vector2.UP: [], Vector2.DOWN: []}

var hits: int = 0
var hurts: int = 0

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	%HitsLabel.text = "Hits: " + str(hits)
	%HurtsLabel.text = "Hurts: " + str(hurts)
	
	
	
	if %HitzoneVisibilityTimer.time_left != 0:
		return
		
	
	# add cooldown timer check, in case you have missed a hit
	if Input.is_action_just_pressed("hit_right"):
		try_hit(Vector2.RIGHT)
		%HitzonePivot.rotation = deg_to_rad(0)
	elif Input.is_action_just_pressed("hit_left"):
		try_hit(Vector2.LEFT)
		%HitzonePivot.rotation = deg_to_rad(180)
	elif Input.is_action_just_pressed("hit_up"):
		try_hit(Vector2.UP)
		%HitzonePivot.rotation = deg_to_rad(-90)
	elif Input.is_action_just_pressed("hit_down"):
		try_hit(Vector2.DOWN)
		%HitzonePivot.rotation = deg_to_rad(90)




func try_hit(hitDir: Vector2):
	%Hitzone.visible = true
	%HitzoneVisibilityTimer.start()
	
	if hittableInsults[hitDir] != []:
		print(hittableInsults[hitDir])
		remove_hittable_insult(hittableInsults[hitDir][0])
		hits += 1
	else:
		print("empty ", hittableInsults[hitDir])





func take_damage(insult: Insult):
	hurts += 1
	remove_hittable_insult(insult)



func add_hittable_insult(insult: Insult):
	hittableInsults[insult.approachDir].append(insult)



func remove_hittable_insult(insult: Insult):
	hittableInsults[insult.approachDir].remove_at(0) # should always be the oldest object that gets removed?
	insult.queue_free()


func _on_hitzone_visibility_timer_timeout() -> void:
	%Hitzone.visible = false
