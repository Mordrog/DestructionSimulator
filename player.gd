extends KinematicBody

onready var missile_object := preload("res://Missile.tscn") as PackedScene
onready var ball_object  := preload("res://Ball.tscn") as PackedScene
onready var laser_object := preload("res://Laser.tscn") as PackedScene
onready var building_object  := preload("res://Building.tscn") as PackedScene



var selected_item = Global.Items.BALL

onready var camera = $Pivot/Camera

var max_speed = 50
var mouse_sensitivity = 0.002  # radians/pixel

var velocity = Vector3()

func shoot_ball():
	var new_ball := ball_object.instance()
	get_owner().add_child(new_ball)
	new_ball.global_transform.origin = global_transform.origin
	new_ball.apply_impulse(Vector3(0, 0, 0), -camera.global_transform.basis.z.normalized() * 250)

func shoot_missile():
	var new_missile := missile_object.instance()
	owner.add_child(new_missile)
	new_missile.global_transform.origin = global_transform.origin
	new_missile.rotation = rotation
	new_missile.velocity = -camera.global_transform.basis.z.normalized() * 200 / 2

func shoot_laser():
	var center_position = get_viewport().size / 2
	var ray_from = camera.project_ray_origin(center_position)
	var ray_to = ray_from + camera.project_ray_normal(center_position) * 100
	
	var new_laser := laser_object.instance()
	new_laser.init(ray_from, ray_to, Color(1,0,0), 0.2)
	owner.add_child(new_laser)
	
	var ray_result = get_world().direct_space_state.intersect_ray(ray_from, ray_to, [self])
	if !ray_result.empty():
		if ray_result["collider"] is RigidBody:
			var grabbed_object = ray_result["collider"]
			if grabbed_object is PointMass:
				grabbed_object.shatter(camera.global_transform.basis.z.normalized() * 5)
			else:
				grabbed_object.queue_free()

func shoot_stuff():
	if selected_item == Global.Items.BALL:
		shoot_ball()
	elif selected_item == Global.Items.LASER:
		shoot_laser()
	elif selected_item == Global.Items.ROCKET:
		shoot_missile()
	else:
		print("Unkonwn item")

func reset_building():
	var center_position = get_viewport().size / 2
	var ray_from = camera.project_ray_origin(center_position)
	var ray_to = ray_from + camera.project_ray_normal(center_position) * 100

	var ray_result = get_world().direct_space_state.intersect_ray(ray_from, ray_to, [self])
	if !ray_result.empty():
		if ray_result["position"]:
			var building := building_object.instance()
			building.global_transform.origin = ray_result["position"]
			owner.add_child(building)
			

func get_input():
	var input_dir = Vector3()
	# desired move in camera direction
	if Input.is_action_pressed("move_forward"):
		input_dir += -camera.global_transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_dir += camera.global_transform.basis.z
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
			shoot_stuff()


func _physics_process(delta):
	var desired_velocity = get_input() * max_speed

	velocity.x = desired_velocity.x
	velocity.y = desired_velocity.y
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)
