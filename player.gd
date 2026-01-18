extends Node2D

@export var HAND_SPEED: float = 150.0
@export var ANGLE_SPEED: float = 3.0
@export var RADIAL_SPEED: float = 150.0
@export var LEFT_UPPER_ARM_LEN: float = 32.0
@export var LEFT_FORE_ARM_LEN: float = 26.0
@export var RIGHT_UPPER_ARM_LEN: float = 32.0
@export var RIGHT_FORE_ARM_LEN: float = 26.0
@export var SHOULDER_MIN = deg_to_rad(-120)
@export var SHOULDER_MAX = deg_to_rad(120)
@export var ELBOW_MIN = deg_to_rad(10)
@export var ELBOW_MAX = deg_to_rad(150)
var LEFT_ARM_MAX_LEN := LEFT_UPPER_ARM_LEN + LEFT_FORE_ARM_LEN - 1.0
var LEFT_ARM_MIN_LEN := 10.0
var RIGHT_ARM_MAX_LEN := RIGHT_UPPER_ARM_LEN + RIGHT_FORE_ARM_LEN - 1.0
var RIGHT_ARM_MIN_LEN := 10.0
var JOINT_SOFTNESS := 0.1

var grabbed_hold_left: Area2D = null
var grabbed_hold_right: Area2D = null
var is_grabbing_something: bool = false
var left_pin_joint: PinJoint2D = null
var right_pin_joint: PinJoint2D = null

@onready var body = $Body
@onready var left_shoulder =  $Body/LeftShoulder
@onready var left_elbow = $Body/LeftShoulder/LeftUpperArm/LeftElbow
@onready var left_upper_arm = $Body/LeftShoulder/LeftUpperArm
@onready var left_fore_arm = $Body/LeftShoulder/LeftUpperArm/LeftElbow/LeftForeArm
@onready var left_hand = $Body/LeftShoulder/LeftUpperArm/LeftElbow/LeftForeArm/LeftHand
@onready var left_hand_target = $LeftHandTarget

@onready var right_shoulder = $Body/RightShoulder
@onready var right_elbow = $Body/RightShoulder/RightUpperArm/RightElbow
@onready var right_upper_arm = $Body/RightShoulder/RightUpperArm
@onready var right_fore_arm = $Body/RightShoulder/RightUpperArm/RightElbow/RightForeArm
@onready var right_hand = $Body/RightShoulder/RightUpperArm/RightElbow/RightForeArm/RightHand
@onready var right_hand_target = $RightHandTarget

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("LeftHold"):
		try_grab(left_hand, true)
	
	if Input.is_action_pressed("RightHold"):
		try_grab(right_hand, false)
		
	if Input.is_action_just_released("LeftHold"):
		release_left_grab()

	if Input.is_action_just_released("RightHold"):
		release_right_grab()

	update_hand_target(delta)
	if grabbed_hold_left != null or grabbed_hold_right != null:
		body.freeze = true
	else:
		body.freeze = false
	
	if grabbed_hold_left == null:
		solve_ik(left_shoulder, LEFT_UPPER_ARM_LEN, left_elbow, LEFT_FORE_ARM_LEN,left_hand_target.global_position, 1.0)
	else:
		solve_reverse_ik(left_hand_target, left_shoulder, left_elbow, LEFT_ARM_MAX_LEN, LEFT_ARM_MIN_LEN, LEFT_UPPER_ARM_LEN, LEFT_FORE_ARM_LEN, 1.0, delta)
		
	if grabbed_hold_right == null:
		solve_ik(right_shoulder, RIGHT_UPPER_ARM_LEN, right_elbow, RIGHT_FORE_ARM_LEN, right_hand_target.global_position, -1.0)
	else:
		solve_reverse_ik(right_hand_target, right_shoulder, right_elbow, RIGHT_ARM_MAX_LEN, RIGHT_ARM_MIN_LEN, RIGHT_UPPER_ARM_LEN, RIGHT_FORE_ARM_LEN, -1.0, delta)


		


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

	if right_dir.length() > 0:
		right_dir = right_dir.normalized()

		
	if grabbed_hold_left != null:
		var force_dir: Vector2 = -left_dir
		apply_body_from_hand(force_dir, delta, left_hand)
	else:
		left_hand_target.global_position += left_dir * HAND_SPEED * delta

	
	if grabbed_hold_right != null:
		var force_dir: Vector2 = -right_dir
		apply_body_from_hand(force_dir, delta, right_hand)
	#print("left:", left_hand_target.global_position)
	#print("right:", right_hand_target.global_position)
	else:
		right_hand_target.global_position += right_dir * HAND_SPEED * delta



func calcurate_position(
	hand: Node2D,
	shoulder_pos: Vector2,
	arm_max_len: float,
	input_dir: Vector2,
	delta: float
) -> Vector2:
	var v: Vector2 = hand.global_position - shoulder_pos
	var dist = (hand.global_position - shoulder_pos).length()
	var angle_gain = clamp(dist / arm_max_len, 0.3, 1.0)
	var angle: float = v.angle()
	angle += input_dir.x * ANGLE_SPEED * angle_gain * delta
	var radius: float = dist 
	radius += input_dir.y * RADIAL_SPEED * delta
	return shoulder_pos + Vector2.from_angle(angle) * radius
	
	
func clamp_target_distance(
	shoulder_pos: Vector2,
	target_pos: Vector2,
	ARM_MAX_LEN: float,
	ARM_MIN_LEN: float
) -> Vector2:
	var v := target_pos - shoulder_pos
	var d := v.length()
	
	d = clamp(d, ARM_MIN_LEN, ARM_MAX_LEN)
	return shoulder_pos + v.normalized() * d



func solve_ik(
	shoulder: Node2D,
	upper_len: float,
	elbow: Node2D,
	fore_len: float,
	hand_target: Vector2,
	sign: float,
) -> void:
	# === positions ===
	var shoulder_pos: Vector2 = shoulder.global_position
	var target_pos: Vector2 = hand_target

	# === distance shoulder -> target ===
	var shoulder_to_target: Vector2 = target_pos - shoulder_pos
	var target_dist: float = shoulder_to_target.length()
	target_dist = clamp(
		target_dist,
		1.0,
		upper_len + fore_len - 0.1
	)
	
	var max_reach = upper_len + fore_len
	if target_dist >= max_reach - 0.5:
		elbow.rotation = 0
		shoulder.global_rotation = shoulder_to_target.angle()
		return

	# === angles (law of cosines) ===
	# elbow interior angle
	var elbow_angle: float = acos(
		(upper_len * upper_len + fore_len * fore_len - target_dist * target_dist)
		/ (2.0 * upper_len * fore_len)
	)
	var elbow_bend:= PI - elbow_angle
	#elbow_bend = clamp(elbow_bend, ELBOW_MIN, ELBOW_MAX)
	var target_elbow_rotation = sign * elbow_bend
	elbow.rotation = lerp_angle(elbow.rotation, target_elbow_rotation, 0.2)

	# shoulder angle
	var shoulder_direction: float = shoulder_to_target.angle()
	var shoulder_angle: float = acos(
		(upper_len * upper_len + target_dist * target_dist - fore_len * fore_len)
		/ (2.0 * upper_len * target_dist)
	)
	#var desired_local_angle = shoulder_direction - shoulder.global_rotation + shoulder.rotation
	var target_shoulder_rotation = shoulder_direction - shoulder_angle * sign
	shoulder.global_rotation = lerp_angle(shoulder.global_rotation, target_shoulder_rotation, 0.2)
	#var parent_global := shoulder.get_parent().global_rotation
	#var desired_local := desired_global - parent_global	
	#desired_local_angle = clamp(desired_local_angle, SHOULDER_MIN, SHOULDER_MAX)
	#shoulder.rotation = desired_local_angle
		
	#print(shoulder.global_rotation)
	#print(elbow.rotation)

func try_grab(hand: Area2D, isLeft: bool):
	var areas = hand.get_overlapping_areas()
	for a in areas:
		if not a.is_in_group("hold"):
			continue

		if isLeft:
			grabbed_hold_left = a
			left_hand_target.global_position = a.global_position
			left_pin_joint = create_pin_joint(a)
		else:
			grabbed_hold_right = a
			right_hand_target.global_position = a.global_position
			right_pin_joint = create_pin_joint(a)
		
		update_grab_state()

func create_pin_joint(hold: Area2D) -> PinJoint2D:
	var joint = PinJoint2D.new()
	add_child(joint)
	
	joint.node_a = body.get_path()
	joint.node_b = hold.get_path()
	joint.global_position = hold.global_position
	joint.softness = JOINT_SOFTNESS
	return joint

func update_grab_state() -> void:
	is_grabbing_something = (grabbed_hold_left != null or grabbed_hold_right != null)

func release_left_grab() -> void:
	grabbed_hold_left = null
	left_hand_target.global_position = left_hand.global_position
	if left_pin_joint != null:
		left_pin_joint.queue_free()
		left_pin_joint = null
		
	update_grab_state()

func release_right_grab() -> void:
	grabbed_hold_right = null
	right_hand_target.global_position = right_hand.global_position
	if right_pin_joint != null:
		right_pin_joint.queue_free()
		right_pin_joint = null
		
	update_grab_state()

func apply_body_from_hand(input: Vector2, delta: float, hand: Node2D) -> void:
	if input == Vector2.ZERO:
		return
	
	var force = Vector2(input.x, input.y)
	force.y *= 1.2
	body.global_position += force * 140.0 * delta	

func solve_reverse_ik(
	hand_target: Node2D,
	shoulder: Node2D,
	elbow: Node2D,
	arm_max_len: float,
	arm_min_len: float,
	upper_len: float,
	fore_len: float,
	sign: float,
	delta: float
) -> void:
	# 手の位置は固定
	var hand_pos = hand_target.global_position
	
	# 現在の肩の位置
	var current_shoulder_pos = shoulder.global_position

	# プレイヤーの入力から「理想の肩の位置」を計算
	var input_dir: Vector2
	if sign > 0.0:
		input_dir = Vector2(
			Input.get_action_strength("LeftRight") - Input.get_action_strength("LeftLeft"),
			Input.get_action_strength("LeftDown") - Input.get_action_strength("LeftUp")
		)
	else:
		input_dir = Vector2(
			Input.get_action_strength("RightRight") - Input.get_action_strength("RightLeft"),
			Input.get_action_strength("RightDown") - Input.get_action_strength("RightUp")
		)			
	
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
	
	# 理想の肩の位置 = 現在位置 + 入力方向
	var desired_shoulder_pos = current_shoulder_pos + input_dir * 100.0 * delta
	
	# 腕の長さ制約を満たすように肩の位置をクランプ
	var hand_to_shoulder = desired_shoulder_pos - hand_pos
	var dist = hand_to_shoulder.length()
	
	# 肩は手から腕の長さ(max)以内にいなければならない
	if dist > arm_max_len:
		desired_shoulder_pos = hand_pos + hand_to_shoulder.normalized() * arm_max_len
	elif dist < arm_min_len:
		desired_shoulder_pos = hand_pos + hand_to_shoulder.normalized() * arm_min_len
	
	# Bodyの位置を更新(肩はBodyの子なので、Bodyを動かす)
	var shoulder_offset = shoulder.position  # Bodyからの相対位置
	var new_body_pos = desired_shoulder_pos - shoulder_offset.rotated(body.rotation)
	body.global_position = new_body_pos
	
	# 通常のIKで腕の角度を解決
	solve_ik(shoulder, upper_len, elbow, fore_len, hand_pos, sign)
