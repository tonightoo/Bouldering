class_name SkillAirDyno
extends SkillLogic

var life_on_execute: int

func execute(key: String, player: Player, stage: Stage):
	if player.observation_controller.is_observation:
		return
	
	if not is_ready():
		return
		
	if player.body.get_contact_count() > 0:
		return

	GlobalData.status.is_triggered_air_dyno = true
	start_cooldown()
