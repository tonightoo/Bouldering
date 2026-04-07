class_name FallingStrategy
extends HoldBehaviorStrategy

@export var fall_time := 2.0
@export var respawn_time := 3.0

var fall_velocity := 0.0
var is_falling := false
var touched_time := -1.0

func update(hold: HoldBehavior, delta: float) -> void:
	if hold.is_grabbed_either and touched_time < 0.0:
		touched_time = 0.0

	if is_falling:
		fall_velocity += 980.0 * delta
		hold.global_position.y += fall_velocity * delta
		if hold.global_position.y > hold.base_position.y + 500:
			hold.visible = false
			is_falling = false
			touched_time = -1.0
			fall_velocity = 0
			hold.start_respawn(respawn_time)

	if hold.respawn_timer > 0.0:
		return

	if touched_time >= 0.0 and not is_falling:
		touched_time += delta
		if touched_time >= fall_time:
			start_falling(hold)

	#if not is_falling and hold.grabbed_time > fall_time:
	#	start_falling(hold)

			
func start_falling(hold: HoldBehavior) -> void:
	is_falling = true
	hold.enabled = false
	if hold.grabbed_by_left:
		hold.hand_controller.release_left_grab()
	if hold.grabbed_by_right:
		hold.hand_controller.release_right_grab()
		
