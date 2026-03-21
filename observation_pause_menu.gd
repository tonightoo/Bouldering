extends CanvasLayer

var observation_controller: ObservationController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel") and observation_controller.is_observation:
		$MenuContainer/ContinueButton.grab_focus()
		toggle_pause()

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_end_observation_button_pressed() -> void:
	get_tree().paused = false
	observation_controller.is_observation = false
	observation_controller.disable_observation()
	visible = false

func _on_restart_button_pressed() -> void:
	Dialogic.VAR.is_restart = true
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_top_button_pressed() -> void:
	Dialogic.VAR.is_restart = true
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func toggle_pause() -> void:
	var pa := not get_tree().paused
	get_tree().paused = pa
	visible = pa


func _on_continue_button_mouse_entered() -> void:
	$MenuContainer/ContinueButton.grab_focus()

func _on_end_observation_button_mouse_entered() -> void:
	$MenuContainer/EndObservationButton.grab_focus()
	
func _on_restart_button_mouse_entered() -> void:
	$MenuContainer/RestartButton.grab_focus()

func _on_top_button_mouse_entered() -> void:
	$MenuContainer/TopButton.grab_focus()

func _on_exit_button_mouse_entered() -> void:
	$MenuContainer/ExitButton.grab_focus()
