## グラブ・リリース管理
## 
## プレイヤーの左手・右手がホールドを掴む・離すの制御を担当する。
## ホールドとの衝突検出、掴み状態の管理、ハンドターゲットの位置更新を行う。
class_name HandController
extends Node

## 左手がホールドを掴んだ時に発火（未使用）
signal grabbed(hand: String, area)
## 左手がホールドを離した時に発火（未使用）
signal released(hand: String)

## 左手が現在掴んでいるホールド
var grabbed_hold_left: Area2D = null
## 右手が現在掴んでいるホールド
var grabbed_hold_right: Area2D = null
## どちらかの手がホールドを掴んでいるか
var is_grabbing_something: bool = false

## 左手ターゲットノード（外部からセット）
var left_hand_target: Node2D
## 右手ターゲットノード（外部からセット）
var right_hand_target: Node2D
## 左手の実際のノード（外部からセット）
var left_hand: Area2D
## 右手の実際のノード（外部からセット）
var right_hand: Area2D

## ホールドを掴もうとする
## [br][br]
## 指定した手の衝突エリア内のホールドを検索し、掴む。
## 掴んだ場合、HoldBehaviorに掴み状態を通知し、ハンドターゲットをホールド位置に移動させる。
## [br][br]
## [param hand] ホールドに接触している手のArea2D
## [param is_left] true なら左手、false なら右手
func try_grab(hand: Area2D, is_left: bool) -> void:
	var areas = hand.get_overlapping_areas()
	for a in areas:
		if not a.is_in_group("hold"):
			continue

		var hold = a.get_parent() as HoldBehavior
		if is_left:
			grabbed_hold_left = a
			if left_hand_target:
				left_hand_target.global_position = a.global_position
			if hold:
				hold.grabbed_by_left = true
			emit_signal("grabbed", "left", a)
		else:
			grabbed_hold_right = a
			if right_hand_target:
				right_hand_target.global_position = a.global_position
			if hold:
				hold.grabbed_by_right = true
			emit_signal("grabbed", "right", a)

		update_grab_state()
		return

## 左手でホールドを離す
## [br][br]
## 左手が掴んでいるホールドをリリースし、
## HoldBehaviorに状態を通知し、ハンドターゲットを実際の手の位置に戻す。
func release_left_grab() -> void:
	if grabbed_hold_left != null:
		var hold = grabbed_hold_left.get_parent() as HoldBehavior
		if hold != null:
			hold.grabbed_by_left = false

	grabbed_hold_left = null
	if left_hand_target and left_hand:
		left_hand_target.global_position = left_hand.global_position
	emit_signal("released", "left")
	update_grab_state()

## 右手でホールドを離す
## [br][br]
## 右手が掴んでいるホールドをリリースし、
## HoldBehaviorに状態を通知し、ハンドターゲットを実際の手の位置に戻す。
func release_right_grab() -> void:
	if grabbed_hold_right != null:
		var hold = grabbed_hold_right.get_parent() as HoldBehavior
		if hold != null:
			hold.grabbed_by_right = false

	grabbed_hold_right = null
	if right_hand_target and right_hand:
		right_hand_target.global_position = right_hand.global_position
	emit_signal("released", "right")
	update_grab_state()

## 掴み状態を更新
## [br][br]
## is_grabbing_something フラグを、現在のホールド状態に基づいて更新する。
func update_grab_state() -> void:
	is_grabbing_something = (grabbed_hold_left != null or grabbed_hold_right != null)
