tool
extends Control

onready var stiffness_slider := $VBoxContainer/MarginContainer/HSplitContainer/StiffnessSlider
onready var break_slider := $VBoxContainer/MarginContainer2/HSplitContainer/BreakSlider
onready var gravity_slider := $VBoxContainer/MarginContainer3/HSplitContainer/GravitySlider
onready var frame_slider := $VBoxContainer/MarginContainer4/HSplitContainer/FrameSlider
onready var fracture_slider := $VBoxContainer/MarginContainer5/HSplitContainer/FractureSlider


export(NodePath) var spring_system_path
onready var spring_system := get_node(spring_system_path)

export(NodePath) var building_path
onready var building := get_node(building_path)
var start_position = Vector3.ZERO


func _enter_tree() -> void:
	get_tree().emit_signal("node_configuration_warning_changed", self)

func _get_configuration_warning() -> String:
	var warnings : = PoolStringArray()
	if not spring_system_path:
		warnings.append("%s requiers Mass Spring System node path" % name)
	if not building_path:
		warnings.append("%s requiers Building node path" % name)
	return warnings.join("\n")

func _ready() -> void:
	if not Engine.editor_hint:
		start_position = building.global_transform.origin
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		visible = false
		stiffness_slider.value = spring_system.stiffness
		break_slider.value = spring_system.break_length
		gravity_slider.value = -spring_system.gravity.y
		frame_slider.value = spring_system.happen_every_x_step
		fracture_slider.value = Global.fracture_impact_force_breakpoint

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		change_menu()


func _on_ExitButton_pressed() -> void:
	change_menu()

func change_menu():
	if not Engine.editor_hint:
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
	spring_system.gravity.y = -value

func _on_FrameSlider_value_changed(value: float) -> void:
	print("Calculation every x step changed: " + str(value))
	spring_system.happen_every_x_step = value

func _on_FractureSlider_value_changed(value: float) -> void:
	print("fracture changed: " + str(value))
	Global.fracture_impact_force_breakpoint = value

func _on_ResetBuildingButton_pressed() -> void:
	building.rebuild_structure()

