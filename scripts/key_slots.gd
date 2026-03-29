class_name KeySlots
extends Control

@export var slot_texture: Texture2D

@onready var slot_sprite = $SlotsSprite
@onready var up_button: SlotButton = $SlotsSprite/UpButton
@onready var down_button: SlotButton = $SlotsSprite/DownButton
@onready var left_button: SlotButton = $SlotsSprite/LeftButton
@onready var right_button: SlotButton = $SlotsSprite/RightButton



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slot_sprite.texture = slot_texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
