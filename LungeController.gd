## ランジ（ダイノ）管理
## 
## プレイヤーが両手でホールドを掴んでいる状態で、
## 強い入力を一定時間加え続けるとランジ（ジャンプ）を発動。
## 入力方向の逆方向に大きな速度を付与してプレイヤーを射出する。
class_name LungeController
extends Node

## ランジ発動時に発火
signal lunge_triggered(direction: Vector2, force: float)

## ゲーム設定
var config: PlayerConfig
## ハンドコントローラー（掴み状態の確認用）
var hand_controller: HandController
## プレイヤーボディ（速度付与用）
var body: Node2D
## 左肩（腕伸び切り判定用）
var left_shoulder: Node2D
## 右肩（腕伸び切り判定用）
var right_shoulder: Node2D
## 左手（腕伸び切り判定用）
var left_hand: Node2D
## 右手（腕伸び切り判定用）
var right_hand: Node2D

## 現在の入力方向
var current_input_direction: Vector2 = Vector2.ZERO
## 入力継続時間
var input_charge_time: float = 0.0
## ランジのクールタイム残時間
var lunge_cooldown_time: float = 0.0
## ランジ発動済みフラグ
var has_lunged_in_charge: bool = false

## ランジ管理を更新
## [br][br]
## 毎フレーム呼び出され、入力を監視してランジ条件を確認。
## 両手掴み状態で腕が完全に伸び切っており、
## 強い一定入力が続いていれば条件を満たす。
## [br][br]
## [param delta] フレーム時間
func update(delta: float) -> void:
	# クールタイムを減らす
	lunge_cooldown_time = max(lunge_cooldown_time - delta, 0.0)
	
	# 両手掴み状態かつ腕が伸び切っていなければ リセット
	if hand_controller.grabbed_hold_left == null or hand_controller.grabbed_hold_right == null or not are_arms_fully_extended():
		input_charge_time = 0.0
		has_lunged_in_charge = false
		current_input_direction = Vector2.ZERO
		return
	
	# 現在の入力を取得
	var left_input = Vector2(
		Input.get_action_strength("LeftRight") - Input.get_action_strength("LeftLeft"),
		Input.get_action_strength("LeftDown") - Input.get_action_strength("LeftUp")
	)
	var right_input = Vector2(
		Input.get_action_strength("RightRight") - Input.get_action_strength("RightLeft"),
		Input.get_action_strength("RightDown") - Input.get_action_strength("RightUp")
	)
	
	# 入力が十分に強いか判定
	if (left_input.length() >= config.LUNGE_INPUT_THRESHOLD and
	  right_input.length() >= config.LUNGE_INPUT_THRESHOLD):
		current_input_direction = (-left_input - right_input).normalized()
		input_charge_time += delta
		
		# チャージ時間に達して、まだランジしていなければ発動
		if input_charge_time >= config.LUNGE_CHARGE_TIME and not has_lunged_in_charge and lunge_cooldown_time <= 0.0:
			trigger_lunge(current_input_direction)
			has_lunged_in_charge = true
	else:
		# 入力が弱くなったらリセット
		input_charge_time = 0.0
		has_lunged_in_charge = false
		current_input_direction = Vector2.ZERO

## 両腕が完全に伸び切っているか判定
## [br][br]
## 左右両手とその肩の距離が、腕の最大長さに近いか判定。
## 余裕を持たせるため、最大長さの95%以上で判定。
## [br][br]
## [return] 両腕が伸び切っていれば true
func are_arms_fully_extended() -> bool:
	# 左腕の距離を計算
	var left_distance = left_shoulder.global_position.distance_to(left_hand.global_position)
	var left_max_len = config.LEFT_ARM_MAX_LEN
	var left_extended = left_distance >= left_max_len * 0.95
	
	# 右腕の距離を計算
	var right_distance = right_shoulder.global_position.distance_to(right_hand.global_position)
	var right_max_len = config.RIGHT_ARM_MAX_LEN
	var right_extended = right_distance >= right_max_len * 0.95
	
	# 両腕が伸び切っていれば true
	return left_extended and right_extended

## ランジを発動
## [br][br]
## 入力方向の逆方向にプレイヤーボディに速度を付与。
## クールタイムを設定してシグナルを発火。
## [br][br]
## [param input_direction] 入力方向（これの逆方向にジャンプ）
func trigger_lunge(input_direction: Vector2) -> void:
	# 逆方向にジャンプ
	var lunge_direction = -input_direction.normalized()
	var lunge_velocity = lunge_direction * config.LUNGE_FORCE
	
	# 両手をリリース（ホールドから離す）
	hand_controller.release_left_grab()
	hand_controller.release_right_grab()
	
	# 1秒間グラブを禁止（ランジ直後の再掴みを防止）
	hand_controller.set_grab_prohibition(1.0)
	
	# ボディに速度を付与（RigidBody2D は linear_velocity を使用）
	body.linear_velocity += lunge_velocity
	
	# クールタイムを設定
	lunge_cooldown_time = config.LUNGE_COOLDOWN
	
	# シグナルを発火
	emit_signal("lunge_triggered", lunge_direction, config.LUNGE_FORCE)
	
	print("Lunge triggered! Direction: ", lunge_direction, " Force: ", config.LUNGE_FORCE)
