class_name SkillLogic
extends Resource

signal activated
signal finished
signal state_changed(new_state: SkillState)

@export var cooldown_time: float = 20.0 # インスペクターでスキルごとに設定
var next_usable_time: float = 0.0 # 次に使える時刻（ミリ秒）

enum SkillState { 
	IDLE,			# 待機
	PHASE_1,		# 1段階目（1回目の入力後）
	PHASE_2,		# 2段階目（2回目の入力後）
	PHASE_3,		# 3段階目（3回目の入力後）
	EXECUTING,		# 最終確定・発動中
	COOLDOWN		# 終わって休み
}
var current_state = SkillState.IDLE

func execute(key: String, player: Player, stage: Stage):
	pass

func is_ready() -> bool:
	return Time.get_ticks_msec() >= next_usable_time

func start_cooldown():
	next_usable_time = Time.get_ticks_msec() + (cooldown_time * 1000.0)

# 残り時間を秒で返す（UI表示用）
func get_remaining_time() -> float:
	var remaining = next_usable_time - Time.get_ticks_msec()
	return max(0.0, remaining / 1000.0)
