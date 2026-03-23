extends Node2D


var current_stage: Stage
var status: PlayerStatus
var stage_scene: PackedScene
@onready var fade_animation = $FadeLayer

func _ready() -> void:
	var config = PlayerConfig.new()
	status = PlayerStatus.new(config)
	stage_scene = preload("res://stage.tscn")
	fade_animation.connect_inout_finished(next_stage)
	load_next_stage()

func load_next_stage():
	if get_tree().has_group("stage"):
		for node in get_tree().get_nodes_in_group("stage"):
			node.queue_free()
	
	var next_stage = stage_scene.instantiate()
	next_stage.initialize(status)
	next_stage.cleared.connect(_on_stage_cleared)
	add_child(next_stage)

	
func _on_stage_cleared() -> void:
	fade_animation.play_inout()

func next_stage(anim_name: StringName) -> void:
	status.stage_level += 1
	load_next_stage()
	
