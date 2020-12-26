extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _score = 0
	
func _on_Grid_score_changed(new_score):
	$VBoxContainer/ScoreLabel.text = str(new_score)
	_score = new_score


func _on_Grid_next_type_changed(new_type):
	$VBoxContainer/VBoxContainer/CenterContainer/Shape.type = new_type


func _on_Grid_game_over():
	$MarginContainer/GameMessage.text = "Game over with a score of " + str(_score) + "\nR to try again"


func _on_Grid_game_started():
	$MarginContainer/GameMessage.text = ""
