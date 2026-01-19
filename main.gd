extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start('MainMenu')


func _on_dialogic_signal(arg_str: String) -> void:
	if arg_str == "Start":
		get_tree().change_scene_to_file("res://stage_1.tscn")
	elif arg_str == "End":
		get_tree().quit()
		
		
