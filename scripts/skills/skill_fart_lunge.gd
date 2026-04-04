class_name SkillFartLunge
extends SkillLogic

var life_on_execute: int
var bonus_amount: float


func execute(key: String, player: Player, stage: Stage):
	if player.observation_controller.is_observation:
		return
	
	if not is_ready():
		return

	GlobalData.status.is_triggered_fart_lunge = true
	GlobalData.status.fart_num += 1
	player.fart_particle.restart()
	player.fart_particle.visible = false
	player.fart_particle.visible = true
	player.fart_particle.emitting = false
	player.fart_particle.emitting = true
	start_cooldown()
