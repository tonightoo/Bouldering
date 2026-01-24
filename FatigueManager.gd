class_name FatigueManager
extends Node

signal fatigue_depleted(hand: String)

# 疲労度
var left_hand_fatigue: float = 0.0
var right_hand_fatigue: float = 0.0

# 外部からセットする参照
var config: PlayerConfig
var hand_controller: HandController
var left_elbow: Node2D
var right_elbow: Node2D
var left_shoulder: Node2D
var right_shoulder: Node2D
var left_hand: Node2D
var right_hand: Node2D

func update(delta: float) -> void:
	update_left_fatigue(delta)
	update_right_fatigue(delta)

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
