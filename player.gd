extends Node2D

const HandController = preload("res://HandController.gd")
const IKSolver = preload("res://IKSolver.gd")
const FatigueManager = preload("res://FatigueManager.gd")
const GoalChecker = preload("res://GoalChecker.gd")
var hand_controller: HandController = null
var ik_solver: IKSolver = null
var fatigue_manager: FatigueManager = null
var goal_checker: GoalChecker = null

# 速度関係
var left_hand_velocity: Vector2 = Vector2.ZERO
var right_hand_velocity: Vector2 = Vector2.ZERO

# パラメータ
@export var config: PlayerConfig

@onready var body = $Body

# 左手
@onready var left_shoulder =  $Body/LeftShoulder
@onready var left_elbow = $Body/LeftShoulder/LeftUpperArm/LeftElbow
@onready var left_upper_arm = $Body/LeftShoulder/LeftUpperArm
@onready var left_fore_arm = $Body/LeftShoulder/LeftUpperArm/LeftElbow/LeftForeArm
@onready var left_hand = $Body/LeftShoulder/LeftUpperArm/LeftElbow/LeftForeArm/LeftHand
@onready var left_hand_target = $LeftHandTarget
@onready var left_fatigue_ui = $Body/LeftFatigueUI

#右手
@onready var right_shoulder = $Body/RightShoulder
@onready var right_elbow = $Body/RightShoulder/RightUpperArm/RightElbow
@onready var right_upper_arm = $Body/RightShoulder/RightUpperArm
@onready var right_fore_arm = $Body/RightShoulder/RightUpperArm/RightElbow/RightForeArm
@onready var right_hand = $Body/RightShoulder/RightUpperArm/RightElbow/RightForeArm/RightHand
@onready var right_hand_target = $RightHandTarget
@onready var right_fatigue_ui = $Body/RightFatigueUI

#UI
@onready var goal_label = $CanvasLayer/GoalLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	config = PlayerConfig.new()
	goal_label.text = ""

	# HandController を生成して参照ノードをセット
	hand_controller = HandController.new()
	add_child(hand_controller)
	hand_controller.left_hand_target = left_hand_target
	hand_controller.right_hand_target = right_hand_target
	hand_controller.left_hand = left_hand
	hand_controller.right_hand = right_hand

	# IKSolver を生成して参照ノードをセット
	ik_solver = IKSolver.new()
	add_child(ik_solver)
	ik_solver.config = config
	ik_solver.body = body

	# FatigueManager を生成して参照ノードをセット
	fatigue_manager = FatigueManager.new()
	add_child(fatigue_manager)
	fatigue_manager.config = config
	fatigue_manager.hand_controller = hand_controller
	fatigue_manager.left_elbow = left_elbow
	fatigue_manager.right_elbow = right_elbow
	fatigue_manager.left_shoulder = left_shoulder
	fatigue_manager.right_shoulder = right_shoulder
	fatigue_manager.left_hand = left_hand
	fatigue_manager.right_hand = right_hand

	# GoalChecker を生成して参照ノードをセット
	goal_checker = GoalChecker.new()
	add_child(goal_checker)
	goal_checker.config = config
	goal_checker.hand_controller = hand_controller
	goal_checker.goal_label = goal_label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if Input.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()
	if Input.is_action_pressed("LeftHold"):
		hand_controller.try_grab(left_hand, true)
	
	if Input.is_action_pressed("RightHold"):
		hand_controller.try_grab(right_hand, false)
		
	if Input.is_action_just_released("LeftHold"):
		hand_controller.release_left_grab()

	if Input.is_action_just_released("RightHold"):
		hand_controller.release_right_grab()

	apply_hold_movement()
		
	fatigue_manager.update(delta)
	left_fatigue_ui.fatigue = fatigue_manager.left_hand_fatigue
	update_hand_target(delta)
	right_fatigue_ui.fatigue = fatigue_manager.right_hand_fatigue
	
	goal_checker.check_goal_condition(delta)
	if hand_controller.is_grabbing_something:
		body.freeze = true
	else:
		body.freeze = false
	
	if hand_controller.grabbed_hold_left == null:
		ik_solver.solve_ik(
			left_shoulder,
			config.LEFT_UPPER_ARM_LEN,
			left_elbow,
			config.LEFT_FORE_ARM_LEN,
			left_hand_target.global_position,
			1.0
		)
	else:
		ik_solver.solve_reverse_ik(
			left_hand_target,
			left_shoulder,
			left_elbow,
			config.LEFT_ARM_MAX_LEN,
			config.LEFT_ARM_MIN_LEN,
			config.LEFT_UPPER_ARM_LEN,
			config.LEFT_FORE_ARM_LEN,
			1.0,
			delta
		)
		
	if hand_controller.grabbed_hold_right == null:
		ik_solver.solve_ik(
			right_shoulder,
			config.RIGHT_UPPER_ARM_LEN,
			right_elbow,
			config.RIGHT_FORE_ARM_LEN,
			right_hand_target.global_position,
			-1.0
		)
	else:
		ik_solver.solve_reverse_ik(
			right_hand_target,
			right_shoulder,
			right_elbow,
			config.RIGHT_ARM_MAX_LEN,
			config.RIGHT_ARM_MIN_LEN,
			config.RIGHT_UPPER_ARM_LEN,
			config.RIGHT_FORE_ARM_LEN,
			-1.0,
			delta
		)




func update_hand_target(delta):
	#var target_vel := Vector2.ZERO
	var left_dir = Vector2(
		Input.get_action_strength("LeftRight") - Input.get_action_strength("LeftLeft"),
		Input.get_action_strength("LeftDown")  - Input.get_action_strength("LeftUp")
	)
	var right_dir = Vector2(
		Input.get_action_strength("RightRight") - Input.get_action_strength("RightLeft"),
		Input.get_action_strength("RightDown")  - Input.get_action_strength("RightUp")
	)
	if left_dir.length() > 0:
		left_dir = left_dir.normalized()
		left_hand_velocity += left_dir * config.HAND_ACCEL * delta
	else:
		left_hand_velocity = left_hand_velocity.move_toward(Vector2.ZERO, config.HAND_DECEL * delta)

	left_hand_velocity = left_hand_velocity.limit_length(config.HAND_MAX_SPEED)

	if right_dir.length() > 0:
		right_dir = right_dir.normalized()
		right_hand_velocity += right_dir * config.HAND_ACCEL * delta
	else:
		right_hand_velocity = right_hand_velocity.move_toward(Vector2.ZERO, config.HAND_DECEL * delta)

	right_hand_velocity = right_hand_velocity.limit_length(config.HAND_MAX_SPEED)
		
	if hand_controller.grabbed_hold_left != null:
		var force_dir: Vector2 = -left_dir
		apply_body_from_hand(force_dir, delta)
	else:
		#left_hand_target.global_position += left_dir * config.HAND_SPEED * delta
		left_hand_target.global_position += left_hand_velocity * delta
		left_hand_target.global_position = ik_solver.clamp_to_circle(
			left_shoulder.global_position,
			left_hand_target.global_position,
			config.LEFT_ARM_MAX_LEN
		)
	
	if hand_controller.grabbed_hold_right != null:
		var force_dir: Vector2 = -right_dir
		apply_body_from_hand(force_dir, delta)
	#print("left:", left_hand_target.global_position)
	#print("right:", right_hand_target.global_position)
	else:
		#right_hand_target.global_position += right_dir * config.HAND_SPEED * delta
		right_hand_target.global_position += right_hand_velocity * delta
		right_hand_target.global_position = ik_solver.clamp_to_circle(
			right_shoulder.global_position,
			right_hand_target.global_position,
			config.RIGHT_ARM_MAX_LEN
		)
	
# IK functions moved to IKSolver

func apply_body_from_hand(input: Vector2, delta: float) -> void:
	if input == Vector2.ZERO:
		return
	
	var force = Vector2(input.x, input.y)
	force.y *= 1.2
	body.global_position += force * 140.0 * delta


# goal management is now handled by GoalChecker

func apply_hold_movement() -> void:
	var total_movement = Vector2.ZERO
	var hold_count: int = 0
	
	# 左手が掴んでるホールドの移動
	if hand_controller.grabbed_hold_left != null:
		var left_hold = hand_controller.grabbed_hold_left.get_parent() as HoldBehavior
		var movement = left_hold.get_movement_delta()
		#left_hand_target.global_position += movement
		total_movement += movement
		left_hold.previous_position += movement
		hold_count += 1
	
	# 右手が掴んでるホールドの移動
	if hand_controller.grabbed_hold_right != null:
		var right_hold = hand_controller.grabbed_hold_right.get_parent() as HoldBehavior
		var movement = right_hold.get_movement_delta()
		#right_hand_target.global_position += movement
		total_movement += movement
		right_hold.previous_position += movement
		hold_count += 1

	if hold_count > 0:
		var average_movement = total_movement / hold_count
		body.global_position += average_movement
	
