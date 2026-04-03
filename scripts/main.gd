extends CanvasLayer

@onready var fade_animation = $FadeLayer
@onready var title_log = $TitleLog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MenuContainer/StartButton.grab_focus()
	animate_logo()

func animate_logo() -> void:
	var final_pos = Vector2(256.0, 110.0)
	var start_pos = Vector2(256.0, -200.0)
	var tween = create_tween()
	tween.tween_property(title_log, "position", final_pos, 3.5)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		fade_animation.play()
	
	if event.is_action("ui_select"):
		fade_animation.play()


func to_tutorial_scene(anim_name: StringName) -> void:
	GlobalData.status.skill_list.clear()
	get_tree().change_scene_to_file("res://scenes/tutorials/arm_tutorial_stage.tscn")	

func to_story_scene(anim_name: StringName) -> void:
	#get_tree().change_scene_to_file("res://stage_1.tscn")
	#get_tree().change_scene_to_file("res://stage.tscn")	
	GlobalData.status.initialize()
	get_tree().change_scene_to_file("res://scenes/attempts_manager.tscn")

func _on_start_button_pressed() -> void:
	fade_animation.connect_finished(to_story_scene)
	fade_animation.play()

func _on_tutorial_button_pressed() -> void:
	fade_animation.connect_finished(to_tutorial_scene)
	fade_animation.play()

func _on_exit_button_pressed() -> void:
	get_tree().quit()	

func _on_start_button_mouse_entered() -> void:
	$MenuContainer/StartButton.grab_focus()

func _on_tutorial_button_mouse_entered() -> void:
	$MenuContainer/TutorialButton.grab_focus()

func _on_exit_button_mouse_entered() -> void:
	$MenuContainer/ExitButton.grab_focus()
