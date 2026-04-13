class_name SkillDetachLeft
extends SkillLogic


var original_position: Vector2

func execute(key: String, player: Player, stage: Stage):
	if player.observation_controller.is_observation:
		return
	
	if not is_ready():
		return
	
	if player.hand_controller.grabbed_hold_left != null:
		return

	if GlobalData.status.is_detaching_right:
		return

	GlobalData.status.is_detaching_left = true
	GlobalData.status.left_detach_bonus = 1000.0
	original_position = player.left_hand.position
	GlobalData.status.left_detach_point = player.left_hand.global_position
	#player.left_hand_sprite.visible = false
	#player.left_hand_target.visible = true

	start_cooldown()
	player.get_tree().create_timer(10.0).timeout.connect(
		func(): restore(player)
	)

func restore(player: Player) -> void:
	if player.hand_controller.grabbed_hold_right != null:
		player.hand_controller.release_right_grab()
	if player.hand_controller.grabbed_hold_left != null:
		var target_pos = player.left_hand_target.global_position - player.body.to_local(player.left_fore_arm.global_position) - original_position
		var tween = player.create_tween()
		tween.tween_property(player.body, "global_position", target_pos, 1.0)\
			.set_trans(Tween.TRANS_QUART)\
			.set_ease(Tween.EASE_OUT)
		tween.parallel().tween_method(
			func(_val): player.left_hand.global_position = player.left_hand_target.global_position,
			0.0, 1.0, 1.0
		)
		tween.finished.connect(complete_restore.bind(player))
	else:
		complete_restore(player)

func complete_restore(player: Player) -> void:
	if player.hand_controller.grabbed_hold_left != null:
		player.body.global_position = player.left_hand_target.global_position - player.body.to_local(player.left_fore_arm.global_position) - original_position

	GlobalData.status.is_detaching_left = false
	GlobalData.status.left_detach_bonus = 0.0
	player.left_hand.position = original_position
	player.left_hand.global_position = player.left_fore_arm.global_position + original_position.rotated(player.left_fore_arm.global_rotation)
	#player.resize_left_arm(null)
	#player.left_hand_sprite.visible = true
	#player.left_hand_target.visible = false
