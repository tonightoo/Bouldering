extends Node2D

@onready var player = $Player
@onready var observation_pause_menu = $ObservationPauseMenu
@onready var bouldering_pause_menu = $BoulderingPauseMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	observation_pause_menu.observation_controller = player.observation_controller
	bouldering_pause_menu.player = player
