extends StaticBody2D
class_name BaseStatic

export var type: String;

func _ready():
	name = UUID.v4();

func _interact(by_who):
	pass;

func _serialize():
	return {
		"n": name,
		"p": global_position,
		"e": type
	}

func _get_state():
	pass;

