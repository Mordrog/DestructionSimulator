extends Node

const Spring = preload("res://entities/mass_spring_system/spring.gd").Spring

var gravity = Vector3(0, -9800*2, 0)
var stiffness = 40000
var break_length = 0.5
var happen_every_x_step = 5

var step_counter = 0

var springs = []
var mass_points = {}

func add_spring(from_node, to_node, spring_node):
	var resting_length = \
			(from_node.translation - to_node.translation).length()
	var new_spring = \
			Spring.new(from_node, to_node, resting_length, spring_node)
	springs.append(new_spring)

	mass_points[from_node.name] = \
			{"handle": from_node, "force": Vector3.ZERO } 
	mass_points[to_node.name] = \
			{"handle": to_node, "force": Vector3.ZERO }

func _physics_process(delta):
	step_counter += 1
	if step_counter >= happen_every_x_step:
		calculate_springs_forces()
		caluclate_mass_points_forces()
		apply_forces()
		step_counter = 0

func calculate_springs_forces():
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

func caluclate_mass_points_forces():
	for key in mass_points.keys():
		if is_instance_valid(mass_points[key]['handle']):
			mass_points[key]['force'] = Vector3.ZERO
		else:
			mass_points.erase(key)

	for spring in springs:
		if mass_points.has(spring.from_node.name):
			mass_points[spring.from_node.name]['force'] += spring.force
		if mass_points.has(spring.to_node.name):
			mass_points[spring.to_node.name]['force'] -= spring.force

func apply_forces():
	for mass_point in mass_points.keys():
		mass_points[mass_point]['handle'].force = \
				mass_points[mass_point]['force'] + gravity
	
