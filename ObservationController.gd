class_name ObservationController
extends Node

# オブザベの残り時間
var observation_time_remaining: float
var camera: Camera2D
var config: PlayerConfig
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
	darkness.color = Color(config.OBSERVATION_DARKNESS, config.OBSERVATION_DARKNESS, config.OBSERVATION_DARKNESS, 1.0)
	if spotlight:
		spotlight.enabled = true
		spotlight.texture_scale = config.OBSERVATION_VISION_RADIUS / 100.0
		spotlight.color = Color.WHITE

func unvisible_message() -> void:
	message_label.text = ""

func update_camera(delta: float) -> void:
	var move_dir = Vector2(
		Input.get_action_strength("LeftRight") - Input.get_action_strength("LeftLeft"),
		Input.get_action_strength("LeftDown")  - Input.get_action_strength("LeftUp")
	)
	if move_dir.length() > 0:
		camera.global_position += move_dir.normalized() * config.OBSERVATION_CAMERA_SPEED * delta
		spotlight.global_position = camera.global_position
	
func update_visible_holds() -> void:
	var camera_pos = camera.global_position
	for hold in get_tree().get_nodes_in_group("hold"):
		var distance = hold.global_position.distance_to(camera_pos)
		hold.is_currently_visible = (distance <= config.OBSERVATION_VISION_RADIUS)
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
