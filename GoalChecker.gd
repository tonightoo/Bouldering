## ゴール管理
## 
## プレイヤーがゴールホールドを掴み条件を満たしているかを判定し、
## UI表示（カウントダウン）を実施。クリアを検出してシグナルを発火。
class_name GoalChecker
extends Node

## クリア設定完了時に発火
signal victory_achieved

## ステータス
var status: PlayerStatus
## ハンドコントローラー（掴み状態を参照）
var hand_controller: HandController
## ゴール表示用Label
var goal_label: Label
## 最後に表示されていた時間
var last_display_score := 0

var clear_effect: GPUParticles2D

var is_goaled: bool = false

## ゴールしたかどうかを確認
## [br][br]
## 両手でゴールホールドを掴んでいるか確認し
## つかんでいる時間が所定時間を満たしていればクリア。
## [br][br]
## [param delta] フレーム時間
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
			if (hold_l.grabbed_goal_time >= status.get_goal_freeze_time() and
				hold_r.grabbed_goal_time >= status.get_goal_freeze_time()):
				victory()
	else:
		update_goal_ui(0.0)

## ゴール設定 UI を更新
## [br][br]
## 掴んでいる時間を反映し、時間統計を表示。
## 一定時間に達したら"Victory!"を表示。
## [br][br]
## [param elapsed_time] ゴールホールド保持経過時間
func update_goal_ui(elapsed_time: float) -> void:
	var current_score = int(ceil(elapsed_time))
	if elapsed_time <= 0.0 and not is_goaled:
		goal_label.text = ""
		last_display_score = -1
	elif elapsed_time < status.get_goal_freeze_time() and current_score != last_display_score and not is_goaled:
		last_display_score = current_score
		goal_label.text = str(current_score)
		goal_label.modulate = Color.WHITE
		
		var tween = goal_label.create_tween()
		goal_label.scale = Vector2(1.5, 1.5)
		tween.tween_property(goal_label, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK)
	elif elapsed_time >= status.get_goal_freeze_time(): 
		is_goaled = true
		clear_effect.restart()
		clear_effect.emitting = true
		goal_label.text = "Victory!"
		goal_label.modulate = Color.GOLD
		goal_label.scale = Vector2(0.1, 0.1)
		goal_label.pivot_offset = goal_label.size / 2
		var tween = goal_label.create_tween()
		tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(goal_label, "scale", Vector2(1.0, 1.0), 1.0)
		tween.parallel().tween_property(goal_label, "modulate:a", 1.0, 1.0)
	
## クリア処理
## [br][br]
## クリアを発表し、シグナルを発火。
func victory() -> void:
	emit_signal("victory_achieved")
