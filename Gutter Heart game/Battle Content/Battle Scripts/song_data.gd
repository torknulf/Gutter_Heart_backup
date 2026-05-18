class_name SongData extends Resource

@export var songName: String

@export var music: AudioStream

@export var bpm: float = 120.0

@export var beatsPerMeasure: int = 4 # for rhythms like 3/4, 4/4, 5/4

@export var beatOffset: float = 0.0

@export var volume: float =  0.0
