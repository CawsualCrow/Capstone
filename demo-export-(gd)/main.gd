extends Node

var score


# Called when the node enters the scene tree for the first time.
func _ready():
	score = 0
	if not FileAccess.file_exists("user://savegame.save"):
		print("Broke")
	else:
		var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		while save_file.get_position() < save_file.get_length():
			var json_string = save_file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			var node_data = json.data
			score = int(node_data["score"])

# Use JSON to save game
func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_data = {"score": score}
	var json_score = JSON.stringify(save_data)
	save_file.store_line(json_score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_score(score):
	$ScoreLabel.text = str(score)
	
func _on_counter_button_pressed():
	score += 1
	update_score(score)
	save_game()


func _on_reset_button_pressed():
	score = 0
	update_score(score)
	save_game()
