class_name SkillVictory
extends SkillLogic

const MIN_V_ANGLE = 15.0
const MAX_V_ANGLE = 45.0

func execute(key: String, player: Player, stage: Stage):
	if player.observation_controller.is_observation:
		return
	
	var vec_body = -player.body.global_transform.y
	var vec_left = (player.left_hand.global_position - player.left_shoulder.global_position).normalized()
	var vec_right = (player.right_hand.global_position - player.right_shoulder.global_position).normalized()
	var shoulder_to_elbow_left = (player.left_elbow.global_position - player.left_shoulder.global_position).normalized()
	var shoulder_to_elbow_right = (player.right_elbow.global_position - player.right_shoulder.global_position).normalized()
	var straightness_left = shoulder_to_elbow_left.dot(vec_left)
	var straightness_right = shoulder_to_elbow_right.dot(vec_right)
	var is_straight = straightness_left >= 0.99 and straightness_right >= 0.99
	var angle_l = abs(rad_to_deg(vec_body.angle_to(vec_left)))
	var angle_r = abs(rad_to_deg(vec_body.angle_to(vec_right)))
	var is_in_range = (angle_l > MIN_V_ANGLE and angle_l < MAX_V_ANGLE) and (angle_r > MIN_V_ANGLE and angle_r < MAX_V_ANGLE)
	var is_symmetric = abs(angle_l - angle_r) <= 1.0
	if is_straight and is_in_range and is_symmetric:
		player.goal_checker.display_clear_performance()
		player.goal_checker.victory()

	GlobalData.status.skill_slots[key] = GlobalData.empty_skill
	player.keys.update_sprites()
