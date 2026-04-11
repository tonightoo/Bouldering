class_name SkillRightWireArm
extends SkillLogic


var executed_tween: Tween

func execute(key: String, player: Player, stage: Stage):
	if player.observation_controller.is_observation:
		return
	
	if not is_ready():
		return
	
	if player.hand_controller.grabbed_hold_right != null:
		return

	#var tween = player.create_tween()
	executed_tween = player.create_tween()
	executed_tween.finished.connect(shrink.bind(player))
	executed_tween.tween_method(
		func(value: float): 
			GlobalData.status.right_arm_length_multiplier = value
			player.resize_right_arm(executed_tween),
		1.0,   # 開始値
		5.0,   # 終了値
		0.5    # 何秒かけて伸ばすか
	)
	start_cooldown()

func shrink(player: Player) -> void:
	var tween = player.create_tween()
	
	tween.tween_method(
		func(value: float): 
			GlobalData.status.right_arm_length_multiplier = value
			player.resize_right_arm(null),
		GlobalData.status.right_arm_length_multiplier,   # 開始値
		1.0,   # 終了値
		0.5    # 何秒かけて伸ばすか
	)
