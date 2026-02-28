extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MenuContainer/StartButton.grab_focus()



func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://arm_tutorial_stage.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()




func _on_start_button_mouse_entered() -> void:
	$MenuContainer/StartButton.grab_focus()


func _on_exit_button_mouse_entered() -> void:
	$MenuContainer/ExitButton.grab_focus()
