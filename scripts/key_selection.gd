class_name KeySelection
extends CanvasLayer

var buttons: Dictionary[String, TextureButton] = {}

@onready var action_keys = $ActionKeys
@onready var arrow_keys = $ArrowKeys

signal key_selected

var skill_data: SkillData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	arrow_keys.up_button.action_name = "up_action"
	arrow_keys.down_button.action_name = "down_action"
	arrow_keys.left_button.action_name = "left_action"
	arrow_keys.right_button.action_name = "right_action"
	action_keys.left_button.action_name = "square_action"
	action_keys.up_button.action_name = "triangle_action"
	action_keys.right_button.action_name = "circle_action"
	action_keys.down_button.action_name = "cross_action"

	buttons["up_action"] = arrow_keys.up_button
	buttons["down_action"] = arrow_keys.down_button
	buttons["left_action"] = arrow_keys.left_button
	buttons["right_action"] = arrow_keys.right_button
	buttons["square_action"] = action_keys.left_button
	buttons["triangle_action"] = action_keys.up_button
	buttons["circle_action"] = action_keys.right_button
	buttons["cross_action"] = action_keys.down_button
	
	arrow_keys.right_button.focus_neighbor_right = arrow_keys.right_button.get_path_to(action_keys.left_button)
	action_keys.left_button.focus_neighbor_left = action_keys.left_button.get_path_to(arrow_keys.right_button)
	update_sprites()

func update_sprites() -> void:
	for action_key in GlobalData.status.skill_slots.keys():
		buttons[action_key].texture_normal = GlobalData.status.skill_slots[action_key].texture

func make_it_readonly() -> void:
	var all_buttons = self.find_children("*", "SlotButton", true)
	
	for btn in all_buttons:
			btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
			btn.focus_mode = Control.FOCUS_NONE
