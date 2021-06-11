extends KinematicBody2D
class_name BasePlayer

export var player_speed: float = 100.0;

var input = Vector2.ZERO;

func setup(new_name):
	name = new_name;

func process_input(delta):
	move_and_collide(input * delta * player_speed);
	
func serialize():
	if !is_inside_tree():
		return;
		
	return {
		"n": name,
		"p": global_position	
	}

remote func recive_input(_input):
	input = _input;
	return;
