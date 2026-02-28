extends Node2D


@onready var tutorial_tasks = $TutorialTasks
@onready var player = $Player
@onready var fade_animation = $FadeLayer
var is_entered_grab_tutorial: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tutorial_tasks.reset_tutorial_tasks()
	fade_animation.connect_finished(on_fade_animation_finished)
	Dialogic.start("grab_tutorial")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Dialogic.VAR.is_in_grab_tutorial and not is_entered_grab_tutorial:
		enter_grab_tutorial()
	
	if Dialogic.VAR.is_in_grab_tutorial and player.hand_controller.grabbed_hold_left != null:
		tutorial_tasks.set_clear(1)
		
	if Dialogic.VAR.is_in_grab_tutorial and player.hand_controller.grabbed_hold_right != null:
		tutorial_tasks.set_clear(2)

	if Dialogic.VAR.is_in_grab_tutorial and player.goal_checker.is_goaled:
		tutorial_tasks.set_clear(3)
	
	if Dialogic.VAR.is_in_grab_tutorial and tutorial_tasks.is_clear_all():
		Dialogic.VAR.is_in_grab_tutorial = false
		tutorial_tasks.reset_tutorial_tasks()
		Dialogic.end_timeline()
		fade_animation.play()
	
func on_fade_animation_finished(anim_name: StringName) -> void:
	next_scene()

func next_scene() -> void:
	Dialogic.VAR.is_restart = false
	get_tree().change_scene_to_file("res://advanced_tutorial.tscn")
	
func enter_grab_tutorial() -> void:
	tutorial_tasks.set_text(1, "左手で掴む E or L1")
	tutorial_tasks.set_text(2, "右手で掴む U or R1")
	tutorial_tasks.set_text(3, "ゴールにたどりつけ！")
	tutorial_tasks.apply_visible()
	is_entered_grab_tutorial = true
