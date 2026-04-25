## プレイヤー管理
## 
## プレイヤーの全体管理の中核ノード。
## 各種マネージャークラス（HandController、IKSolver、
## FatigueManager、GoalChecker、LungeController）を一体管理し、
## 每フレームの処理を調整する。
class_name Player
extends Node2D

## ハンドコントローラー（掴み及びリリース管理）
const HandController = preload("res://scripts/HandController.gd")
## IKソルバー（腕の角度計算）
const IKSolver = preload("res://scripts/IKSolver.gd")
## 疲労管理
const FatigueManager = preload("res://scripts/FatigueManager.gd")
## ゴールチェッカー
const GoalChecker = preload("res://scripts/GoalChecker.gd")
## ランジコントローラ
const LungeController = preload("res://scripts/LungeController.gd")
## オブザベーションコントローラ
const ObservationController = preload("res://scripts/ObservationController.gd")

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

## オブザベーションが必要かどうか
@export var is_need_observation: bool = false

@onready var head_sprite = $Body/HeadSprite

## プレイヤーボディ
@onready var body = $Body

@onready var body_sprite = $Body/BodySprite

@onready var body_collision = $Body/BodyCollision

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
## 左手ターゲットのスプライト
@onready var left_hand_target_sprite = $LeftHandTarget/VisualSprite
## 左手の当たり判定
@onready var left_hand_collision = $Body/LeftShoulder/LeftUpperArm/LeftElbow/LeftForeArm/LeftHand/CollisionShape2D

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
## 右手ターゲットのスプライト
@onready var right_hand_target_sprite = $RightHandTarget/VisualSprite
## 右手の当たり判定
@onready var right_hand_collision = $Body/RightShoulder/RightUpperArm/RightElbow/RightForeArm/RightHand/CollisionShape2D

## 右手の腕の長さのリミット
var right_arm_length_limit: float

## 画面中央表示用ラベル
@onready var message_label = $CanvasLayer/CenterMessageLabel
## 画面右上表示用ラベル
@onready var topright_message_label = $CanvasLayer/TopRightMessageLabel

## カメラ
@onready var camera = $Camera2D

## オブザベ中にかかる暗闇効果
@onready var dark_screen = $DarkScreen
## オブザベ中に使用する視界
@onready var spot_light = $ObservationVision
## クリア時のぼかし用
@onready var blur_rect = $CanvasLayer/BlurRect
## ヴィネット用
@onready var vignette_rect = $CanvasLayer/VignetteRect
## クリア時のエフェクト
@onready var clear_effect_left = $Body/ClearEffectLeft
@onready var clear_effect_right = $Body/ClearEffectRight

@onready var fart_particle = $Body/FartParticle

@onready var keys = $KeySelection

## 速度
var body_velocity: Vector2 = Vector2.ZERO
var last_body_velocity: Vector2 = Vector2.ZERO

var initial_position: Vector2 = Vector2.ZERO
var is_initialize_next: bool = false

var last_left_fore_arm_length: float = GlobalData.status.get_left_fore_arm_len()
var last_right_fore_arm_length: float = GlobalData.status.get_right_fore_arm_len()

signal cleared

## ゲームを初期化
## [br][br]
## 設定を設定し、各種マネージャークラスを生成し毎々に必要な参照を渡す。
func _ready() -> void:
	message_label.text = ""

	# スプライトの準備
	left_upper_arm_sprite.texture = GlobalData.status.get_left_upper_arm_sprite()
	right_upper_arm_sprite.texture = GlobalData.status.get_right_upper_arm_sprite()
	left_fore_arm_sprite.texture = GlobalData.status.get_left_fore_arm_sprite()
	right_fore_arm_sprite.texture = GlobalData.status.get_right_fore_arm_sprite()
	head_sprite.texture = GlobalData.status.get_head_sprite()
	body_sprite.texture = GlobalData.status.get_body_sprite()
	left_hand_sprite.sprite_frames = GlobalData.status.get_left_hand_sprite()
	right_hand_sprite.sprite_frames = GlobalData.status.get_right_hand_sprite()
	left_hand_sprite.animation = StringName("open")
	right_hand_sprite.animation = StringName("open")

	initial_position = Vector2(body.global_position.x, body.global_position.y)
	
	## 頭の位置・肩の位置をスプライトのサイズに応じて変更
	head_sprite.position.x = 0.0
	head_sprite.position.y = - body_sprite.texture.get_height() / 2 - head_sprite.texture.get_height() / 2 + GlobalData.status.get_head_overlap()
	
	left_shoulder.position.x = - body_sprite.texture.get_width() / 2 + GlobalData.status.get_left_shoulder_horizontal_overlap()
	left_shoulder.position.y = - body_sprite.texture.get_height() / 2 + GlobalData.status.get_left_shoulder_vertical_overlap()

	right_shoulder.position.x = body_sprite.texture.get_width() / 2 - GlobalData.status.get_right_shoulder_horizontal_overlap()
	right_shoulder.position.y = -body_sprite.texture.get_height() / 2 + GlobalData.status.get_right_shoulder_vertical_overlap()
	
	## Bodyの大きさに応じてBodyの当たり判定を変更
	body_collision.shape = CapsuleShape2D.new()
	var collision: CapsuleShape2D = CapsuleShape2D.new()
	if body_sprite.texture.get_width() > body_sprite.texture.get_height():
		collision.radius = body_sprite.texture.get_height() / 2
		collision.height = body_sprite.texture.get_width()
		body_collision.rotation = deg_to_rad(90.0)
	else:
		collision.radius = body_sprite.texture.get_width() / 2
		collision.height = body_sprite.texture.get_height()
		body_collision.rotation = deg_to_rad(0.0)
	
	body_collision.shape = collision
	
	## 手のサイズ・位置をステータスに応じて変更
	left_upper_arm_sprite.scale.x = GlobalData.status.get_left_upper_arm_len() / left_upper_arm_sprite.texture.get_width()
	left_upper_arm_sprite.position.x = GlobalData.status.get_left_upper_arm_len() / 2
	left_elbow.position.x = GlobalData.status.get_left_upper_arm_len()
	left_fore_arm_sprite.scale.x = GlobalData.status.get_left_fore_arm_len() / left_fore_arm_sprite.texture.get_width()
	left_fore_arm_sprite.position.x = GlobalData.status.get_left_fore_arm_len() / 2 - GlobalData.status.get_left_elbow_overlap()
	var left_hand_sprite_half_width = left_hand_sprite.sprite_frames.get_frame_texture("open", 0).get_width() * left_hand_sprite.scale.x / 2
	left_hand.position.x = GlobalData.status.get_left_fore_arm_len() - GlobalData.status.get_left_elbow_overlap() + left_hand_sprite_half_width - GlobalData.status.get_left_hand_overlap()
	var left_hand_sprite_half_height  = left_hand_sprite.sprite_frames.get_frame_texture("open", 0).get_height() * left_hand_sprite.scale.x / 2
	left_hand.position.y = - GlobalData.status.get_left_hand_horizontal_offset()
	var left_collision: CapsuleShape2D = CapsuleShape2D.new()
	left_collision.height = GlobalData.status.get_left_hand_collision_height()
	left_collision.radius = GlobalData.status.get_left_hand_collision_radius()
	left_hand_collision.shape = left_collision

	right_upper_arm_sprite.scale.x = GlobalData.status.get_right_upper_arm_len() / right_upper_arm_sprite.texture.get_width()
	right_upper_arm_sprite.position.x = GlobalData.status.get_right_upper_arm_len() / 2
	right_elbow.position.x = GlobalData.status.get_right_upper_arm_len()
	right_fore_arm_sprite.scale.x = GlobalData.status.get_right_fore_arm_len() / right_fore_arm_sprite.texture.get_width()
	right_fore_arm_sprite.position.x = GlobalData.status.get_right_fore_arm_len() / 2 - GlobalData.status.get_right_elbow_overlap()
	var right_hand_sprite_half_width = right_hand_sprite.sprite_frames.get_frame_texture("open", 0).get_width() * right_hand_sprite.scale.x / 2
	right_hand.position.x = GlobalData.status.get_right_fore_arm_len() - GlobalData.status.get_right_elbow_overlap() + right_hand_sprite_half_width - GlobalData.status.get_right_hand_overlap()
	right_hand.position.y = - GlobalData.status.get_right_hand_horizontal_offset()
	var right_collision: CapsuleShape2D = CapsuleShape2D.new()
	right_collision.height = GlobalData.status.get_right_hand_collision_height()
	right_collision.radius = GlobalData.status.get_right_hand_collision_radius()
	right_hand_collision.shape = right_collision

	# HandController を生成して参照ノードをセット
	hand_controller = HandController.new()
	add_child(hand_controller)
	hand_controller.left_hand_target = left_hand_target
	hand_controller.right_hand_target = right_hand_target
	hand_controller.left_hand = left_hand
	hand_controller.right_hand = right_hand
	hand_controller.body = body
	hand_controller.grabbed.connect(grab_hand_sprite)
	hand_controller.grabbed.connect(unlighten)
	hand_controller.grabbed.connect(reset_body_verocity)
	hand_controller.released.connect(open_hand_sprite)
	hand_controller.released.connect(lighten)

	# IKSolver を生成して参照ノードをセット
	ik_solver = IKSolver.new()
	add_child(ik_solver)
	ik_solver.body = body

	# FatigueManager を生成して参照ノードをセット
	fatigue_manager = FatigueManager.new()
	add_child(fatigue_manager)
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
	goal_checker.hand_controller = hand_controller
	goal_checker.goal_label = message_label
	goal_checker.victory_achieved.connect(inform_cleared)
	goal_checker.clear_effect_left = clear_effect_left
	clear_effect_left.emitting = false
	goal_checker.clear_effect_right = clear_effect_right
	clear_effect_right.emitting = false	

	# LungeController を生成して参照ノードをセット
	lunge_controller = LungeController.new()
	add_child(lunge_controller)
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
	observation_controller.observation_time_remaining = GlobalData.status.get_observation_time_limit()
	observation_controller.camera = camera
	observation_controller.is_observation = is_need_observation
	observation_controller.darkness = dark_screen
	observation_controller.spotlight = spot_light
	observation_controller.message_label = topright_message_label

	if is_need_observation:
		observation_controller.enable_observation()
		
	left_arm_length_limit = GlobalData.status.get_left_arm_max_len()
	right_arm_length_limit = GlobalData.status.get_right_arm_max_len()

	adjust_keys_scale(0.6)

func adjust_keys_scale(scale: float) -> void:
	keys.arrow_keys.scale = Vector2(scale, scale)
	keys.arrow_keys.pivot_offset = keys.arrow_keys.size / 2
	keys.arrow_keys.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	keys.action_keys.scale = Vector2(scale, scale)
	keys.action_keys.pivot_offset = keys.action_keys.size / 2
	keys.action_keys.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	keys.make_it_readonly()

func resize_left_arm(tween: Tween) -> void:
	if tween != null and hand_controller.grabbed_hold_left != null:
		tween.stop()
		tween.finished.emit()
		
	# 手のサイズ・位置をステータスに応じて変更
	var left_fore_arm_length: float = left_fore_arm_sprite.scale.x * left_fore_arm_sprite.texture.get_width()
	left_fore_arm_sprite.scale.x = GlobalData.status.get_left_fore_arm_len() / left_fore_arm_sprite.texture.get_width()
	left_fore_arm_sprite.position.x = GlobalData.status.get_left_fore_arm_len() / 2 - GlobalData.status.get_left_elbow_overlap()
	var left_hand_sprite_half_width = left_hand_sprite.sprite_frames.get_frame_texture("open", 0).get_width() * left_hand_sprite.scale.x / 2
	left_hand.position.x = GlobalData.status.get_left_fore_arm_len() - GlobalData.status.get_left_elbow_overlap() + left_hand_sprite_half_width - GlobalData.status.get_left_hand_overlap()
	#var left_dir = (left_hand_target.global_position - left_shoulder.global_position).normalized()
	left_hand_target.global_position += (left_fore_arm_length - last_left_fore_arm_length) * (left_hand_target.global_position - left_elbow.global_position).normalized()
	last_left_fore_arm_length = left_fore_arm_length

func resize_right_arm(tween: Tween) -> void:
	if tween != null and hand_controller.grabbed_hold_right != null:
		tween.stop()
		tween.finished.emit()

	var right_fore_arm_length: float = right_fore_arm_sprite.scale.x * right_fore_arm_sprite.texture.get_width()
	right_fore_arm_sprite.scale.x = GlobalData.status.get_right_fore_arm_len() / right_fore_arm_sprite.texture.get_width()
	right_fore_arm_sprite.position.x = GlobalData.status.get_right_fore_arm_len() / 2 - GlobalData.status.get_right_elbow_overlap()
	var right_hand_sprite_half_width = right_hand_sprite.sprite_frames.get_frame_texture("open", 0).get_width() * right_hand_sprite.scale.x / 2
	right_hand.position.x = GlobalData.status.get_right_fore_arm_len() - GlobalData.status.get_right_elbow_overlap() + right_hand_sprite_half_width - GlobalData.status.get_right_hand_overlap()
	right_hand_target.global_position += (right_fore_arm_length - last_right_fore_arm_length) * (right_hand_target.global_position - right_elbow.global_position).normalized()
	last_right_fore_arm_length = right_fore_arm_length

	#var right_dir = (right_hand_target.global_position - right_shoulder.global_position).normalized()
	#right_hand_target.global_position = right_shoulder.global_position + right_dir * right_arm_length_limit


# Called every frame. 'delta' is the elapsed time since the previous frame.
## 毎フレーム処理
## [br][br]
## 入力を受けつけ整常、疲労を計算し、IKを描画し、ゴールを判定し、
## ホールドの移動を使用してプレイヤーが介入。
## [br][br]
## [param delta] フレーム時間
func _process(delta: float) -> void:
	if GlobalData.status.is_gameover:
		GlobalData.signals.gameover.emit()

	if observation_controller.is_observation:
		return

	bouldering_process(delta)

func enabled_initialize() -> void:
	is_initialize_next = true

func initialize() -> void:
	body_velocity = Vector2.ZERO
	last_body_velocity = Vector2.ZERO
	body.linear_velocity = Vector2.ZERO
	body.angular_velocity = 0.0
	body.global_position = Vector2(initial_position.x, initial_position.y)
	body.global_rotation = 0
	is_initialize_next = false
	fatigue_manager.left_hand_fatigue = 0.0
	fatigue_manager.right_hand_fatigue = 0.0
	body.gravity_scale = 1.0
	camera.rotation = 0.0
	vignette_rect.visible = false
	GlobalData.status.reset_bonus()

func bouldering_process(delta: float) -> void:
	if is_initialize_next:
		initialize()
		return
		
	if Input.is_action_just_pressed("LeftHold"):
		hand_controller.try_grab(left_hand, true)
	
	if Input.is_action_just_pressed("RightHold"):
		hand_controller.try_grab(right_hand, false)

	if not Input.is_action_pressed("LeftHold") and hand_controller.grabbed_hold_left != null:
		hand_controller.release_left_grab()
		
	if not Input.is_action_pressed("RightHold") and hand_controller.grabbed_hold_right != null:
		hand_controller.release_right_grab()

	#resize_arms()
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
	apply_fart_skill()
	apply_air_dyno()
	
	goal_checker.check_goal_condition(delta)
	if hand_controller.is_grabbing_something:
		body.linear_velocity = Vector2.ZERO
	
	ik_solver.solve_ik(
		left_shoulder,
		GlobalData.status.get_left_upper_arm_len(),
		left_elbow,
		GlobalData.status.get_left_fore_arm_len() - GlobalData.status.get_left_elbow_overlap(),
		left_hand_target.global_position,
		1.0,
		GlobalData.status.get_left_arm_max_len()
	)
	if hand_controller.grabbed_hold_left != null:
		ik_solver.solve_reverse_ik(
			left_hand_target,
			left_shoulder,
			left_elbow,
			#config.LEFT_ARM_MAX_LEN,
			#left_arm_length_limit,
			GlobalData.status.get_left_arm_max_len(),
			GlobalData.status.get_left_arm_min_len(),
			GlobalData.status.get_left_upper_arm_len(),
			GlobalData.status.get_left_fore_arm_len() - GlobalData.status.get_left_elbow_overlap(),
			1.0,
			delta
		)
		
	ik_solver.solve_ik(
		right_shoulder,
		GlobalData.status.get_right_upper_arm_len(),
		right_elbow,
		GlobalData.status.get_right_fore_arm_len() - GlobalData.status.get_right_elbow_overlap(),
		right_hand_target.global_position,
		-1.0,
		GlobalData.status.get_right_arm_max_len()
	)
	if hand_controller.grabbed_hold_right != null:
		ik_solver.solve_reverse_ik(
			right_hand_target,
			right_shoulder,
			right_elbow,
			#config.RIGHT_ARM_MAX_LEN,
			#right_arm_length_limit,
			GlobalData.status.get_right_arm_max_len(),
			GlobalData.status.get_right_arm_min_len(),
			GlobalData.status.get_right_upper_arm_len(),
			GlobalData.status.get_right_fore_arm_len() - GlobalData.status.get_right_elbow_overlap(),
			-1.0,
			delta
		)	
	check_current_position()
	keys.update_cooltime()
	update_camera()
	#release_far_hold()
	#recalcurate_body_velocity(last_body_position, delta)
	if GlobalData.status.is_detaching_left:
		left_hand.global_position = left_hand_target.global_position
	if GlobalData.status.is_detaching_right:
		right_hand.global_position = right_hand_target.global_position

func release_far_hold() -> void:
	if hand_controller.grabbed_hold_left != null and \
		left_hand.global_position.distance_to(hand_controller.grabbed_hold_left.global_position) > 30:
			hand_controller.release_left_grab()

	if hand_controller.grabbed_hold_right != null and\
		right_hand.global_position.distance_to(hand_controller.grabbed_hold_right.global_position) > 30:
			hand_controller.release_right_grab()

func update_camera() -> void:
	if GlobalData.status.is_detaching_left:
		camera.global_position = left_hand_target.global_position
	elif GlobalData.status.is_detaching_right:
		camera.global_position = right_hand_target.global_position
	else:
		camera.global_position = body.global_position

func check_current_position() -> void:
	if not GlobalData.status.stage_bounds.has_point(body.global_position):
		self.initialize()
		GlobalData.status.set_remaining_life(GlobalData.status.remaining_life - 1)
	#if body.global_position.x >= 2000 or \
		#body.global_position.x <= -2000 or \
		#body.global_position.y >= 2000 or \
		#body.global_position.y <= -2000:

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
		left_dir = left_dir.rotated(camera.rotation)
		left_hand_velocity += left_dir * GlobalData.status.get_hand_accel() * delta
	else:
		left_hand_velocity = left_hand_velocity.move_toward(Vector2.ZERO, GlobalData.status.get_hand_decel() * delta)

	left_hand_velocity = left_hand_velocity.limit_length(GlobalData.status.get_hand_max_speed())

	if right_dir.length() > 0:
		right_dir = right_dir.normalized()		
		right_dir = right_dir.rotated(camera.rotation)
		right_hand_velocity += right_dir * GlobalData.status.get_hand_accel() * delta
	else:
		right_hand_velocity = right_hand_velocity.move_toward(Vector2.ZERO, GlobalData.status.get_hand_decel() * delta)

	right_hand_velocity = right_hand_velocity.limit_length(GlobalData.status.get_hand_max_speed())
		
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
			GlobalData.status.get_left_arm_max_len()
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
			GlobalData.status.get_right_arm_max_len()
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
	var distance = Vector2(force.x * GlobalData.status.get_keep_up_strength(), force.y * GlobalData.status.get_lift_up_strength()) * delta
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

	var lines = get_arm_direction_lines(hand_pos, body.global_position)
	
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
	var force: Vector2 = direction * strength * GlobalData.status.get_input_force_strength()
	body_velocity += force * delta

## 重力を適用
func apply_gravity(direction: Vector2,delta: float) -> void:
	var strength: float = Vector2(0.0, GlobalData.status.get_gravity()).dot(direction)
	var force: Vector2 = direction * strength
	body_velocity += force * delta

## 空気抵抗を適用
func apply_air_resistence() -> void:
	body_velocity *= GlobalData.status.get_air_resistance()

func cancel_tangent_velocity(direction: Vector2, delta: float) -> void:
	var strength: float = body_velocity.dot(direction)
	body_velocity = direction * strength


func clamp_body_velocity(delta: float) -> void:
	var accel_limit_x = GlobalData.status.get_accel_max_x() * delta
	if (body_velocity.x - last_body_velocity.x) > accel_limit_x:
		body_velocity.x -= body_velocity.x - last_body_velocity.x - accel_limit_x

	var accel_limit_y = GlobalData.status.get_accel_max_y() * delta	
	if (body_velocity.y - last_body_velocity.y) > accel_limit_y:
		body_velocity.y -= body_velocity.y - last_body_velocity.y - accel_limit_y
	
	last_body_velocity = Vector2(body_velocity.x, body_velocity.y)

		
func apply_rotation_power(delta: float) -> void:
	if not hand_controller.is_grabbing_something:
		return
	body.rotation = lerp_angle(
		body.rotation, 
		GlobalData.status.get_initial_rotation(), 
		0.002 * delta * abs(GlobalData.status.get_gravity())
	)
	
		
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
	var min_time_ratio = lunge_controller.input_charge_time / GlobalData.status.get_lunge_min_charge_time()
	var max_time_ratio = (lunge_controller.input_charge_time - GlobalData.status.get_lunge_min_charge_time()) / (GlobalData.status.get_lunge_max_charge_time() - GlobalData.status.get_lunge_min_charge_time())
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
	if lunge_controller.input_charge_time >= GlobalData.status.get_lunge_min_charge_time():
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
		left_hand_sprite.animation = StringName("grab_gaba")
		left_chalk_particle.emitting = true
	elif hand == "right":
		right_hand_sprite.animation = StringName("grab_gaba")
		right_chalk_particle.emitting = true
	Input.start_joy_vibration(0, 0.5, 0.8, 0.2)
	hitstop(0.05)

func hitstop(duration: float) -> void:
	Engine.time_scale = 0.1
	await get_tree().create_timer(duration * 0.1).timeout
	Engine.time_scale = 1.0

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
	if area == null:
		return
	if area.is_in_group("holdarea"):
		var hold: HoldBehavior = area.get_parent()
		hold.lighten()

func _on_hand_area_exited(area: Area2D) -> void:
	if area.is_in_group("holdarea"):
		var hold: HoldBehavior = area.get_parent()
		hold.unlighten()

func reset_body_verocity(name: String, area: Area2D) -> void:
	body_velocity = Vector2.ZERO
	last_body_velocity = Vector2.ZERO

func lighten(name:String, area: Area2D) -> void:
	_on_hand_area_entered(area)

func unlighten(name: String, area: Area2D) -> void:
	_on_hand_area_exited(area)
	
func inform_cleared() -> void:
	emit_signal("cleared")

func apply_air_dyno() -> void:
	if not GlobalData.status.is_triggered_air_dyno:
		return
	var direction: Vector2 = Vector2(
		Input.get_action_strength("LeftRight") - Input.get_action_strength("LeftLeft") + Input.get_action_strength("RightRight") - Input.get_action_strength("RightLeft"),
		Input.get_action_strength("LeftDown")  - Input.get_action_strength("LeftUp") + Input.get_action_strength("RightDown")  - Input.get_action_strength("RightUp")
	)
	if direction == Vector2.ZERO:
		direction = -body.global_transform.y
	
	var force:Vector2 = direction.normalized() * GlobalData.status.get_lunge_skill_force()
	GlobalData.status.is_triggered_air_dyno = false
		
	if hand_controller.is_grabbing_something:
		body_velocity += force
	else:
		body.linear_velocity += force

func apply_fart_skill() -> void:
	if not GlobalData.status.is_triggered_fart_lunge:
		return
	var direction: Vector2 = -body.global_transform.y
	var force:Vector2 = direction * GlobalData.status.get_fart_force()
	GlobalData.status.is_triggered_fart_lunge = false
		
	if hand_controller.is_grabbing_something:
		body_velocity += force
	else:
		body.linear_velocity += force
