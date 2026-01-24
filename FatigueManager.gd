## 疲労管理
## 
## プレイヤーの左手・右手の疲労度を計算・更新
## ホールドを掴んでいる間疲労をため、話している間回復していく
## 疲労を超過した場合自動でホールドをリリースする。
class_name FatigueManager
extends Node

## 疲労完全時に発火
signal fatigue_depleted(hand: String)

## 左手の疲労度（ 0.0 - MAX_FATIGUE ）
var left_hand_fatigue: float = 0.0
## 右手の疲労度（ 0.0 - MAX_FATIGUE ）
var right_hand_fatigue: float = 0.0

## ゲーム設定（FATIGUE_RATE_*等を参照）
var config: PlayerConfig
## ハンドコントローラー（掴み状態を参照）
var hand_controller: HandController
## 左肘のNode2D
## 肘の曲がり具合から疲労郘を計算
var left_elbow: Node2D
## 右肘のNode2D
var right_elbow: Node2D
## 左肩のNode2D
## 肩の高さを筓との比較に使用
var left_shoulder: Node2D
## 右肩のNode2D
var right_shoulder: Node2D
## 左手のNode2D
var left_hand: Node2D
## 右手のNode2D
var right_hand: Node2D

## 両手の疲労を更新
## [br][br]
## [param delta] フレーム時間
func update(delta: float) -> void:
	update_left_fatigue(delta)
	update_right_fatigue(delta)

## 左手の疲労を更新
## [br][br]
## 掴んでいる場合、肘の曲がりと肩の高さを考慮して疲労を追加
## 疲労最大時に自動リリース。掴んでいない場合、疲労を回復
## [br][br]
## [param delta] フレーム時間
func update_left_fatigue(delta: float) -> void:
	if hand_controller.grabbed_hold_left != null:
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
		if hand_controller.grabbed_hold_right != null:
			fatigue_rate *= config.FATIGUE_BOTH_HANDS_REDUCE_RATE
		
		# 疲労度を増加
		left_hand_fatigue += fatigue_rate * delta
		left_hand_fatigue = min(left_hand_fatigue, config.MAX_FATIGUE)
		
		# パンプしたら自動で離れる
		if left_hand_fatigue >= config.MAX_FATIGUE:
			hand_controller.release_left_grab()
			emit_signal("fatigue_depleted", "left")
	else:
		# レスト中は回復
		left_hand_fatigue -= config.FATIGUE_RECOVERY_RATE * delta
		left_hand_fatigue = max(left_hand_fatigue, 0.0)

## 右手の疲労を更新
## [br][br]
## 掴んでいる場合、肘の曲がりと肩の高さを考慮して疲労を追加
## 疲労最大時に自動リリース。掴んでいない場合、疲労を回復
## [br][br]
## [param delta] フレーム時間
func update_right_fatigue(delta: float) -> void:
	if hand_controller.grabbed_hold_right != null:
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
		if hand_controller.grabbed_hold_left != null:
			fatigue_rate *= config.FATIGUE_BOTH_HANDS_REDUCE_RATE

		
		right_hand_fatigue += fatigue_rate * delta
		right_hand_fatigue = min(right_hand_fatigue, config.MAX_FATIGUE)
		
		if right_hand_fatigue >= config.MAX_FATIGUE:
			hand_controller.release_right_grab()
			emit_signal("fatigue_depleted", "right")
	else:
		right_hand_fatigue -= config.FATIGUE_RECOVERY_RATE * delta
		right_hand_fatigue = max(right_hand_fatigue, 0.0)
