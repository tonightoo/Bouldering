extends Node2D


@onready var tutorial_tasks = $TutorialTasks
@onready var fade_animation = $FadeLayer
var is_entered_arm_tutorial: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tutorial_tasks.reset_tutorial_tasks()
	Dialogic.start("tutorial")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#腕のチュートリアルを開始
	if Dialogic.VAR.is_in_arm_tutorial and not is_entered_arm_tutorial:
		enter_arm_tutorial()	

	#腕のチュートリアルの終了判定
	if Dialogic.VAR.is_in_arm_tutorial and not Dialogic.VAR.is_arm_tutorial_done:
		if tutorial_tasks.is_clear_all():
			tutorial_tasks.reset_tutorial_tasks()
			Dialogic.VAR.is_arm_tutorial_done = true
			Dialogic.VAR.is_in_arm_tutorial = false
			Dialogic.end_timeline()
			fade_animation.connect_finished(on_fade_animation_finished)
			fade_animation.play()

func on_fade_animation_finished(anim_name: StringName) -> void:
	next_scene()

func next_scene() -> void:
	Dialogic.VAR.is_restart = false
	get_tree().change_scene_to_file("res://grab_tutorial.tscn")

			
func _input(event: InputEvent) -> void:
	# 腕を動かすチュートリアル
	if Dialogic.VAR.is_in_arm_tutorial:
		if event.is_action_pressed("LeftUp"):
			tutorial_tasks.set_clear(1)

		if event.is_action_pressed("LeftLeft"):
			tutorial_tasks.set_clear(2)

		if event.is_action_pressed("LeftDown"):
			tutorial_tasks.set_clear(3)
			
		if event.is_action_pressed("LeftRight"):
			tutorial_tasks.set_clear(4)

		if event.is_action_pressed("RightUp"):
			tutorial_tasks.set_clear(5)
			
		if event.is_action_pressed("RightLeft"):
			tutorial_tasks.set_clear(6)

		if event.is_action_pressed("RightDown"):
			tutorial_tasks.set_clear(7)

		if event.is_action_pressed("RightRight"):
			tutorial_tasks.set_clear(8)

func enter_arm_tutorial() -> void:
	tutorial_tasks.set_text(1, "- W or 左スティック上")
	tutorial_tasks.set_text(2, "- A or 左スティック左")
	tutorial_tasks.set_text(3, "- S or 左スティック下")
	tutorial_tasks.set_text(4, "- D or 左スティック右")
	tutorial_tasks.set_text(5, "- I or 右スティック上")
	tutorial_tasks.set_text(6, "- J or 右スティック左")
	tutorial_tasks.set_text(7, "- K or 右スティック下")
	tutorial_tasks.set_text(8, "- L or 右スティック右")

	tutorial_tasks.visible = true
	is_entered_arm_tutorial = true

	
