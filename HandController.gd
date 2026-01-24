class_name HandController
extends Node

signal grabbed(hand: String, area)
signal released(hand: String)

# 掴む状態
var grabbed_hold_left: Area2D = null
var grabbed_hold_right: Area2D = null
var is_grabbing_something: bool = false

# 外部からセットするノード参照
var left_hand_target: Node2D
var right_hand_target: Node2D
var left_hand: Area2D
var right_hand: Area2D

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

func update_grab_state() -> void:
	is_grabbing_something = (grabbed_hold_left != null or grabbed_hold_right != null)
