class_name BeatManager extends Node

@export var bpm: float = 120.0
var songTime: float = 0.0

var isActive: bool = false

signal newBeat



## --- PROCESSES ---


func _process(delta: float) -> void:
	if !isActive:
		return
	
	update_time_vars(delta)
	
	%BeatNrLabel.text = "Bear Nr: " + str(get_beat())



## updates songtime and sends out signal on new beats
func update_time_vars(delta: float) -> void:
	var oldBeat = get_beat()
	
	songTime += delta
	
	if oldBeat != get_beat():
		%MetronomeSFX.play()
		newBeat.emit()



## --- FUNCTIONALITY ----


func start_counting_beat():
	isActive = true
	%MetronomeSFX.play()
	songTime = 0.0


func stop_counting_beat():
	isActive = false
	songTime = 0.0



## --- GET FUNCTIONS ---

func get_song_time():
	return songTime


## returns the number of the current beat
func get_beat():
	return floor(songTime / get_bps())


## beats per second, 120 bpm = 0.5 bps
func get_bps():
	return (60.0 / bpm)


## Beats per minute
func get_bpm():
	return bpm
