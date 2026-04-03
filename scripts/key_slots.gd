class_name KeySlots
extends Control

@export var slot_texture: Texture2D

@onready var slot_sprite = $SlotsSprite
@onready var up_button: SlotButton = $SlotsSprite/Up/UpButton
@onready var down_button: SlotButton = $SlotsSprite/Down/DownButton
@onready var left_button: SlotButton = $SlotsSprite/Left/LeftButton
@onready var right_button: SlotButton = $SlotsSprite/Right/RightButton

@onready var up_progress: TextureProgressBar = $SlotsSprite/Up/UpProgressBar
@onready var down_progress: TextureProgressBar = $SlotsSprite/Down/DownProgressBar
@onready var left_progress: TextureProgressBar = $SlotsSprite/Left/LeftProgressBar
@onready var right_progress: TextureProgressBar = $SlotsSprite/Right/RightProgressBar

@onready var up_label: Label = $SlotsSprite/Up/UpLabel
@onready var down_label: Label = $SlotsSprite/Down/DownLabel
@onready var left_label: Label = $SlotsSprite/Left/LeftLabel
@onready var right_label: Label = $SlotsSprite/Right/RightLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slot_sprite.texture = slot_texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
