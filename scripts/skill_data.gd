class_name SkillData
extends Resource

enum SkillRank {
	NORMAL,
	RARE,
	EPIC,
	LEGENDARY,
}

enum SkillType {
	ACTIVE,
	PASSIVE,
}

@export var id: String
@export var texture: Texture2D
@export var name: String = ""
@export var rank: SkillRank = SkillRank.NORMAL
@export_multiline var description: String = ""
@export var cool_time: float = 10.0
@export var type: SkillType = SkillType.PASSIVE
@export var logic: SkillLogic = SkillLogic.new()
