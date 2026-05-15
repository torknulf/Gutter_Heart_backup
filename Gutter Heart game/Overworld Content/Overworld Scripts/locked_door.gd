extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Sprite2D.visible = true
	%CollisionShape2D.disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func unlock():
	%Sprite2D.visible = false
	%CollisionShape2D.disabled = true
