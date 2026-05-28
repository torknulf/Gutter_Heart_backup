class_name OverworldCamera extends Camera2D
var player: OverworldPLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("OverworldPlayer")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = player.global_position + Vector2(0, -300)
