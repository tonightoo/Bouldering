## ゴール管理
## 
## プレイヤーがゴールホールドを掴み条件を満たしているかを判定し、
## UI表示（カウントダウン）を実施。クリアを検出してシグナルを発火。
class_name GoalChecker
extends CanvasLayer

## クリア設定完了時に発火
signal victory_achieved

## ハンドコントローラー（掴み状態を参照）
var hand_controller: HandController
## ゴール表示用Label
var goal_label: Label
## 最後に表示されていた時間
var last_display_score := 0

var clear_effect_left: GPUParticles2D
var clear_effect_right: GPUParticles2D

var is_goaled: bool = false

func _ready() -> void:
	GlobalData.signals.gameover.connect(gameover)

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
			if (hold_l.grabbed_goal_time >= GlobalData.status.get_goal_freeze_time() and
				hold_r.grabbed_goal_time >= GlobalData.status.get_goal_freeze_time()):
				victory()
	else:
		update_goal_ui(0.0)

func gameover() -> void:
	GlobalData.status.pause_enabled = false
	goal_label.text = "Loser"
	goal_label.modulate = Color.DARK_RED
	goal_label.modulate.a = 0.0
	goal_label.scale = Vector2(0.5, 0.5)
	goal_label.pivot_offset = goal_label.size / 2
	var tween = goal_label.create_tween().set_parallel(true)
	tween.tween_property(goal_label, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(goal_label, "scale", Vector2(1.0, 1.0), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	await get_tree().create_timer(2.0).timeout
	GlobalData.status.pause_enabled = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	

## ゴール設定 UI を更新
## [br][br]
## 掴んでいる時間を反映し、時間統計を表示。
## 一定時間に達したら"Victory!"を表示。
## [br][br]
## [param elapsed_time] ゴールホールド保持経過時間
func update_goal_ui(elapsed_time: float) -> void:
	if GlobalData.status.is_gameover:
		return
	var current_score = int(ceil(elapsed_time))
	if elapsed_time <= 0.0 and not is_goaled:
		goal_label.text = ""
		last_display_score = -1
	elif elapsed_time < GlobalData.status.get_goal_freeze_time() and current_score != last_display_score and not is_goaled:
		last_display_score = current_score
		goal_label.text = str(current_score)
		goal_label.modulate = Color.WHITE
		
		var tween = goal_label.create_tween()
		goal_label.scale = Vector2(1.5, 1.5)
		tween.tween_property(goal_label, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK)
	elif elapsed_time >= GlobalData.status.get_goal_freeze_time() and not is_goaled: 
		display_clear_performance()

func display_clear_performance() -> void:
	is_goaled = true
	GlobalData.status.pause_enabled = false
	clear_effect_left.restart()
	clear_effect_left.emitting = true
	clear_effect_right.restart()
	clear_effect_right.emitting = true
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
