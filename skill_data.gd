class_name SkillData
extends Resource

enum Rank {
	NORMAL,
	RARE,
	EPIC,
	LEGENDARY,
}

@export var id: int
@export var texture: Texture2D
@export var name: String = ""
@export var rank: Rank = Rank.NORMAL
@export_multiline var description: String = ""
@export var cool_time: float = 10.0
