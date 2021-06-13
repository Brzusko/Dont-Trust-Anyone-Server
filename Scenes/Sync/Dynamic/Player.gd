extends KinematicBody2D
class_name BasePlayer

const MOVE_SPEED: float = 100.0;

var unprocessed_inputs: Array = [];

var input_template = {
	"i": -1,
	"v": Vector2.ZERO,
	"last_recive": null,
}

var last_recived_input = {
	"i": 0,
	"v": Vector2.ZERO,
}

var last_processed_input = 0;

func setup(new_name):
	name = new_name;

func process_input(delta):
	while !unprocessed_inputs.empty():
		var input = unprocessed_inputs.pop_front();
		move_and_collide(input.v * (delta * MOVE_SPEED));
		last_processed_input = input.i;
	pass;
		
func serialize():
	if !is_inside_tree():
		return;
		
	return {
		"n": name,
		"p": global_position,
		"li": last_processed_input,	
	}

func clear_input():
	last_recived_input = input_template.duplicate();

remote func recive_input(_input: Dictionary):
	if last_recived_input.i > _input.i:
		return;
	last_recived_input = _input;
	unprocessed_inputs.append(last_recived_input);
	
