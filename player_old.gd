extends Node2D

const MOVE_SPEED: int = 100
const POWER: int = 2000
const DAMP: int = 10

@onready var left_tip = $Body/LeftShoulderJoint/LeftUpperArm/LeftElbowJoint/LeftForeArm/LeftTipTarget
@onready var right_tip = $Body/RightShoulderJoint/RightUpperArm/RightElbowJoint/RightForeArm/RightTipTarget
@onready var left_hand = $Body/LeftShoulderJoint/LeftUpperArm/LeftElbowJoint/LeftForeArm/LeftWrist/LeftHand
@onready var right_hand = $Body/RightShoulderJoint/RightUpperArm/RightElbowJoint/RightForeArm/RightWrist/RightHand

func _process(delta: float) -> void:
	pass
	#left_hand.linear_velocity += input_dir_left;
	#right_hand.linear_velocity += input_dir_right;
	#left_hand.apply_force(input_dir_left * POWER)
	#right_hand.apply_force(input_dir_right * POWER)

func _physics_process(delta: float) -> void:
	
	var input_dir_left := Vector2 (
		Input.get_action_strength("leftRight") - Input.get_action_strength("LeftLeft"),
		Input.get_action_strength("LeftDown") - Input.get_action_strength("LeftUp")
	)
	
	var input_dir_right := Vector2 (
		Input.get_action_strength("RightRight") - Input.get_action_strength("RightLeft"),
		Input.get_action_strength("RightDown") - Input.get_action_strength("RightUp")
	)

	if input_dir_left.length() > 0:
		input_dir_left = input_dir_left.normalized()
		
	if input_dir_right.length() > 0:
		input_dir_right = input_dir_right.normalized()
	
	left_tip.global_position += input_dir_left * MOVE_SPEED * delta
	right_tip.global_position += input_dir_right * MOVE_SPEED * delta

	
	var to_target_left = left_tip.global_position - left_hand.global_position	
	var to_target_right = right_tip.global_position - right_hand.global_position
	var dist_left = to_target_left.length()
	var dist_right = to_target_right.length()
	var dir_left = to_target_left.normalized()
	var dir_right = to_target_right.normalized()
	
	const MAX_LENGTH: int = 100
	if dist_left > MAX_LENGTH:
		dir_left = dir_left * MAX_LENGTH
		
	if dist_right > MAX_LENGTH:
		dir_right = dir_right.normalized() * MAX_LENGTH
	
	var strength_left = clamp(dist_left / 120.0, 0.0, 1.0)
	var strength_right = clamp(dist_right / 120.0, 0.0, 1.0)
	
	var left_force = dir_left * POWER * strength_left - left_hand.linear_velocity * DAMP
	var right_force = dir_right * POWER * strength_right - right_hand.linear_velocity * DAMP	
	left_hand.apply_force(left_force)
	right_hand.apply_force(right_force)
