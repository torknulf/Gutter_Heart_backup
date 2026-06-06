extends Node

const SAVE_PATH := "user://settings.save"


func get_settings_dict():
	return {
		"masterVolume": masterVolume,
		"musicVolume": musicVolume,
		"SFXVolume": SFXVolume,
		"screenMode": screenMode,
	}

func load_from_dict(data: Dictionary): # returns the default if the key does not exist!
	masterVolume = data.get("masterVolume", 0.2)
	musicVolume = data.get("musicVolume", 0.6)
	SFXVolume = data.get("SFXVolume", 0.2)
	screenMode = data.get("screenMode", 0)


func load_settings():
	if FileAccess.file_exists(SAVE_PATH):
		print("LOADED SAVED SETTINGS")
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		load_from_dict(data)
	else:
		print("RESETTED SETTINGS TO DEFAULT")
		reset_to_defaults()
		save_settings()


func save_settings():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(get_settings_dict())


func reset_to_defaults():
	masterVolume = 0.9
	musicVolume = 0.7
	SFXVolume = 0.45
	screenMode = 0


	apply_settings()



var masterVolume := 0.9
var musicVolume := 0.7
var SFXVolume := 0.45

var screenMode := 0 

#0.9
#0.85
#0.1

func _ready() -> void:
	load_settings()
	apply_settings()


func apply_settings():
	apply_audio()
	apply_screen_mode()
	
	save_settings()
	




func apply_screen_mode():
	match screenMode:
		0: # Windowed
			set_windowed()
			
		1: # Fullscreen
			set_fullscreen()

		2: # Borderless
			set_borderless()
	

func set_windowed():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	
	var screen = DisplayServer.window_get_current_screen()
	DisplayServer.window_set_current_screen(screen) # to force the window to current screen
	
	var screen_rect = DisplayServer.screen_get_usable_rect(screen)
	var screen_size = Vector2(screen_rect.size) # convert to Vector2 from Vector2i 
	var screen_pos = Vector2(screen_rect.position) 
	
	# set default window size, smaller than full screen
	var window_size = screen_size * 0.8 
	DisplayServer.window_set_current_screen(screen) # to force the window to current screen
	DisplayServer.window_set_size(window_size)
	
	# to center the window

	var window_pos = screen_pos + (screen_size - window_size) / 2
	
	DisplayServer.window_set_size(window_size)
	DisplayServer.window_set_position(window_pos)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func set_fullscreen():
	var screen = DisplayServer.window_get_current_screen()
	DisplayServer.window_set_current_screen(screen) # to force the window to current screen
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func set_borderless():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	# matches window to screen size and position
	var screen = DisplayServer.window_get_current_screen()
	DisplayServer.window_set_current_screen(screen) # to force the window to current screen
	var screen_rect = DisplayServer.screen_get_size(screen)
	var screen_pos = DisplayServer.screen_get_position(screen)

	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_size(screen_rect)
	DisplayServer.window_set_position(screen_pos)



## --- AUDIO SETTINGS ---

func apply_audio():
	var masterBus = AudioServer.get_bus_index("Master")
	var musicBus = AudioServer.get_bus_index("Music")
	var SFXBus = AudioServer.get_bus_index("SFX")

	print("UPDATE VOLUME", masterVolume)

	AudioServer.set_bus_volume_db(masterBus, linear_to_db(masterVolume))
	AudioServer.set_bus_volume_db(musicBus, linear_to_db(musicVolume))
	AudioServer.set_bus_volume_db(SFXBus, linear_to_db(SFXVolume))
