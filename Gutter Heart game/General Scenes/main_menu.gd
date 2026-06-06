class_name MenuClass extends RunnableScene


func _ready() -> void:
	super._ready()
	%SettingsMenu.settingsClosed.connect(show_menu)
	%SettingsMenu.hide_settings()




## START GAME
func _on_start_button_pressed() -> void:
	SceneManager.load_scene("res://Overworld Content/Overworld Scenes/Overworld Stages/overworld.tscn")
	%ChoiceSFX.play()

## SETTINGS
func _on_settings_button_pressed() -> void:
	%SettingsMenu.show_settings()
	%MainLayout.visible = false
	%ChoiceSFX.play()
	pass

## QUIT GAME
func _on_quit_button_pressed() -> void:
	%ChoiceSFX.play()
	get_tree().quit()




func show_menu():
	%MainLayout.visible = true
