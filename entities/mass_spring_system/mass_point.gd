tool
extends RigidBody
class_name MassPoint

const Neighbor = preload("res://entities/mass_spring_system/neighbor.gd").Neighbor

var force := Vector3.ZERO

var neighbors:Array = []

export(bool) var is_static = false setget set_is_static

func set_is_static(new_value):
	is_static = new_value
	if is_static:
		mode = RigidBody.MODE_STATIC
	else:
		mode = RigidBody.MODE_RIGID


func add_neighbor(point_mass, break_length):
	var resting_length = (point_mass.translation - translation).length()
	neighbors.append(Neighbor.new(point_mass, resting_length, break_length))

func remove_neighbor(node):
	for neighbor in neighbors:
		if neighbor.node == node:
			neighbors.erase(neighbor)

func is_node_neighbor(node):
	for neighbor in neighbors:
		if neighbor.node == node:
			return true
	return false


func _process(delta):
	for neighbor in neighbors:
		if not neighbor.node:
			neighbors.erase(neighbor)

func _physics_process(delta: float) -> void:
	if not Engine.editor_hint and not is_static:
		add_central_force(force * pow( delta, 2.0 ))


func _shatter(additional_velocity: Vector3 = Vector3.ZERO) -> void:
	pass