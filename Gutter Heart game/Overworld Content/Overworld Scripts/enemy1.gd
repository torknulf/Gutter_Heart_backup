extends Interactable



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is OverworldPLayer:
		get_tree().change_scene_to_file("res://Battle Content/Battle Scenes/battle_scene_general.tscn")
