class_name SkillAntiGravity
extends SkillLogic



func execute(key: String, player: Player, stage: Stage):
	if player.observation_controller.is_observation:
		return

	player.body.gravity_scale *= -1
	if GlobalData.status.get_gravity() >= 0:
		GlobalData.status.gravity_bonus = -1960
		player.body.global_position.y -= 1
	else:
		GlobalData.status.gravity_bonus = 0
		player.body.global_position.y += 1
		
	
func restore_gravity(player: Player) -> void:
	player.body.gravity_scale *= -1
	GlobalData.status.gravity_bonus = 0.0	

	
