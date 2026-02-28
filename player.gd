## プレイヤー管理
## 
## プレイヤーの全体管理の中核ノード。
## 各種マネージャークラス（HandController、IKSolver、
## FatigueManager、GoalChecker、LungeController）を一体管理し、
## 每フレームの処理を調整する。
extends Node2D

## ハンドコントローラー（掴み及びリリース管理）
const HandController = preload("res://HandController.gd")
## IKソルバー（腕の角度計算）
const IKSolver = preload("res://IKSolver.gd")
## 疲労管理
const FatigueManager = preload("res://FatigueManager.gd")
## ゴールチェッカー（クリア文判定及びUI揺示）
const GoalChecker = preload("res://GoalChecker.gd")
## ランジとていて下ちなど）
const LungeController = preload("res://LungeController.gd")

## ハンドコントローラーインスタンス
var hand_controller: HandController = null
## IKソルバーインスタンス
var ik_solver: IKSolver = null
## 疲労管理インスタンス
var fatigue_manager: FatigueManager = null
## ゴールチェッカーインスタンス
var goal_checker: GoalChecker = null
## ランジコントローラーインスタンス
var lunge_controller: LungeController = null

## 左手のターゲット位置への速度度
var left_hand_velocity: Vector2 = Vector2.ZERO
## 右手のターゲット位置への速度度
var right_hand_velocity: Vector2 = Vector2.ZERO

## プレイヤー設定
@export var config: PlayerConfig

## プレイヤーボディ
@onready var body = $Body

## 左肩
@onready var left_shoulder =  $Body/LeftShoulder
## 左肘
@onready var left_elbow = $Body/LeftShoulder/LeftUpperArm/LeftElbow
## 左上腕
@onready var left_upper_arm = $Body/LeftShoulder/LeftUpperArm
## 左前腕
@onready var left_fore_arm = $Body/LeftShoulder/LeftUpperArm/LeftElbow/LeftForeArm
## 左手
@onready var left_hand = $Body/LeftShoulder/LeftUpperArm/LeftElbow/LeftForeArm/LeftHand
## 左手のターゲット位置（IKターゲット）
@onready var left_hand_target = $LeftHandTarget
## 左手の疲労度表示UI
@onready var left_fatigue_ui = $Body/LeftFatigueUI

## 右肩
@onready var right_shoulder = $Body/RightShoulder
## 右肘
@onready var right_elbow = $Body/RightShoulder/RightUpperArm/RightElbow
## 右上腕
@onready var right_upper_arm = $Body/RightShoulder/RightUpperArm
## 右前腕
@onready var right_fore_arm = $Body/RightShoulder/RightUpperArm/RightElbow/RightForeArm
## 右手
@onready var right_hand = $Body/RightShoulder/RightUpperArm/RightElbow/RightForeArm/RightHand
## 右手のターゲット位置（IKターゲット）
@onready var right_hand_target = $RightHandTarget
## 右手の疲労度表示UI
@onready var right_fatigue_ui = $Body/RightFatigueUI

## ゴール設定Label
@onready var goal_label = $CanvasLayer/GoalLabel

## ゲームを初期化
## [br][br]
## 設定を設定し、各種マネージャークラスを生成し毎々に必要な参照を渡す。
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
	hand_controller.body = body
	hand_controller.config = config

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
	# HandControllerに FatigueManager の参照を設定
	hand_controller.fatigue_manager = fatigue_manager
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

	# LungeController を生成して参照ノードをセット
	lunge_controller = LungeController.new()
	add_child(lunge_controller)
	lunge_controller.config = config
	lunge_controller.hand_controller = hand_controller
	lunge_controller.body = body
	lunge_controller.left_shoulder = left_shoulder
	lunge_controller.right_shoulder = right_shoulder
	lunge_controller.left_hand = left_hand
	lunge_controller.right_hand = right_hand
	
	# ランジチャージシグナルに接続
	lunge_controller.lunge_charge_updated.connect(_on_lunge_charge_updated)
	lunge_controller.lunge_charge_reset.connect(_on_lunge_charge_reset)

# Called every frame. 'delta' is the elapsed time since the previous frame.
## 毎フレーム処理
## [br][br]
## 入力を受けつけ整常、疲労を計算し、IKを描画し、ゴールを判定し、
## ホールドの移動を使用してプレイヤーが介入。
## [br][br]
## [param delta] フレーム時間
func _process(delta: float) -> void:

	if Input.is_action_pressed("LeftHold"):
		hand_controller.try_grab(left_hand, true)
	
	if Input.is_action_pressed("RightHold"):
		hand_controller.try_grab(right_hand, false)
		
	if Input.is_action_just_released("LeftHold"):
		hand_controller.release_left_grab()

	if Input.is_action_just_released("RightHold"):
		hand_controller.release_right_grab()

	apply_hold_movement()
	
	hand_controller.update(delta)
	fatigue_manager.update(delta)
	left_fatigue_ui.fatigue = fatigue_manager.left_hand_fatigue
	update_hand_target(delta)
	right_fatigue_ui.fatigue = fatigue_manager.right_hand_fatigue
	
	lunge_controller.update(delta)
	
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




## 手のターゲット位置を更新
## [br][br]
## 入力に応じて左右の手のターゲット位置を移動させる。
## ホールド掴み時は肩がターゲット位置に到達せず固定される。
## ハンドの可動範囲制限を満たすようにクランプされる。
## [br][br]
## [param delta] フレーム時間
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

## 手からの力を使用してボディを移動
## [br][br]
## ホールド掴み時に、入力により手に加わった力をプレイヤーボディに反映させ、
## プレイヤーを引っ張り上げたり移動させたりする。
## [br][br]
## [param input] 入力方向（通常-left_dir、-right_dirで逆方向）
## [param delta] フレーム時間
func apply_body_from_hand(input: Vector2, delta: float) -> void:
	if input == Vector2.ZERO:
		return
	
	var force = Vector2(input.x, input.y)
	force.y *= 1.2
	body.global_position += force * 140.0 * delta


# goal management is now handled by GoalChecker

## 掴んでいるホールドの移動をプレイヤーに適用
## [br][br]
## 両手が掴んでいるホールドの移動量を平均化し、プレイヤーボディにそれを反映させる。
## 動くホールドや落下するホールドを表現するのに使用される。
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
	

## ランジチャージ進捗が更新された時のコールバック
## [br][br]
## チャージ進捗に応じてボディのグロー効果を更新。
## 色は黄色→オレンジ→赤に段階的に変化し、
## MIN_CHARGE_TIME以上で点滅が始まり、進むにつれて加速する。
## [br][br]
## [param progress] チャージ進捗（0～1）
func _on_lunge_charge_updated(progress: float) -> void:
	var body_rect = body.get_node("ColorRect") as ColorRect
	if body_rect == null:
		return
	
	# チャージ進捗をMIN_CHARGETIMEからMAX_CHARGETIMEで正規化
	# MIN_CHARGE_TIME以前は0、MAX_CHARGE_TIME以降は1になる
	var min_time_ratio = lunge_controller.input_charge_time / config.LUNGE_MIN_CHARGE_TIME
	var max_time_ratio = (lunge_controller.input_charge_time - config.LUNGE_MIN_CHARGE_TIME) / (config.LUNGE_MAX_CHARGE_TIME - config.LUNGE_MIN_CHARGE_TIME)
	var normalized_charge = clamp(max_time_ratio, 0.0, 1.0)
	
	# 色を段階的に変化させる：黄色(1,1,0.5) → オレンジ(1,0.6,0) → 赤(1,0,0)
	var color: Color
	if normalized_charge < 0.5:
		# 黄色 → オレンジ
		var t = normalized_charge * 2.0
		color = Color(1.0, 1.0 - t * 0.4, 0.5 - t * 0.5, 1.0)
	else:
		# オレンジ → 赤
		var t = (normalized_charge - 0.5) * 2.0
		color = Color(1.0, 0.6 - t * 0.6, 0.0, 1.0)
	
	# MIN_CHARGE_TIME以上で点滅を開始
	if lunge_controller.input_charge_time >= config.LUNGE_MIN_CHARGE_TIME:
		# 点滅速度：MIN_CHARGE_TIMEで遅く、MAX_CHARGE_TIMEで速くなる
		var pulse_speed = 5.0 + normalized_charge * 15.0  # 5～20
		var pulse = sin(Time.get_ticks_msec() * 0.001 * pulse_speed) * 0.3 + 0.7
		color.v *= pulse
	
	body_rect.self_modulate = color

## ランジチャージがリセットされた時のコールバック
## [br][br]
## グロー効果をリセットして通常状態に戻す。
func _on_lunge_charge_reset() -> void:
	var body_rect = body.get_node("ColorRect") as ColorRect
	if body_rect == null:
		return
	
	body_rect.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
