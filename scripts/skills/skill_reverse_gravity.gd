class_name SkillReverseGravity
extends SkillLogic

var life_on_execute: int
var bonus_amount: float

func execute(key: String, player: Player, stage: Stage):
	if player.observation_controller.is_observation:
		return
	
	if not is_ready():
		return

	life_on_execute = GlobalData.status.remaining_life
	player.body.gravity_scale *= -1

	if GlobalData.status.get_gravity() >= 0:
		player.body.global_position.y -= 1
		GlobalData.status.gravity_bonus -= 1960
		bonus_amount = -1960
	else:
		player.body.global_position.y -= 1
		GlobalData.status.gravity_bonus += 1960 
		bonus_amount = 1960

	var tween = player.camera.create_tween()
	player.vignette_rect.visible = true
	tween.tween_property(player.vignette_rect.material, "shader_parameter/vignette_opacity", 0.9, 0.05)
	tween.tween_property(player.camera, "zoom", Vector2(1.1, 1.1), 0.1)
	var target_rotation = player.camera.rotation + PI
	tween.parallel().tween_property(player.body, "rotation", target_rotation, 0.1)
	tween.parallel().tween_property(player.camera, "rotation", target_rotation, 0.18).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(player.camera, "zoom", Vector2(1.0, 1.0), 0.1)
	start_cooldown()
	player.get_tree().create_timer(5.0).timeout.connect(
		func(): restore_gravity(player)
	)
	
func restore_gravity(player: Player) -> void:
	if life_on_execute != GlobalData.status.remaining_life:
		life_on_execute = 0
		return
	player.vignette_rect.visible = false
	var tween = player.camera.create_tween()
	tween.tween_property(player.camera, "zoom", Vector2(1.1, 1.1), 0.1)
	var target_rotation = player.camera.rotation + PI
	tween.parallel().tween_property(player.body, "rotation", target_rotation, 0.1)
	tween.parallel().tween_property(player.camera, "rotation", target_rotation, 0.18).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(player.camera, "zoom", Vector2(1.0, 1.0), 0.1)
	
	player.body.gravity_scale /= -1
	GlobalData.status.gravity_bonus -= bonus_amount

	
