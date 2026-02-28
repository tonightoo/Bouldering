extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		$MenuContainer/ContinueButton.grab_focus()
		toggle_pause()

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_restart_button_pressed() -> void:
	Dialogic.VAR.is_restart = true
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func toggle_pause() -> void:
	var pa := not get_tree().paused
	get_tree().paused = pa
	visible = pa


func _on_continue_button_mouse_entered() -> void:
	$MenuContainer/ContinueButton.grab_focus()


func _on_restart_button_mouse_entered() -> void:
	$MenuContainer/RestartButton.grab_focus()


func _on_exit_button_mouse_entered() -> void:
	$MenuContainer/ExitButton.grab_focus()
