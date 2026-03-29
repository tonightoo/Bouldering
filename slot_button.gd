class_name SlotButton
extends TextureButton

@onready var default_color = modulate
var action_name: String

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func _on_mouse_entered():
	modulate = Color(2.0, 2.0, 2.0)

func _on_mouse_exited():
	modulate = default_color

func _on_button_down():
	modulate = Color(0.7, 0.7, 0.7)
	scale = Vector2(0.95, 0.95)

func _on_button_up():
	modulate = Color(1.2, 1.2, 1.2)
	scale = Vector2(1.0, 1.0)


func _on_focus_entered() -> void:
	modulate = Color(2.0, 2.0, 2.0)


func _on_focus_exited() -> void:
	modulate = default_color
