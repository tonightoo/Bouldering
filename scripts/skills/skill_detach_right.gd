class_name SkillDetachRight
extends SkillLogic

var original_position: Vector2

func execute(key: String, player: Player, stage: Stage):
	if player.observation_controller.is_observation:
		return
	
	if not is_ready():
		return
	
	if player.hand_controller.grabbed_hold_right != null:
		return
	
	if GlobalData.status.is_detaching_left:
		return

	GlobalData.status.is_detaching_right = true
	GlobalData.status.right_detach_bonus = 1000.0
	original_position = player.right_hand.position
	GlobalData.status.right_detach_point = player.right_hand.global_position
	#player.left_hand_sprite.visible = false
	#player.left_hand_target.visible = true

	start_cooldown()
	player.get_tree().create_timer(10.0).timeout.connect(
		func(): restore(player)
	)

func restore(player: Player) -> void:
	if player.hand_controller.grabbed_hold_left != null:
		player.hand_controller.release_left_grab()
	if player.hand_controller.grabbed_hold_right != null:
		var target_pos = player.right_hand_target.global_position - player.body.to_local(player.right_fore_arm.global_position) - original_position
		var tween = player.create_tween()
		tween.tween_property(player.body, "global_position", target_pos, 1.0)\
			.set_trans(Tween.TRANS_QUART)\
			.set_ease(Tween.EASE_OUT)
		tween.parallel().tween_method(
			func(_val): player.right_hand.global_position = player.right_hand_target.global_position,
			0.0, 1.0, 1.0
		)
		tween.finished.connect(complete_restore.bind(player))
	else:
		complete_restore(player)

func complete_restore(player: Player) -> void:
	if player.hand_controller.grabbed_hold_right != null:
		player.body.global_position = player.right_hand_target.global_position - player.body.to_local(player.right_fore_arm.global_position) - original_position

	GlobalData.status.is_detaching_right = false
	GlobalData.status.right_detach_bonus = 0.0
	player.right_hand.position = original_position
	player.right_hand.global_position = player.right_fore_arm.global_position + original_position.rotated(player.right_fore_arm.global_rotation)
	#player.resize_left_arm(null)
	#player.left_hand_sprite.visible = true
	#player.left_hand_target.visible = false
