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
	FAKE,
	MAGNET,
	ROCKET,
	SPIKE,
	ELECTRIC,
	GOAL,
	GOAL_RIGHT,
	GOAL_LEFT,
}
enum Rank {
	S,
	A,
	B,
	C,
}

@export var type: HoldType
@export var rank: Rank
@export var size: Vector2
@export var color: Color
@export var texture: Texture2D
@export var unknown_texture: Texture2D
@export var fatigue_rate: float = 1.0
@export var recovery_rate: float = 0.0
@export var strategies: Array[HoldBehaviorStrategy] = []
