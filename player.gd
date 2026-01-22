extends Node2D

# つかみ関係
var grabbed_hold_left: Area2D = null
var grabbed_hold_right: Area2D = null
var is_grabbing_something: bool = false

# 疲労関係
var left_hand_fatigue: float = 0.0
var right_hand_fatigue: float = 0.0

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
var last_display_score := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	config = PlayerConfig.new()
	goal_label.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if Input.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()
	if Input.is_action_pressed("LeftHold"):
		try_grab(left_hand, true)
	
	if Input.is_action_pressed("RightHold"):
		try_grab(right_hand, false)
		
	if Input.is_action_just_released("LeftHold"):
		release_left_grab()

	if Input.is_action_just_released("RightHold"):
		release_right_grab()

	update_fatigue(delta)
	left_fatigue_ui.fatigue = left_hand_fatigue
	update_hand_target(delta)
	right_fatigue_ui.fatigue = right_hand_fatigue
	
	check_goal_condition(delta)
	
	if is_grabbing_something:
		body.freeze = true
	else:
		body.freeze = false
	
	if grabbed_hold_left == null:
		solve_ik(
			left_shoulder,
			config.LEFT_UPPER_ARM_LEN,
			left_elbow,
			config.LEFT_FORE_ARM_LEN,
			left_hand_target.global_position,
			1.0
		)
	else:
		solve_reverse_ik(
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
		
	if grabbed_hold_right == null:
		solve_ik(
			right_shoulder,
			config.RIGHT_UPPER_ARM_LEN,
			right_elbow,
			config.RIGHT_FORE_ARM_LEN,
			right_hand_target.global_position,
			-1.0
		)
	else:
		solve_reverse_ik(
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
		
	if grabbed_hold_left != null:
		var force_dir: Vector2 = -left_dir
		apply_body_from_hand(force_dir, delta)
	else:
		#left_hand_target.global_position += left_dir * config.HAND_SPEED * delta
		left_hand_target.global_position += left_hand_velocity * delta
		left_hand_target.global_position = clamp_to_circle(
			left_shoulder.global_position,
			left_hand_target.global_position,
			config.LEFT_ARM_MAX_LEN
		)
	
	if grabbed_hold_right != null:
		var force_dir: Vector2 = -right_dir
		apply_body_from_hand(force_dir, delta)
	#print("left:", left_hand_target.global_position)
	#print("right:", right_hand_target.global_position)
	else:
		#right_hand_target.global_position += right_dir * config.HAND_SPEED * delta
		right_hand_target.global_position += right_hand_velocity * delta
		right_hand_target.global_position = clamp_to_circle(
			right_shoulder.global_position,
			right_hand_target.global_position,
			config.RIGHT_ARM_MAX_LEN
		)
	
func clamp_to_circle(
	center: Vector2,
	pos: Vector2,
	max_radius: float
) -> Vector2:
	var v := pos - center
	var d := v.length()

	if d > max_radius:
		return center + v.normalized() * max_radius

	return pos


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
	elbow.rotation = lerp_angle(elbow.rotation, target_elbow_rotation, config.SMOOTHNESS)

	# shoulder angle
	var shoulder_direction: float = shoulder_to_target.angle()
	var shoulder_angle: float = acos(
		(upper_len * upper_len + target_dist * target_dist - fore_len * fore_len)
		/ (2.0 * upper_len * target_dist)
	)
	#var desired_local_angle = shoulder_direction - shoulder.global_rotation + shoulder.rotation
	var target_shoulder_rotation = shoulder_direction - shoulder_angle * sign
	shoulder.global_rotation = lerp_angle(shoulder.global_rotation, target_shoulder_rotation, config.SMOOTHNESS)
	#var parent_global := shoulder.get_parent().global_rotation
	#var desired_local := desired_global - parent_global	
	#desired_local_angle = clamp(desired_local_angle, SHOULDER_MIN, SHOULDER_MAX)
	#shoulder.rotation = desired_local_angle
		
	#print(shoulder.global_rotation)
	#print(elbow.rotation)
func apply_body_from_hand(input: Vector2, delta: float) -> void:
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


func try_grab(hand: Area2D, isLeft: bool):
	var areas = hand.get_overlapping_areas()
	for a in areas:
		if not a.is_in_group("hold"):
			continue

		var hold = a.get_parent() as HoldBehavior
		if isLeft:
			grabbed_hold_left = a
			left_hand_target.global_position = a.global_position
			hold.grabbed_by_left = true
		else:
			grabbed_hold_right = a
			right_hand_target.global_position = a.global_position
			hold.grabbed_by_right = true
		
		update_grab_state()

func update_grab_state() -> void:
	is_grabbing_something = (grabbed_hold_left != null or grabbed_hold_right != null)

func release_left_grab() -> void:
	if grabbed_hold_left != null:
		var hold = grabbed_hold_left.get_parent() as HoldBehavior
		if hold != null:
			hold.grabbed_by_left = false
	
	grabbed_hold_left = null
	left_hand_target.global_position = left_hand.global_position
	
	update_grab_state()

func release_right_grab() -> void:
	if grabbed_hold_right != null:
		var hold = grabbed_hold_right.get_parent() as HoldBehavior
		if hold != null:
			hold.grabbed_by_right = false

	grabbed_hold_right = null
	right_hand_target.global_position = right_hand.global_position
	
	update_grab_state()


func update_fatigue(delta: float) -> void:
	# 左手の疲労度
	if grabbed_hold_left != null:
		# 肘の角度を取得(絶対値)
		var elbow_angle = abs(left_elbow.rotation)
		
		# 疲労速度を計算
		var fatigue_rate: float
		if elbow_angle > config.BENT_ARM_THRESHOLD:
			fatigue_rate = config.FATIGUE_RATE_BENT_ARM
		else:
			fatigue_rate = config.FATIGUE_RATE_OPEN_HAND

		
		# 体が腕より高かったらより倍率上げる
		if left_shoulder.global_position.y < left_hand.global_position.y:
			var height_diff = clamp(
				(left_shoulder.global_position.y - left_hand.global_position.y) / config.HEIGHT_DIFF_MAX,
				0.0,
				1.0
			)
			
			fatigue_rate += lerp(1.0, config.FATIGUE_RATE_BODY_ABOVE, height_diff) - 1.0

		# 両手なら少し楽になる
		if grabbed_hold_right != null:
			fatigue_rate *= config.FATIGUE_BOTH_HANDS_REDUCE_RATE
		
		# 疲労度を増加
		left_hand_fatigue += fatigue_rate * delta
		left_hand_fatigue = min(left_hand_fatigue, config.MAX_FATIGUE)
		
		# パンプしたら自動で離れる
		if left_hand_fatigue >= config.MAX_FATIGUE:
			release_left_grab()
	else:
		# レスト中は回復
		left_hand_fatigue -= config.FATIGUE_RECOVERY_RATE * delta
		left_hand_fatigue = max(left_hand_fatigue, 0.0)
	
	# 右手の疲労度
	if grabbed_hold_right != null:
		var elbow_angle = abs(right_elbow.rotation)
		
		var fatigue_rate: float
		if elbow_angle > config.BENT_ARM_THRESHOLD:
			fatigue_rate = config.FATIGUE_RATE_BENT_ARM
		else:
			fatigue_rate = config.FATIGUE_RATE_OPEN_HAND

		# 体が腕より高かったらより倍率あげる
		if right_shoulder.global_position.y < right_hand.global_position.y:
			var height_diff = clamp(
				(right_shoulder.global_position.y - right_hand.global_position.y) / config.HEIGHT_DIFF_MAX,
				0.0,
				1.0
			)
			
			fatigue_rate *= lerp(1.0, config.FATIGUE_RATE_BODY_ABOVE, height_diff)

		# 両手なら少し楽になる
		if grabbed_hold_left != null:
			fatigue_rate *= config.FATIGUE_BOTH_HANDS_REDUCE_RATE

		
		right_hand_fatigue += fatigue_rate * delta
		right_hand_fatigue = min(right_hand_fatigue, config.MAX_FATIGUE)
		
		if right_hand_fatigue >= config.MAX_FATIGUE:
			release_right_grab()
	else:
		right_hand_fatigue -= config.FATIGUE_RECOVERY_RATE * delta
		right_hand_fatigue = max(right_hand_fatigue, 0.0)

func check_goal_condition(delta: float) -> void:
	if grabbed_hold_left != null and grabbed_hold_right != null:
		# 両方のホールドが「GOAL」タイプかチェック
		var hold_l = grabbed_hold_left.get_parent() as HoldBehavior
		var hold_r = grabbed_hold_right.get_parent() as HoldBehavior
		
		# 両手GOALの場合
		if ((hold_l.hold_data.type == HoldData.HoldType.GOAL and 
			hold_r.hold_data.type == HoldData.HoldType.GOAL) or 
			(hold_l.hold_data.type == HoldData.HoldType.GOAL_LEFT and 
			hold_r.hold_data.type == HoldData.HoldType.GOAL_RIGHT)):
			update_goal_ui(min(hold_l.grabbed_goal_time, hold_r.grabbed_goal_time))
			if (hold_l.grabbed_goal_time >= config.GOAL_FREEZE_TIME and
				hold_r.grabbed_goal_time >= config.GOAL_FREEZE_TIME):
				victory()
	else:
		update_goal_ui(0.0)	

func update_goal_ui(elapsed_time: float) -> void:
	var current_score = int(ceil(elapsed_time))
	if elapsed_time <= 0.0:
		goal_label.text = ""
		last_display_score = -1
	elif elapsed_time < config.GOAL_FREEZE_TIME and current_score != last_display_score:
		last_display_score = current_score
		goal_label.text = str(current_score)
		goal_label.modulate = Color.WHITE
		
		var tween = create_tween()
		goal_label.scale = Vector2(1.5, 1.5)
		tween.tween_property(goal_label, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK)
	elif elapsed_time >= config.GOAL_FREEZE_TIME:
		goal_label.text = "Victory!"
		goal_label.modulate = Color.GOLD
			
func victory() -> void:
	print("victory!")			

			
		
		
