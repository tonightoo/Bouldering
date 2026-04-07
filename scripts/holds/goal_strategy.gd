class_name GoalStrategy
extends HoldBehaviorStrategy

enum GoalHand { BOTH, LEFT_ONLY, RIGHT_ONLY }
@export var required_hand: GoalHand = GoalHand.BOTH
@export var clear_time := 3.0

signal stage_cleared

func update(hold: HoldBehavior, delta: float) -> void:
	var holding := false
	match required_hand:
		GoalHand.BOTH:
			holding = hold.is_grabbed_both
		GoalHand.LEFT_ONLY:
			holding = hold.grabbed_by_left
		GoalHand.RIGHT_ONLY:
			holding = hold.grabbed_by_right

	if holding:
		hold.grabbed_goal_time += delta
		if hold.grabbed_goal_time >= clear_time:
			stage_cleared.emit()
	else:
		hold.grabbed_goal_time = 0.0
