class_name TransitionElement extends Resource

@export var path1: String
@export var path2: String

var paths = [path1, path2]

@export_enum("Path 1", "Path 2") var transition_from: String
@export_enum("Path 1", "Path 2") var transition_to: String
