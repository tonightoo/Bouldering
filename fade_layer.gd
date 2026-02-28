extends CanvasLayer

@onready var fade_animation = $FadeRect/FadeAnimation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


func play() -> void:
	visible = true
	fade_animation.play("fade_animation")

func connect_finished(callable: Callable) -> void:
	fade_animation.connect("animation_finished", callable)
