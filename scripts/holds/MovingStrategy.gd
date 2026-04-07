class_name MovingStrategy
extends HoldBehaviorStrategy

@export var move_dir := Vector2.RIGHT
@export var move_amplitude := 100.0
@export var move_period := 2.0
@export var move_phase := 0.0

func update(hold: HoldBehavior, delta: float) -> void:
	if move_period <= 0.0:
		return
	
	var t = Time.get_ticks_msec() / 1000.0
	var phase = (t + move_phase) * TAU / move_period
	hold.global_position = hold.base_position + move_dir.normalized() * sin(phase) * move_amplitude
