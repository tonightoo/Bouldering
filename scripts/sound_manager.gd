extends Node

# Dictionaryでリソースを保持
# @export を使うとインスペクターから [Key: String, Value: Resource] の形で編集できて便利！
@export var sound_library: Dictionary = {
	"grab": [preload("res://assets/se/grab1.wav"), preload("res://assets/se/grab2.wav"), preload("res://assets/se/grab3.wav"), preload("res://assets/se/grab4.wav")],
}

var audio_player: AudioStreamPlayer

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.volume_db = -10.0
	add_child(audio_player)

# 再生用の共通関数
func play_se(sound_name: String, pitch: float = 1.0):
	if sound_library.has(sound_name):
		audio_player.stream = sound_library[sound_name].pick_random()
		audio_player.pitch_scale = pitch
		audio_player.bus = "SFX"
		audio_player.play()
	else:
		push_error("SoundManager: '" + sound_name + "' が見つかりません！")
