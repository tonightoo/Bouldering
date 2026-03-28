extends Node

@export_group("Player Database")
@export var config: PlayerConfig
@export var status: PlayerStatus

@export_group("Hold Database")
@export var c_rank_holds: Array[HoldData]
@export var b_rank_holds: Array[HoldData]
@export var a_rank_holds: Array[HoldData]
@export var s_rank_holds: Array[HoldData]
@export var goal_holds: Array[HoldData]

@export_group("Skill Database")
@export var normal_skills: Array[SkillData]
@export var rare_skills: Array[SkillData]
@export var epic_skills: Array[SkillData]
@export var legendary_skills: Array[SkillData]

var rng: RandomNumberGenerator

func _ready() -> void:
	config = PlayerConfig.new()
	status = PlayerStatus.new(config)
	rng = RandomNumberGenerator.new()

func pick_up_one_hold() -> HoldData:
	var hold_rand_value = rng.randf_range(0.0, 100.0)
	if hold_rand_value <= status.get_c_rank_probability():
		return c_rank_holds.pick_random()
	elif hold_rand_value <= status.get_c_rank_probability() + status.get_b_rank_probability():
		return b_rank_holds.pick_random()
	elif hold_rand_value <= status.get_c_rank_probability() + status.get_b_rank_probability() + status.get_a_rank_probability():
		return a_rank_holds.pick_random()
	else:
		return s_rank_holds.pick_random()

func pick_up_one_skill() -> SkillData:
	var skill_rand_value = rng.randf_range(0.0, 100.0)
	if skill_rand_value <= status.get_normal_drop_rate():
		return normal_skills.pick_random()
	elif skill_rand_value <= status.get_normal_drop_rate() + status.get_rare_drop_rate():
		return rare_skills.pick_random()
	elif skill_rand_value <= status.get_normal_drop_rate() + status.get_rare_drop_rate() + status.get_epic_drop_rate():
		return epic_skills.pick_random()
	else:
		return legendary_skills.pick_random()
		


func get_rank_color(rank: SkillData.Rank) -> Color:
	match rank:
		SkillData.Rank.NORMAL: return Color("#4D65B4FF")
		SkillData.Rank.RARE: return Color("#1EBC73FF")
		SkillData.Rank.EPIC: return Color("#A884F3FF")
		SkillData.Rank.LEGENDARY: return Color("#F9C22BFF")
	return Color.WHITE
