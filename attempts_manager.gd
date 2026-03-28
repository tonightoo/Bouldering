extends Node2D


var current_stage: Stage
var stage_scene: PackedScene
@onready var fade_animation = $FadeLayer

func _ready() -> void:
	stage_scene = preload("res://stage.tscn")
	#fade_animation.connect_finished(skill_select)
	load_next_stage()

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
	Engine.time_scale = 0.2
	await get_tree().create_timer(0.6).timeout	
	Engine.time_scale = 1.0
	get_tree().paused = true
	current_stage.player.blur_rect.visible = true
	current_stage.skill_selection.visible = true

func move_next_stage() -> void:
	get_tree().paused = false
	GlobalData.status.stage_level += 1
	load_next_stage()
	
