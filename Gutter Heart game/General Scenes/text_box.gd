class_name TextBubble extends Control

@onready var marginContainer: MarginContainer = $TextLabel/MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.playTextSFX.connect(_on_play_text_SFX)
	DialogueManager.playChoiceSFX.connect(_on_play_choice_SFX)
	DialogueManager.playNextTextSFX.connect(_on_play_next_text_SFX)


## --- SIGNAL TRIGGERED FUNCTIONS ---

func _on_play_choice_SFX():
	%ChoiceSFX.play()

func _on_play_text_SFX():
	%TextSFX.play()

func _on_play_next_text_SFX():
	%NextTextSFX.play()
