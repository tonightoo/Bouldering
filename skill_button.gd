class_name SkillButton
extends Button

var skill_data: SkillData

@onready var skill_texture = $HBoxContainer/SkillIconTexture
@onready var skill_name = $HBoxContainer/BackgroundPanel/VBoxContainer/SkillNameLabel
@onready var skill_description = $HBoxContainer/BackgroundPanel/VBoxContainer/SkillDescriptionLabel
@onready var panel = $HBoxContainer/BackgroundPanel

signal skill_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if skill_data:
		skill_texture.texture = skill_data.texture
		skill_name.text = skill_data.name
		skill_description.text = skill_data.description

func setup(skill: SkillData) -> void:
	skill_data = skill
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	GlobalData.status.skill_list.set(skill_data.id, skill_data)
	skill_selected.emit()






func _on_focus_entered() -> void:
	panel.modulate = Color(1.5, 1.5, 1.5)


func _on_focus_exited() -> void:
	panel.modulate = Color(1.0, 1.0, 1.0)
