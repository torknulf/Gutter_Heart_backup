class_name SettingsMenu extends Control

signal settingsClosed

func _ready() -> void:
	pass



## UPDATE UI ELEMENTS WITH CURRENT SETTINGS
func load_settings_into_ui():
	# --- DISPLAY ---
	%ScreenModeOptions.select(SettingsManager.screenMode)
	
	
	
	# --- AUDIO --- (block signals in case value change is triggered)
	%MasterVolSlider.set_block_signals(true)
	%MasterVolSlider.value = SettingsManager.masterVolume
	%MasterVolSlider.set_block_signals(false)
	
	%BGMVolSlider.set_block_signals(true)
	%BGMVolSlider.value = SettingsManager.musicVolume
	%BGMVolSlider.set_block_signals(false)
	
	%SFXVolSlider.set_block_signals(true)
	%SFXVolSlider.value = SettingsManager.SFXVolume
	%SFXVolSlider.set_block_signals(false)


## APPLY SETTINGS
func _on_apply_button_pressed() -> void:
	SettingsManager.apply_settings()
	%ChoiceSFX.play()


## RETURN FROM SETTINGS
func _on_back_button_pressed() -> void:
	hide_settings()
	%ChoiceSFX.play()


## RESET TO DEFAULT SETTINGS
func _on_reset_button_pressed() -> void:
	SettingsManager.reset_to_defaults()
	load_settings_into_ui()
	%ChoiceSFX.play()


func show_settings():
	load_settings_into_ui()
	visible = true
	#mouse_filter = Control.MOUSE_FILTER_STOP

func hide_settings():
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	settingsClosed.emit()




# -----DISPLAY----- 

## SELECT SCREEN MODE
func _on_screen_mode_options_item_selected(index: int) -> void:
	SettingsManager.screenMode = index




# -----AUDIO----- 

## MASTER VOLUME
func _on_master_vol_slider_value_changed(value: float) -> void:
	SettingsManager.masterVolume = value
	print("MASTER VALUE ", value)


## MUSIC VOLUME
func _on_bgm_vol_slider_value_changed(value: float) -> void:
	SettingsManager.musicVolume = value


## SFX VOLUME
func _on_sfx_vol_slider_value_changed(value: float) -> void:
	SettingsManager.SFXVolume = value
