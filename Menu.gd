extends Control

onready var stiffness_slider := $VBoxContainer/MarginContainer/HSplitContainer/StiffnessSlider
onready var break_slider := $VBoxContainer/MarginContainer2/HSplitContainer/BreakSlider
onready var gravity_slider := $VBoxContainer/MarginContainer3/HSplitContainer/GravitySlider
onready var frame_slider := $VBoxContainer/MarginContainer4/HSplitContainer/FrameSlider
onready var fracture_slider := $VBoxContainer/MarginContainer5/HSplitContainer/FractureSlider

onready var building_object  := preload("res://Building.tscn") as PackedScene

onready var spring_system := get_node("/root/Root/SpringSystem")

var building

var start_position = Vector3.ZERO

func _ready() -> void:
	building = get_node("/root/Root/Building")
	start_position = building.global_transform.origin
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false
	stiffness_slider.value = spring_system.stiffness
	break_slider.value = spring_system.break_length
	gravity_slider.value = spring_system.gravity.y
	frame_slider.value = spring_system.happen_every_x_frame
	fracture_slider.value = Global.fracture_impact_force_breakpoint

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		change_menu()


func _on_ExitButton_pressed() -> void:
	change_menu()


func change_menu():
	visible = !visible
	if (visible):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_StiffnessSlider_value_changed(value: float) -> void:
	print("stiffness changed: " + str(value))
	spring_system.stiffness = value


func _on_BreakSlider_value_changed(value: float) -> void:
	print ("break changed: " + str(value))
	spring_system.break_length = value


func _on_GravitySlider_value_changed(value: float) -> void:
	print("gravity changed: " + str(value))
	spring_system.gravity.y = value

func _on_FrameSlider_value_changed(value: float) -> void:
	print("Calculation every x frame changed: " + str(value))
	spring_system.happen_every_x_frame = value

func _on_FractureSlider_value_changed(value: float) -> void:
	print("fracture changed: " + str(value))
	Global.fracture_impact_force_breakpoint = value

func _on_ResetBuildingButton_pressed() -> void:
	building.rebuild_structure()
#	var structure_dimension = building.structure_dimension
#	building.queue_free()
#	building = building_object.instance()
#	building.name = "Building"
#	building.structure_dimension = structure_dimension
#	owner.add_child(building)
#	building.global_transform.origin = start_position

