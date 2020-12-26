extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
	
func _on_Grid_score_changed(new_score):
	$VBoxContainer/ScoreLabel.text = str(new_score)


func _on_Grid_next_type_changed(new_type):
	$VBoxContainer/VBoxContainer/CenterContainer/Shape.type = new_type
