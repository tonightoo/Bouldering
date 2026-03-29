class_name Stage
extends Node2D

@onready var player = $Player
@onready var observation_pause_menu = $ObservationPauseMenu
@onready var bouldering_pause_menu = $BoulderingPauseMenu
@onready var stage_effect_label = $StageEffect/StageLabel
@onready var stage_generator = $StageGenerator
@onready var skill_selection = $SkillSelection

signal cleared

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	observation_pause_menu.observation_controller = player.observation_controller
	bouldering_pause_menu.player = player
	player.cleared.connect(inform_cleared)
	stage_effect_label.text = "Stage" + str(GlobalData.status.stage_level)
	stage_generator.initialize()


func inform_cleared() -> void:
	emit_signal("cleared")
