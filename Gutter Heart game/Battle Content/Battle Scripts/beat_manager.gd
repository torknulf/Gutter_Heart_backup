class_name BeatManager extends Node

@export var bpm: float = 120.0
var songTime: float = 0.0

@export var songOffset: float

var isActive: bool = false

signal newBeat
signal newBar



## --- PROCESSES ---


func _process(delta: float) -> void:
	if !isActive:
		return
	
	update_time_vars(delta)
	
	%BeatNrLabel.text = "Bear Nr: " + str(get_beat())



## updates songTime and sends out signal on new beats
func update_time_vars(delta: float) -> void:
	var oldBeat = get_beat()
	var oldBar = get_bar()
	
	songTime += delta
	
	if oldBeat != get_beat():
		%MetronomeSFX.play()
		newBeat.emit()
	
	if oldBar != get_bar():
		newBar.emit()
		%MetronomeSFXFirst.play()


## --- FUNCTIONALITY ----


func start_counting_beat():
	isActive = true
	%MetronomeSFX.play()
	songTime = songOffset


func stop_counting_beat():
	isActive = false
	songTime = songOffset



## --- GET FUNCTIONS ---

func get_song_time():
	return songTime + songOffset


## returns the number of the current beat
func get_beat():
	return floor((songTime + songOffset) / get_bps())

## returns the number of the current musical bar
func get_bar():
	return floor(get_beat() / 4) #3 ONLY FOR 4/4 NOW


## beats per second, 120 bpm = 0.5 bps
func get_bps():
	return (60.0 / bpm)


## Beats per minute
func get_bpm():
	return bpm
