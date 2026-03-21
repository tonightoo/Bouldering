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
## ゴールチェッカー
const GoalChecker = preload("res://GoalChecker.gd")
## ランジコントローラ
const LungeController = preload("res://LungeController.gd")
## オブザベーションコントローラ
const ObservationController = preload("res://ObservationController.gd")

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
## オブザベーションコントローラーインスタンス
var observation_controller: ObservationController = null
## 左手のターゲット位置への速度度
var left_hand_velocity: Vector2 = Vector2.ZERO
## 右手のターゲット位置への速度度
var right_hand_velocity: Vector2 = Vector2.ZERO

## プレイヤー設定
@export var config: PlayerConfig

## プレイヤーの現在ステータス
@export var status: PlayerStatus

## オブザベーションが必要かどうか
@export var is_need_observation: bool = false

## プレイヤーボディ
@onready var body = $Body

## 左肩
@onready var left_shoulder =  $Body/LeftShoulder
## 左肘
@onready var left_elbow = $Body/LeftShoulder/LeftUpperArm/LeftElbow
## 左上腕
@onready var left_upper_arm = $Body/LeftShoulder/LeftUpperArm
## 左上腕のスプライト
@onready var left_upper_arm_sprite = $Body/LeftShoulder/LeftUpperArm/VisualSprite
## 左前腕
@onready var left_fore_arm = $Body/LeftShoulder/LeftUpperArm/LeftElbow/LeftForeArm
## 左前腕のスプライト
@onready var left_fore_arm_sprite = $Body/LeftShoulder/LeftUpperArm/LeftElbow/LeftForeArm/VisualSprite
## 左手
@onready var left_hand = $Body/LeftShoulder/LeftUpperArm/LeftElbow/LeftForeArm/LeftHand
## 左手のターゲット位置（IKターゲット）
@onready var left_hand_target = $LeftHandTarget
## 左手の疲労度表示UI
@onready var left_fatigue_ui = $Body/LeftFatigueUI
## 左手の表示スプライト
@onready var left_hand_sprite = $Body/LeftShoulder/LeftUpperArm/LeftElbow/LeftForeArm/LeftHand/VisualSprite
## 左手のチョークパーティクル
@onready var left_chalk_particle = $Body/LeftShoulder/LeftUpperArm/LeftElbow/LeftForeArm/LeftHand/ChalkParticle
## 左手の腕の長さのリミット
var left_arm_length_limit: float

## 右肩
@onready var right_shoulder = $Body/RightShoulder
## 右肘
@onready var right_elbow = $Body/RightShoulder/RightUpperArm/RightElbow
## 右上腕
@onready var right_upper_arm = $Body/RightShoulder/RightUpperArm
## 右上腕のスプライト
@onready var right_upper_arm_sprite = $Body/RightShoulder/RightUpperArm/VisualSprite
## 右前腕
@onready var right_fore_arm = $Body/RightShoulder/RightUpperArm/RightElbow/RightForeArm
## 右前腕のスプライト
@onready var right_fore_arm_sprite = $Body/RightShoulder/RightUpperArm/RightElbow/RightForeArm/VisualSprite
## 右手
@onready var right_hand = $Body/RightShoulder/RightUpperArm/RightElbow/RightForeArm/RightHand
## 右手のターゲット位置（IKターゲット）
@onready var right_hand_target = $RightHandTarget
## 右手の疲労度表示UI
@onready var right_fatigue_ui = $Body/RightFatigueUI
## 右手の表示スプライト
@onready var right_hand_sprite = $Body/RightShoulder/RightUpperArm/RightElbow/RightForeArm/RightHand/VisualSprite
## 右手のチョークパーティクル
@onready var right_chalk_particle = $Body/RightShoulder/RightUpperArm/RightElbow/RightForeArm/RightHand/ChalkParticle
## 右手の腕の長さのリミット
var right_arm_length_limit: float

## 画面中央表示用ラベル
@onready var message_label = $CanvasLayer/CenterMessageLabel
## 画面右上表示用ラベル
@onready var topright_message_label = $CanvasLayer/TopRightMessageLabel

## カメラ
@onready var camera = $Body/Camera2D
## オブザベ中にかかる暗闇効果
@onready var dark_screen = $DarkScreen
## オブザベ中に使用する視界
@onready var spot_light = $ObservationVision

## 速度
var body_velocity: Vector2 = Vector2.ZERO
var last_body_velocity: Vector2 = Vector2.ZERO

## ゲームを初期化
## [br][br]
## 設定を設定し、各種マネージャークラスを生成し毎々に必要な参照を渡す。
func _ready() -> void:
	config = PlayerConfig.new()
	status = PlayerStatus.new(config)
	message_label.text = ""

	# 手のサイズ・位置をステータスに応じて変更
	left_upper_arm_sprite.scale.x = status.get_left_upper_arm_len() / left_upper_arm_sprite.texture.get_width()
	left_upper_arm_sprite.position.x = status.get_left_upper_arm_len() / 2
	left_elbow.position.x = status.get_left_upper_arm_len()
	left_fore_arm_sprite.scale.x = status.get_left_fore_arm_len() / left_fore_arm_sprite.texture.get_width()
	left_fore_arm_sprite.position.x = status.get_left_fore_arm_len() / 2 - status.get_left_elbow_overlap()
	var left_hand_sprite_half_width = left_hand_sprite.sprite_frames.get_frame_texture("open", 0).get_width() * left_hand_sprite.scale.x / 2
	left_hand.position.x = status.get_left_fore_arm_len() - status.get_left_elbow_overlap() + left_hand_sprite_half_width - status.get_left_hand_overlap()
	print(left_fore_arm_sprite.position, left_hand.position)

	right_upper_arm_sprite.scale.x = status.get_right_upper_arm_len() / right_upper_arm_sprite.texture.get_width()
	right_upper_arm_sprite.position.x = status.get_right_upper_arm_len() / 2
	right_elbow.position.x = status.get_right_upper_arm_len()
	right_fore_arm_sprite.scale.x = status.get_right_fore_arm_len() / right_fore_arm_sprite.texture.get_width()
	right_fore_arm_sprite.position.x = status.get_right_fore_arm_len() / 2 - status.get_right_elbow_overlap()
	var right_hand_sprite_half_width = right_hand_sprite.sprite_frames.get_frame_texture("open", 0).get_width() * right_hand_sprite.scale.x / 2
	right_hand.position.x = status.get_right_fore_arm_len() - status.get_right_elbow_overlap() + right_hand_sprite_half_width - status.get_right_hand_overlap()
	print(right_fore_arm_sprite.position, right_hand.position)

	# HandController を生成して参照ノードをセット
	hand_controller = HandController.new()
	add_child(hand_controller)
	hand_controller.left_hand_target = left_hand_target
	hand_controller.right_hand_target = right_hand_target
	hand_controller.left_hand = left_hand
	hand_controller.right_hand = right_hand
	hand_controller.body = body
	hand_controller.status = status
	hand_controller.grabbed.connect(grab_hand_sprite)
	hand_controller.grabbed.connect(unlighten)
	hand_controller.released.connect(open_hand_sprite)
	hand_controller.released.connect(lighten)

	# IKSolver を生成して参照ノードをセット
	ik_solver = IKSolver.new()
	add_child(ik_solver)
	ik_solver.status = status
	ik_solver.body = body

	# FatigueManager を生成して参照ノードをセット
	fatigue_manager = FatigueManager.new()
	add_child(fatigue_manager)
	fatigue_manager.status = status
	fatigue_manager.hand_controller = hand_controller
	# HandControllerに FatigueManager の参照を設定
	hand_controller.fatigue_manager = fatigue_manager
	fatigue_manager.left_elbow = left_elbow
	fatigue_manager.right_elbow = right_elbow
	fatigue_manager.left_shoulder = left_shoulder
	fatigue_manager.right_shoulder = right_shoulder
	fatigue_manager.left_hand = left_hand
	fatigue_manager.right_hand = right_hand
	
	# fatigue_uiにもステータスをセット
	left_fatigue_ui.status = status
	right_fatigue_ui.status = status

	# GoalChecker を生成して参照ノードをセット
	goal_checker = GoalChecker.new()
	add_child(goal_checker)
	goal_checker.status = status
	goal_checker.hand_controller = hand_controller
	goal_checker.goal_label = message_label

	# LungeController を生成して参照ノードをセット
	lunge_controller = LungeController.new()
	add_child(lunge_controller)
	lunge_controller.status = status
	lunge_controller.hand_controller = hand_controller
	lunge_controller.body = body
	lunge_controller.left_shoulder = left_shoulder
	lunge_controller.right_shoulder = right_shoulder
	lunge_controller.left_hand = left_hand
	lunge_controller.right_hand = right_hand
	
	# ランジチャージシグナルに接続
	lunge_controller.lunge_charge_updated.connect(_on_lunge_charge_updated)
	lunge_controller.lunge_charge_reset.connect(_on_lunge_charge_reset)
	
	# ObservationControllerを生成して参照ノードをセット
	observation_controller = ObservationController.new()
	add_child(observation_controller)
	observation_controller.status = status
	observation_controller.observation_time_remaining = status.get_observation_time_limit()
	observation_controller.camera = camera
	observation_controller.is_observation = is_need_observation
	observation_controller.darkness = dark_screen
	observation_controller.spotlight = spot_light
	observation_controller.message_label = topright_message_label

	if is_need_observation:
		observation_controller.enable_observation()
		
	left_arm_length_limit = status.get_left_arm_max_len()
	right_arm_length_limit = status.get_right_arm_max_len()

# Called every frame. 'delta' is the elapsed time since the previous frame.
## 毎フレーム処理
## [br][br]
## 入力を受けつけ整常、疲労を計算し、IKを描画し、ゴールを判定し、
## ホールドの移動を使用してプレイヤーが介入。
## [br][br]
## [param delta] フレーム時間
func _process(delta: float) -> void:
	if observation_controller.is_observation:
		return

	bouldering_process(delta)


func bouldering_process(delta: float) -> void:
	if Input.is_action_just_pressed("LeftHold"):
		hand_controller.try_grab(left_hand, true)
	
	if Input.is_action_just_pressed("RightHold"):
		hand_controller.try_grab(right_hand, false)

	if not Input.is_action_pressed("LeftHold") and hand_controller.grabbed_hold_left != null:
		hand_controller.release_left_grab()
		
	if not Input.is_action_pressed("RightHold") and hand_controller.grabbed_hold_right != null:
		hand_controller.release_right_grab()


	#if Input.is_action_just_released("LeftHold"):
		#hand_controller.release_left_grab()

	#if Input.is_action_just_released("RightHold"):
		#hand_controller.release_right_grab()

	# ホールドを掴んでいる場合、ボディの位置を左手・右手のホールドの移動に合わせて計算し適用する
	apply_hold_movement()

	# ホールドを掴んでいる場合、ホールドの位置に手を動かす
	hand_controller.update(delta)

	# 両手の疲労度を状況に応じて増加・回復
	fatigue_manager.update(delta)
	left_fatigue_ui.fatigue = fatigue_manager.left_hand_fatigue
	right_fatigue_ui.fatigue = fatigue_manager.right_hand_fatigue
	
	# ユーザーの入力に応じて手の位置・体の位置を更新
	update_hand_target(delta)
	# ランジの入力状態や発動条件を確認し実行
	lunge_controller.update(delta)

	
	goal_checker.check_goal_condition(delta)
	if hand_controller.is_grabbing_something:
		body.linear_velocity = Vector2.ZERO
	
	ik_solver.solve_ik(
		left_shoulder,
		status.get_left_upper_arm_len(),
		left_elbow,
		status.get_left_fore_arm_len() - status.get_left_elbow_overlap(),
		left_hand_target.global_position,
		1.0
	)
	if hand_controller.grabbed_hold_left != null:
		ik_solver.solve_reverse_ik(
			left_hand_target,
			left_shoulder,
			left_elbow,
			#config.LEFT_ARM_MAX_LEN,
			left_arm_length_limit,
			status.get_left_arm_min_len(),
			status.get_left_upper_arm_len(),
			status.get_left_fore_arm_len() - status.get_left_elbow_overlap(),
			1.0,
			delta
		)
		
	ik_solver.solve_ik(
		right_shoulder,
		status.get_right_upper_arm_len(),
		right_elbow,
		status.get_right_fore_arm_len() - status.get_right_elbow_overlap(),
		right_hand_target.global_position,
		-1.0
	)
	if hand_controller.grabbed_hold_right != null:
		ik_solver.solve_reverse_ik(
			right_hand_target,
			right_shoulder,
			right_elbow,
			#config.RIGHT_ARM_MAX_LEN,
			right_arm_length_limit,
			status.get_right_arm_min_len(),
			status.get_right_upper_arm_len(),
			status.get_right_fore_arm_len() - status.get_right_elbow_overlap(),
			-1.0,
			delta
		)	
	
	#recalcurate_body_velocity(last_body_position, delta)


## 手のターゲット位置を更新
## [br][br]
## 入力に応じて左右の手のターゲット位置を移動させる。
## ホールド掴み時は肩がターゲット位置に到達せず固定される。
## ハンドの可動範囲制限を満たすようにクランプされる。
## [br][br]
## [param delta] フレーム時間
func update_hand_target(delta):
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
		left_hand_velocity += left_dir * status.get_hand_accel() * delta
	else:
		left_hand_velocity = left_hand_velocity.move_toward(Vector2.ZERO, status.get_hand_decel() * delta)

	left_hand_velocity = left_hand_velocity.limit_length(status.get_hand_max_speed())

	if right_dir.length() > 0:
		right_dir = right_dir.normalized()		
		right_hand_velocity += right_dir * status.get_hand_accel() * delta
	else:
		right_hand_velocity = right_hand_velocity.move_toward(Vector2.ZERO, status.get_hand_decel() * delta)

	right_hand_velocity = right_hand_velocity.limit_length(status.get_hand_max_speed())
		
	if hand_controller.grabbed_hold_left != null:
		var force_dir: Vector2 = -left_dir
		apply_velocity(true, left_dir, delta)
		#apply_body_from_hand(Vector2(0.0, -left_dir.y), delta)
		apply_body_from_hand(force_dir, delta)
	else:
		#left_hand_target.global_position += left_dir * config.HAND_SPEED * delta
		left_hand_target.global_position += left_hand_velocity * delta
		left_hand_target.global_position = ik_solver.clamp_to_circle(
			left_shoulder.global_position,
			left_hand_target.global_position,
			status.get_left_arm_max_len()
		)
	
	if hand_controller.grabbed_hold_right != null:
		var force_dir: Vector2 = -right_dir
		apply_velocity(false, right_dir, delta)
		#apply_body_from_hand(Vector2(0.0, -right_dir.y), delta)
		apply_body_from_hand(force_dir, delta)
	#print("left:", left_hand_target.global_position)
	#print("right:", right_hand_target.global_position)
	else:
		#right_hand_target.global_position += right_dir * config.HAND_SPEED * delta
		right_hand_target.global_position += right_hand_velocity * delta
		right_hand_target.global_position = ik_solver.clamp_to_circle(
			right_shoulder.global_position,
			right_hand_target.global_position,
			status.get_right_arm_max_len()
		)
	
	apply_rotation_power(delta)
		

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
	#body.global_position += force * 140.0 * delta
	#var distance = force * status.get_lift_up_strength() * delta
	var distance = Vector2(force.x * status.get_keep_up_strength(), force.y * status.get_lift_up_strength()) * delta
	body.global_position += distance

## 速度計算
func apply_velocity(is_left: bool, input: Vector2, delta: float) -> void:
	var hand_pos: Vector2
	var elbow_pos: Vector2
	var shoulder_pos: Vector2
	if is_left:
		hand_pos = left_hand.global_position
		elbow_pos = left_elbow.global_position
		shoulder_pos = left_shoulder.global_position
	else:
		hand_pos = right_hand.global_position
		elbow_pos = right_elbow.global_position
		shoulder_pos = right_shoulder.global_position

	var lines = get_arm_direction_lines(hand_pos, elbow_pos)

	## 左右入力による振り子運動の計算
	#var pendulum_strength = input.dot(lines["tangent"])
	apply_pendulum_velocity(lines["tangent"], -input.x, delta)
	apply_gravity(lines["tangent"], delta)
	apply_air_resistence()
	cancel_tangent_velocity(lines["tangent"], delta)
	clamp_body_velocity(delta)
	
	body.global_position += body_velocity * delta

## 現在の手・肘の位置から手の接線・垂線を計算し返す
func get_arm_direction_lines(hand_pos: Vector2, elbow_pos: Vector2) -> Dictionary:
	var perpendicular: Vector2 = (hand_pos - elbow_pos).normalized()	
	var tangent = Vector2(-perpendicular.y, perpendicular.x)

	return {
		"perpendicular": perpendicular,
		"tangent": tangent
	}

## 振り子運動の力を速度に適用
func apply_pendulum_velocity(direction: Vector2, strength: float, delta: float) -> void:		
	var force: Vector2 = direction * strength * status.get_input_force_strength()
	body_velocity += force * delta

## 重力を適用
func apply_gravity(direction: Vector2,delta: float) -> void:
	var strength: float = Vector2(0.0, status.get_gravity()).dot(direction)
	var force: Vector2 = direction * strength
	body_velocity += force * delta

## 空気抵抗を適用
func apply_air_resistence() -> void:
	body_velocity *= status.get_air_resistance()

func cancel_tangent_velocity(direction: Vector2, delta: float) -> void:
	var strength: float = body_velocity.dot(direction)
	body_velocity = direction * strength


func clamp_body_velocity(delta: float) -> void:
	var accel_limit_x = status.get_accel_max_x() * delta
	if (body_velocity.x - last_body_velocity.x) > accel_limit_x:
		body_velocity.x -= body_velocity.x - last_body_velocity.x - accel_limit_x

	var accel_limit_y = status.get_accel_max_y() * delta	
	if (body_velocity.y - last_body_velocity.y) > accel_limit_y:
		body_velocity.y -= body_velocity.y - last_body_velocity.y - accel_limit_y
	
	last_body_velocity = Vector2(body_velocity.x, body_velocity.y)

		
func apply_rotation_power(delta: float) -> void:
	if not hand_controller.is_grabbing_something:
		return
	
	var target_rotation = 0.0
	body.rotation = lerp_angle(body.rotation, target_rotation, 0.002 * delta * status.get_gravity())
		
		
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
	var body_rect = body.get_node("BodySprite") as Sprite2D
	if body_rect == null:
		return
	
	# チャージ進捗をMIN_CHARGETIMEからMAX_CHARGETIMEで正規化
	# MIN_CHARGE_TIME以前は0、MAX_CHARGE_TIME以降は1になる
	var min_time_ratio = lunge_controller.input_charge_time / status.get_lunge_min_charge_time()
	var max_time_ratio = (lunge_controller.input_charge_time - status.get_lunge_min_charge_time()) / (status.get_lunge_max_charge_time() - status.get_lunge_min_charge_time())
	var normalized_charge = clamp(max_time_ratio, 0.0, 1.0)
	#charge_sprite.visible = true

	#var t = (config.LUNGE_MAX_CHARGE_TIME - lunge_controller.input_charge_time) / config.LUNGE_MAX_CHARGE_TIME
	#var charge_ratio = lunge_controller.input_charge_time / config.LUNGE_MAX_CHARGE_TIME
	#
	#var circle_scale = config.LUNGE_SPRITE_MAX_SCALE * t
	#charge_sprite.scale = Vector2(circle_scale, circle_scale)

	# 色を段階的に変化させる：黄色(1,1,0.5) → オレンジ(1,0.6,0) → 赤(1,0,0)
	var color: Color
	if normalized_charge < 0.5:
		# 黄色 → オレンジ
		var t = normalized_charge * 2.0
		var cyan = Color(0.0, 0.8, 1.0, 1.0)
		var light_cyan = Color(0.5, 1.0, 1.0, 1.0)
		color = cyan.lerp(light_cyan, t)
	else:
		# オレンジ → 赤
		var t = (normalized_charge - 0.5) * 2.0
		var light_cyan = Color(0.5, 1.0, 1.0, 1.0)
		var white = Color(0.99, 1.0, 1.0, 1.0)
		color = light_cyan.lerp(white, t)
	
	# MIN_CHARGE_TIME以上で点滅を開始
	if lunge_controller.input_charge_time >= status.get_lunge_min_charge_time():
		# 点滅速度：MIN_CHARGE_TIMEで遅く、MAX_CHARGE_TIMEで速くなる
		var pulse_speed = 5.0 + normalized_charge * 15.0  # 5～20
		var pulse = sin(Time.get_ticks_msec() * 0.001 * pulse_speed)# * 0.5 + 0.5
		#color.v *= pulse
		#color = Color.WHITE.lerp(color, pulse)
		pulse = max(pulse, 0.0)
		var white = Color(10.0, 10.0, 10.0, 1.0)
		color = color.lerp(white, pulse)
	
	body_rect.self_modulate = color

## ランジチャージがリセットされた時のコールバック
## [br][br]
## グロー効果をリセットして通常状態に戻す。
func _on_lunge_charge_reset() -> void:
	var body_rect = body.get_node("BodySprite") as Sprite2D
	if body_rect == null:
		return

	#charge_sprite.visible = false
	body_rect.self_modulate = Color(1.0, 1.0, 1.0, 1.0)


func grab_hand_sprite(hand: String, area: Area2D) -> void:
	if hand == "left":
		left_hand_sprite.animation = StringName("grab")
		left_chalk_particle.emitting = true
	elif hand == "right":
		right_hand_sprite.animation = StringName("grab")
		right_chalk_particle.emitting = true
	

func open_hand_sprite(hand: String, area: Area2D) -> void:
	if hand == "left":
		left_hand_sprite.animation = StringName("open")
		if hand_controller.grabbed_hold_right == null:
			body.linear_velocity = body_velocity
	elif hand == "right":
		right_hand_sprite.animation = StringName("open")
		if hand_controller.grabbed_hold_left == null:
			body.linear_velocity = body_velocity

func _on_hand_area_entered(area: Area2D) -> void:
	if area.is_in_group("holdarea"):
		var hold: HoldBehavior = area.get_parent()
		hold.lighten()

func _on_hand_area_exited(area: Area2D) -> void:
	if area.is_in_group("holdarea"):
		var hold: HoldBehavior = area.get_parent()
		hold.unlighten()

func lighten(name:String, area: Area2D) -> void:
	_on_hand_area_entered(area)

func unlighten(name: String, area: Area2D) -> void:
	_on_hand_area_exited(area)
