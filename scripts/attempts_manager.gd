extends Node2D


var current_stage: Stage
var stage_scene: PackedScene
@onready var fade_animation = $FadeLayer

func _ready() -> void:
	stage_scene = preload("res://scenes/stage.tscn")
	#fade_animation.connect_finished(skill_select)
	load_next_stage()

func _process(delta: float) -> void:
	for action_key in GlobalData.status.skill_slots.keys():
		if Input.is_action_just_pressed(action_key):
			var skill: SkillData = GlobalData.status.skill_slots[action_key]
			skill.logic.execute(action_key, current_stage.player, current_stage)

func load_next_stage():
	if get_tree().has_group("stage"):
		for node in get_tree().get_nodes_in_group("stage"):
			node.queue_free()
	
	var next_stage = stage_scene.instantiate()
	next_stage.cleared.connect(skill_select)
	add_child(next_stage)
	current_stage = next_stage
	next_stage.skill_selection.connect("skill_selected", move_next_stage)
	
#func _on_stage_cleared() -> void:
	#fade_animation.play()
	
func skill_select() -> void:
	for skill_key in GlobalData.status.skill_slots.keys():
		GlobalData.status.skill_slots[skill_key].logic.next_usable_time = 0.0
	current_stage.player.keys.update_cooltime()
	Engine.time_scale = 0.2
	await get_tree().create_timer(0.6).timeout	
	Engine.time_scale = 1.0
	get_tree().paused = true
	current_stage.player.blur_rect.visible = true
	current_stage.skill_selection.visible = true
	current_stage.player.adjust_keys_scale(1.0)

func move_next_stage() -> void:
	get_tree().paused = false
	GlobalData.status.stage_level += 1
	GlobalData.status.recalcurate()
	load_next_stage()
	
