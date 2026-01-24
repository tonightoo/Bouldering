class_name GoalChecker
extends Node

signal victory_achieved

# 外部からセットする参照
var config: PlayerConfig
var hand_controller: HandController
var goal_label: Label
var last_display_score := 0

func check_goal_condition(delta: float) -> void:
	if hand_controller.grabbed_hold_left != null and hand_controller.grabbed_hold_right != null:
		# 両方のホールドが「GOAL」タイプかチェック
		var hold_l = hand_controller.grabbed_hold_left.get_parent() as HoldBehavior
		var hold_r = hand_controller.grabbed_hold_right.get_parent() as HoldBehavior
		
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
		
		var tween = goal_label.create_tween()
		goal_label.scale = Vector2(1.5, 1.5)
		tween.tween_property(goal_label, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK)
	elif elapsed_time >= config.GOAL_FREEZE_TIME:
		goal_label.text = "Victory!"
		goal_label.modulate = Color.GOLD

func victory() -> void:
	print("victory!")
	emit_signal("victory_achieved")
