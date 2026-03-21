class_name ObservationController
extends Node

# オブザベの残り時間
var observation_time_remaining: float
var camera: Camera2D
var status: PlayerStatus
var is_observation: bool = false
var darkness: CanvasModulate
var spotlight: PointLight2D
var message_label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_observation:
		return
		
	update_camera(delta)
	update_visible_holds()
	handle_confirmation_input()
	observation_time_remaining -= delta
	message_label.text = "オブザベタイム！%2.1f" % observation_time_remaining
	if observation_time_remaining <= 0:
		is_observation = false
		disable_observation()

# オブザベ終了時の処理
func disable_observation() -> void:
	darkness.color = Color(1.0, 1.0, 1.0, 1.0)
	spotlight.enabled = false
	camera.position = Vector2(0.0, 0.0)
	message_label.text = ""
	update_visible_holds()

# オブザベ開始時の処理	
func enable_observation() -> void:
	darkness.color = Color(status.get_observation_darkness(), status.get_observation_darkness(), status.get_observation_darkness(), 1.0)
	if spotlight:
		spotlight.visible = true
		spotlight.enabled = true
		spotlight.texture_scale = status.get_observation_vision_radius() / 100.0
		spotlight.color = Color.WHITE

func unvisible_message() -> void:
	message_label.text = ""

func update_camera(delta: float) -> void:
	var move_dir = Vector2(
		Input.get_action_strength("LeftRight") - Input.get_action_strength("LeftLeft") + Input.get_action_strength("RightRight") - Input.get_action_strength("RightLeft"),
		Input.get_action_strength("LeftDown")  - Input.get_action_strength("LeftUp") + Input.get_action_strength("RightDown") - Input.get_action_strength("RightUp")
	)
	if move_dir.length() > 0:
		camera.global_position += move_dir.normalized() * status.get_observation_camera_speed() * delta
		spotlight.global_position = camera.global_position
	
func update_visible_holds() -> void:
	var camera_pos = camera.global_position
	for hold in get_tree().get_nodes_in_group("hold"):
		var distance = hold.global_position.distance_to(camera_pos)
		hold.is_currently_visible = (distance <= status.get_observation_vision_radius())
		hold.update_visibility(is_observation)

func handle_confirmation_input() -> void:
	if Input.is_action_just_pressed("LeftObservation"):
		confirm_visible_holds()
	elif Input.is_action_just_pressed("RightObservation"):
		confirm_visible_holds()
	elif Input.is_action_just_pressed("LeftHold"):
		confirm_visible_holds()
	elif Input.is_action_just_pressed("RightHold"):
		confirm_visible_holds()
		
func confirm_visible_holds() -> void:
	for hold in get_tree().get_nodes_in_group("hold"):
		if hold.is_currently_visible and hold.is_observed:
			hold.confirm()
