# HoldData.gd
extends Resource
class_name HoldData

enum HoldType {
	NORMAL,
	MOVING,
	FALLING,
	FATIGUE,
	SLIPPERY,
	BLOCK,
	RECOVER,
	GOAL,
	GOAL_RIGHT,
	GOAL_LEFT,
}

@export var type: HoldType
@export var size: Vector2
@export var color: Color

# 疲労関係
@export var fatigue_multiplier := 1.0
@export var recover_rate := 0.0

# 落下
@export var fall_time := -1.0
@export var respawn_time := -1.0

# 移動
@export var move_dir := Vector2.ZERO
@export var move_amplitude := 0.0
@export var move_period := 0.0
@export var move_phase := 0.0

# 滑り
@export var slip_speed := 0.0
