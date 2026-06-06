extends Control



func _on_retry_button_pressed() -> void:
	%ChoiceSFX.play()
	SceneManager.reload_scene()


func _on_main_menu_button_pressed() -> void:
	%ChoiceSFX.play()
	SceneManager.load_scene("res://General Scenes/main_menu.tscn")
