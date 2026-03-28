extends CanvasLayer

@onready var skill_container:VBoxContainer = $Panel/VBoxContainer

signal skill_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var skill_scene = preload("res://skill_button.tscn")
	var buttons: Array[SkillButton]
	for i in range(GlobalData.status.get_skill_candidate_num()):
		var skill_button: SkillButton = skill_scene.instantiate()
		skill_button.setup(GlobalData.pick_up_one_skill())
		skill_button.custom_minimum_size = Vector2(360.0, 96.0)
		skill_button.connect("skill_selected", on_skill_selected)
		skill_button.process_mode = Node.PROCESS_MODE_ALWAYS
		buttons.append(skill_button)
		skill_container.add_child(skill_button)

	for i in range(buttons.size()):
		buttons[i].focus_neighbor_top = buttons[(i - 1 + buttons.size()) % buttons.size()].get_path()
		buttons[i].focus_neighbor_bottom = buttons[(i + 1) % buttons.size()].get_path()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_skill_selected() -> void:
	skill_selected.emit()


func _on_visibility_changed() -> void:
	if visible:
		for button in skill_container.get_children():
			if button is SkillButton:
				button.grab_focus()
				return
