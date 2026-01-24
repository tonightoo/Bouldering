## 逆運動学（IK）ソルバー
## 
## プレイヤーの腕の角度を計算し、手がターゲット位置に到達するように
## 肩と肘の回転を解決する。通常のIK と逆IK（ホールド掴み時）の2モード対応。
class_name IKSolver
extends Node

## ゲーム設定（SMOOTHNESS等を参照）
var config: PlayerConfig
## プレイヤーボディ（肩の位置決定に使用）
var body: Node2D

## 通常の逆運動学（IK）で腕を解く
## [br][br]
## 肩とエルボーの回転角度を計算し、手がターゲット位置に到達するように解く。
## 両腕共通で使用される基本的なIKアルゴリズム。
## [br][br]
## [param shoulder] 肩のNode2D（グローバル回転を更新）
## [param upper_len] 上腕の長さ
## [param elbow] 肘のNode2D（ローカル回転を更新）
## [param fore_len] 前腕の長さ
## [param hand_target] 手が到達すべきグローバル座標
## [param sign] 1.0 = 左手、-1.0 = 右手（計算方向の反転用）
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

## ホールド掴み時の逆IK（手位置固定、肩位置可変）
## [br][br]
## 手の位置を固定し、プレイヤー入力に応じて肩とボディの位置を計算する。
## 腕の長さ制約（最小・最大）を考慮して肩位置をクランプする。
## [br][br]
## [param hand_target] 手のターゲットNode2D（グローバル位置を参照）
## [param shoulder] 肩のNode2D
## [param elbow] 肘のNode2D
## [param arm_max_len] 腕の最大伸長距離
## [param arm_min_len] 腕の最小屈曲距離
## [param upper_len] 上腕の長さ
## [param fore_len] 前腕の長さ
## [param sign] 1.0 = 左手、-1.0 = 右手
## [param delta] フレーム時間
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

## 円形の範囲内に位置をクランプ
## [br][br]
## 指定した中心から最大距離以内に位置を制限する。
## ハンドの可動範囲制限に使用。
## [br][br]
## [param center] 円の中心
## [param pos] クランプする位置
## [param max_radius] 最大半径
## [return] クランプ後の位置
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
