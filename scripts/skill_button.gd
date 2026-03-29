class_name SkillButton
extends Button

var skill_data: SkillData

@onready var skill_texture = $HBoxContainer/SkillIconTexture
@onready var skill_name = $HBoxContainer/BackgroundPanel/VBoxContainer/HBoxContainer/SkillNameLabel
@onready var skill_description = $HBoxContainer/BackgroundPanel/VBoxContainer/SkillDescriptionLabel
@onready var skill_type = $HBoxContainer/BackgroundPanel/VBoxContainer/HBoxContainer/SkillTypeLabel
@onready var panel = $HBoxContainer/BackgroundPanel

signal skill_selected(skill: SkillData)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not skill_data:
		return

	skill_texture.texture = skill_data.texture
	skill_name.text = skill_data.name
	skill_description.text = skill_data.description
	if skill_data.type == SkillData.SkillType.ACTIVE:
		skill_type.text = "A"
		skill_type.modulate = Color.RED
	else:
		skill_type.text = "P"
		skill_type.modulate = Color.AQUA

func setup(skill: SkillData) -> void:
	skill_data = skill
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	GlobalData.status.skill_list.append(skill_data)
	self.z_index = 10
	var tween = self.create_tween().set_parallel(true)
	var center_pos = get_viewport_rect().size / 2
	tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

	if skill_data.type == SkillData.SkillType.ACTIVE:
		self.z_index = 10
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.5)
		tween.tween_property(self, "global_position", center_pos, 0.5)
		skill_selected.emit()
	else:
		tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.5)
		tween.tween_property(self, "global_position", center_pos, 0.5)
		tween.tween_property(self, "modulate:a", 0.0, 0.5)
		await tween.finished
		skill_selected.emit()


func _on_focus_entered() -> void:
	panel.modulate = Color(1.5, 1.5, 1.5)


func _on_focus_exited() -> void:
	panel.modulate = Color(1.0, 1.0, 1.0)
