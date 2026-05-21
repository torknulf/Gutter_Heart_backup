class_name BeatManager extends Node

var songTime: float = 0.0

@export var currSong: SongData # resource!

var isActive: bool = false

signal newBeat
signal newBar

var barStart



## --- PROCESSES ---

func _ready() -> void:
	%BGMusic.stream = currSong.music
	%BGMusic.play()

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
		barStart = flip_barstart()
		newBar.emit(barStart)
		%MetronomeSFXFirst.play()


## --- FUNCTIONALITY ----


func start_counting_beat():
	isActive = true
	%MetronomeSFX.play()
	songTime = currSong.beatOffset


func stop_counting_beat():
	isActive = false
	songTime = currSong.beatOffset


func flip_barstart():
	if barStart:
		return false
	else:
		return true


## --- GET FUNCTIONS ---

func get_song_time():
	return songTime + currSong.beatOffset


## returns the number of the current beat
func get_beat():
	return floor((songTime + currSong.beatOffset) / get_bps())

## returns the number of the current musical bar
func get_bar():
	return floor(get_beat() / currSong.beatsPerMeasure) 


## beats per second, 120 bpm = 0.5 bps
func get_bps():
	return (60.0 / currSong.bpm)


## Beats per minute
func get_bpm():
	return currSong.bpm
