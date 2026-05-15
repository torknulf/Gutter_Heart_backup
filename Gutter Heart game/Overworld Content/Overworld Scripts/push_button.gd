extends Interactable


@export var connectedLock : StaticBody2D




func perform_interaction():
	connectedLock.unlock()
