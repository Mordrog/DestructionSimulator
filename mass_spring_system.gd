extends Node

const Spring = preload("res://new_spring.gd").NewSpring

var gravity = Vector3(0, 9800*2, 0)
var stiffness = 40000
var break_length = 0.5
var happen_every_x_frame = 5

var frame_counter = 0

var springs = []
var mass_points_force = {}

func add_spring(from_node, to_node, stiffness, break_length, spring_node):
	var resting_length = (from_node.translation - to_node.translation).length()
	var new_spring = Spring.new(from_node, to_node, stiffness, resting_length, break_length, spring_node)
	springs.append(new_spring)
	mass_points_force[from_node] = Vector3.ZERO
	mass_points_force[to_node] = Vector3.ZERO

func _physics_process(delta):
	if not Engine.editor_hint:
		frame_counter += 1
		if frame_counter >= happen_every_x_frame:
			calculate_spring_force()
			caluclate_mass_points_force()
			apply_force(delta)
			frame_counter = 0

func calculate_spring_force():
	var remove_springs = []
	for spring in springs:
		if spring.to_node and spring.from_node:
			var distance = spring.to_node.translation - spring.from_node.translation
			var difference = distance.length() - spring.resting_length
			spring.force = stiffness * max(1, difference) * distance.normalized()

			if difference > break_length:
				remove_springs.append(spring)
		else:
			remove_springs.append(spring)

	for spring in remove_springs:
		springs.erase(spring)

func caluclate_mass_points_force():
	var remove_mass_points = []
	
	for mass_point in mass_points_force:
		if is_instance_valid(mass_point):
			mass_points_force[mass_point] = Vector3.ZERO
		else:
			remove_mass_points.append(mass_point)
	
	for mass_point in remove_mass_points:
		mass_points_force.erase(mass_point)
	
	for spring in springs:
		mass_points_force[spring.from_node] += spring.force
		mass_points_force[spring.to_node] -= spring.force



func apply_force( delta ):
	for mass_point in mass_points_force:
		mass_point.force = mass_points_force[mass_point] - gravity