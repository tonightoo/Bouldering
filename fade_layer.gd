extends CanvasLayer

@onready var fade_animation = $FadeRect/FadeAnimation
@onready var fade_inout = $FadeRect/FadeInOut

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	connect_inout_finished(unvisible)


func play() -> void:
	visible = true
	fade_animation.play("fade_animation")

func play_inout() -> void:
	visible = true
	fade_inout.play("FadeInOut")

func unvisible(anim_name: StringName) -> void:
	visible = false

func connect_finished(callable: Callable) -> void:
	fade_animation.connect("animation_finished", callable)

func connect_inout_finished(callable: Callable) -> void:
	fade_inout.connect("animation_finished", callable)
