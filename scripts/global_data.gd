extends Node

@export_group("Player Database")
@export var configs: Dictionary[String, PlayerConfig] = {}
@export var status: PlayerStatus

@export var selected_character_name: String = "Kabeoji"

@export_group("Hold Database")
@export var c_rank_holds: Array[HoldData]
@export var b_rank_holds: Array[HoldData]
@export var a_rank_holds: Array[HoldData]
@export var s_rank_holds: Array[HoldData]
@export var goal_holds: Array[HoldData]

@export_group("Skill Database")
@export var empty_skill: SkillData
@export var normal_skills: Array[SkillData]
@export var rare_skills: Array[SkillData]
@export var epic_skills: Array[SkillData]
@export var legendary_skills: Array[SkillData]


var signals: GlobalSignal

var rng: RandomNumberGenerator

func _ready() -> void:
	#set_character()
	rng = RandomNumberGenerator.new()
	signals = GlobalSignal.new()

func set_character() -> void:
	status = PlayerStatus.new(configs[selected_character_name])

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
		


func get_rank_color(rank: SkillData.SkillRank) -> Color:
	match rank:
		SkillData.SkillRank.NORMAL: return Color("#4D65B4FF")
		SkillData.SkillRank.RARE: return Color("#1EBC73FF")
		SkillData.SkillRank.EPIC: return Color("#A884F3FF")
		SkillData.SkillRank.LEGENDARY: return Color("#F9C22BFF")
	return Color.WHITE
