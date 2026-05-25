class_name GameScene extends Node

signal hasFadedOut 
signal hasFadedIn



func _ready() -> void:
	fade_in()




func fade_out():
	%SceneTransitionPlayer.play("fade_out")

func fade_in():
	%SceneTransitionPlayer.play("fade_in")



func _on_scene_transition_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		hasFadedOut.emit()
		
	
	elif anim_name == "fade_in":
		hasFadedIn.emit()
		#load_player()
