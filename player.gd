extends KinematicBody

onready var missile_object := preload("res://Missile.tscn") as PackedScene
onready var ball_object  := preload("res://Ball.tscn") as PackedScene

onready var camera = $Pivot/Camera

var max_speed = 50
var mouse_sensitivity = 0.002  # radians/pixel

var velocity = Vector3()

func _init() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func shoot_ball():
	var new_ball := ball_object.instance()
	get_owner().add_child(new_ball)
	new_ball.global_transform.origin = global_transform.origin
	new_ball.apply_impulse(Vector3(0, 0, 0), -camera.global_transform.basis.z.normalized() * 1000 / 2)

func shoot_missile():
	var new_missile := missile_object.instance()
	owner.add_child(new_missile)
	new_missile.global_transform.origin = global_transform.origin
	new_missile.rotation = rotation
	new_missile.velocity = -camera.global_transform.basis.z.normalized() * 200 / 2

func hitscan_destroy():
	var center_position = get_viewport().size / 2
	var ray_from = camera.project_ray_origin(center_position)
	var ray_to = ray_from + camera.project_ray_normal(center_position) * 100

	var ray_result = get_world().direct_space_state.intersect_ray(ray_from, ray_to, [self])
	if !ray_result.empty():
		if ray_result["collider"] is RigidBody:
			var grabbed_object = ray_result["collider"]
			grabbed_object.queue_free()

func get_input():
	var input_dir = Vector3()
	# desired move in camera direction
	if Input.is_action_pressed("move_forward"):
		input_dir += -camera.global_transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_dir += camera.global_transform.basis.z
	if Input.is_action_pressed("move_up"):
		input_dir += camera.global_transform.basis.y
	if Input.is_action_pressed("move_down"):
		input_dir += -camera.global_transform.basis.y
	if Input.is_action_pressed("strafe_left"):
		input_dir += -camera.global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += camera.global_transform.basis.x
	input_dir = input_dir.normalized()
	return input_dir

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -1.2, 1.2)
	if event is InputEventMouseButton:
		var mouse_button = (event as InputEventMouseButton)
		if mouse_button.button_index == BUTTON_LEFT && mouse_button.pressed:
			shoot_missile()
	if event is InputEventKey:
		if (event as InputEventKey).scancode == KEY_ESCAPE:
			get_tree().quit()

func _physics_process(delta):
	var desired_velocity = get_input() * max_speed

	velocity.x = desired_velocity.x
	velocity.y = desired_velocity.y
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)
