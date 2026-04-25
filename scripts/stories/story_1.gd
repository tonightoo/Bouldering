extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalData.selected_character_name = "Kabeoji"
	GlobalData.set_character()
	GlobalData.status.initialize()
	Dialogic.start("story_1")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
