extends Camera2D

var shakeStrength: float = 0.0
var shakeDecay: float = 20.0

func _ready() -> void:
	%PlayerDefending.comboShake .connect(screen_shake)

func _process(delta: float) -> void:
	if shakeStrength > 0:
		shakeStrength = move_toward(shakeStrength, 0.0, shakeDecay * delta)
		offset = Vector2(randf_range(-shakeStrength, shakeStrength), randf_range(-shakeStrength, shakeStrength))

	else:
		offset = Vector2.ZERO


func screen_shake(strength: float = 6):
	offset = Vector2.ZERO
	shakeStrength = strength
