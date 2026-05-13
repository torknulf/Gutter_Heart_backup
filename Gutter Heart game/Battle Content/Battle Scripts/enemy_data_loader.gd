class_name EnemyDataLoader extends Node

## Returns dictionary with enemy data
func load_enemy(enemy_path: String) -> Dictionary:
	var file = FileAccess.open(enemy_path, FileAccess.READ)
	
	# in case loading fails
	if file == null:
		push_error("Could not open enemy file: ", enemy_path)
		return {}
	
	var json_text = file.get_as_text()
	
	var data = JSON.parse_string(json_text)
	
	# in case parsing fails
	if data == null:
		push_error("Invalid JSON in: " + enemy_path)
		return {}
	
	return data
