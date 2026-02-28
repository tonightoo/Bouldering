extends CanvasLayer


@onready var first_task = $TasksContainer/FirstTask
@onready var second_task = $TasksContainer/SecondTask
@onready var third_task = $TasksContainer/ThirdTask
@onready var fourth_task = $TasksContainer/FourthTask
@onready var fifth_task = $TasksContainer/FifthTask
@onready var sixth_task = $TasksContainer/SixthTask
@onready var seventh_task = $TasksContainer/SeventhTask
@onready var eighth_task = $TasksContainer/EighthTask
const CLEAR_TEXT: String = "OK!"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func is_clear_all() -> bool:
	return (first_task.text == CLEAR_TEXT and 
			second_task.text == CLEAR_TEXT and
			third_task.text == CLEAR_TEXT and
			fourth_task.text == CLEAR_TEXT and
			fifth_task.text == CLEAR_TEXT and
			sixth_task.text == CLEAR_TEXT and
			seventh_task.text == CLEAR_TEXT and
			eighth_task.text == CLEAR_TEXT)
			
func reset_tutorial_tasks() -> void:
	first_task.text = CLEAR_TEXT
	second_task.text = CLEAR_TEXT
	third_task.text = CLEAR_TEXT
	fourth_task.text = CLEAR_TEXT
	fifth_task.text = CLEAR_TEXT
	sixth_task.text = CLEAR_TEXT
	seventh_task.text = CLEAR_TEXT
	eighth_task.text = CLEAR_TEXT
	visible = false
	
func set_text(index: int, text: String) -> void:
	match index:
		1:
			first_task.text = text
		2:
			second_task.text = text
		3:
			third_task.text = text
		4:
			fourth_task.text = text
		5:
			fifth_task.text = text
		6:
			sixth_task.text = text
		7:
			seventh_task.text = text
		8:
			eighth_task.text = text
		_:
			assert("out of range in TutorialTasks")

func apply_visible() -> void:
	first_task.visible = (first_task.text != CLEAR_TEXT)
	second_task.visible = (second_task.text != CLEAR_TEXT)
	third_task.visible = (third_task.text != CLEAR_TEXT)
	fourth_task.visible = (fourth_task.text != CLEAR_TEXT)
	fifth_task.visible = (fifth_task.text != CLEAR_TEXT)
	sixth_task.visible = (sixth_task.text != CLEAR_TEXT)
	seventh_task.visible = (seventh_task.text != CLEAR_TEXT)
	eighth_task.visible = (eighth_task.text != CLEAR_TEXT)
	visible = true

func set_clear(index: int) -> void:
	set_text(index, CLEAR_TEXT)
