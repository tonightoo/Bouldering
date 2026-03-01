extends Node2D
@onready var tutorial_tasks = $TutorialTasks
@onready var fade_animation = $FadeLayer
@onready var player = $Player
var is_entered_advanced_tutorial: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tutorial_tasks.reset_tutorial_tasks()
	Dialogic.start("advanced_tutorial")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Dialogic.VAR.is_in_advanced_tutorial and not is_entered_advanced_tutorial:
		enter_advanced_tutorial()

	if Dialogic.VAR.is_in_advanced_tutorial and player.lunge_controller.has_lunged_in_charge:
		tutorial_tasks.set_clear(1)

	if Dialogic.VAR.is_in_advanced_tutorial and tutorial_tasks.is_clear_all():
		Dialogic.VAR.is_in_advanced_tutorial = false
		await get_tree().create_timer(1.0).timeout
		tutorial_tasks.reset_tutorial_tasks()
		Dialogic.end_timeline()
		fade_animation.connect_finished(on_fade_animation_finished)
		fade_animation.play()

func on_fade_animation_finished(anim_name: StringName) -> void:
	Dialogic.VAR.is_restart = false
	next_scene()

func next_scene() -> void:
	get_tree().change_scene_to_file("res://stage_1.tscn")

func enter_advanced_tutorial() -> void:
	tutorial_tasks.set_text(1, "両手を下に引いて溜め離す")
	tutorial_tasks.apply_visible()
	is_entered_advanced_tutorial = true
