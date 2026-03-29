extends CanvasLayer

@onready var skill_container:VBoxContainer = $Panel/VBoxContainer

@onready var key_selection: KeySelection = $KeySelection

signal skill_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var skill_scene = preload("res://scenes/skill_button.tscn")
	var buttons: Array[SkillButton]
	for i in range(GlobalData.status.get_skill_candidate_num()):
		var skill_button: SkillButton = skill_scene.instantiate()
		skill_button.setup(GlobalData.pick_up_one_skill())
		skill_button.custom_minimum_size = Vector2(360.0, 96.0)
		if skill_button.skill_data.type == SkillData.SkillType.ACTIVE:
			skill_button.skill_selected.connect(on_active_skill_selected.bind(skill_button.skill_data))
		else:
			skill_button.skill_selected.connect(on_skill_selected.bind(skill_button.skill_data))
		skill_button.process_mode = Node.PROCESS_MODE_ALWAYS
		buttons.append(skill_button)
		skill_container.add_child(skill_button)

	for i in range(buttons.size()):
		buttons[i].focus_neighbor_top = buttons[(i - 1 + buttons.size()) % buttons.size()].get_path()
		buttons[i].focus_neighbor_bottom = buttons[(i + 1) % buttons.size()].get_path()

	#key_selection.action_keys.scale = Vector2(1.5, 1.5)
	#key_selection.arrow_keys.scale = Vector2(1.5, 1.5)

	key_selection.key_selected.connect(on_skill_selected.bind(null))
	key_selection.visibility_changed.connect(_on_visibility_changed_for_keys)

	key_selection.arrow_keys.up_button.pressed.connect(on_clicked.bind("up_action"))
	key_selection.arrow_keys.down_button.pressed.connect(on_clicked.bind("down_action"))
	key_selection.arrow_keys.left_button.pressed.connect(on_clicked.bind("left_action"))
	key_selection.arrow_keys.right_button.pressed.connect(on_clicked.bind("right_action"))
	
	key_selection.action_keys.up_button.pressed.connect(on_clicked.bind("triangle_action"))
	key_selection.action_keys.down_button.pressed.connect(on_clicked.bind("cross_action"))
	key_selection.action_keys.left_button.pressed.connect(on_clicked.bind("square_action"))
	key_selection.action_keys.right_button.pressed.connect(on_clicked.bind("circle_action"))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_skill_selected(skill: SkillData) -> void:
	GlobalData.status.pause_enabled = false
	skill_selected.emit()

func on_active_skill_selected(skill: SkillData) -> void:
	key_selection.skill_data = skill
	key_selection.visible = true

func _on_visibility_changed() -> void:
	if visible:
		for button in skill_container.get_children():
			if button is SkillButton:
				button.grab_focus()
				return


func _on_visibility_changed_for_keys() -> void:
	if visible:
		key_selection.arrow_keys.left_button.grab_focus()

func on_clicked(action_name: String) -> void:
	GlobalData.status.skill_slots[action_name] = key_selection.skill_data
	key_selection.key_selected.emit()
