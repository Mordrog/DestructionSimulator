tool
extends RigidBody
class_name PointMass

onready var brick_material = preload("res://Brick.material")
onready var Neighbor = preload("res://Neighbor.gd")

export(float) var size = 5 setget set_size

var stiffness:float = 8000.0
var medium_damping:float = 30.0

var velocity             := Vector3.ZERO
var previous_translation := Vector3.ZERO
var force                := Vector3.ZERO

var neighbors:Array = []

func set_size(new_size):
	if new_size > 0:
		size = new_size
		update_block()

func update_block():
	var new_cube = CubeMesh.new()
	new_cube.size = Vector3(size, size, size)
	new_cube.material = brick_material
	$MeshInstance.mesh = new_cube
	$MeshInstance.set_material_override(brick_material)

	var new_box = BoxShape.new()
	new_box.extents = Vector3(size, size, size)/2
	$CollisionShape.shape = new_box

func add_neighbor(point_mass):
	var resting_length = (point_mass.translation - translation).length()
	neighbors.append(Neighbor.Neighbor.new(point_mass, resting_length))

func _ready():
	update_block()
	previous_translation = translation - velocity * get_physics_process_delta_time()

func _process(delta):
	for neighbor in neighbors:
		if not neighbor.node:
			neighbors.erase(neighbor)

func get_force():
	force = Vector3()
	var remove_neighbors = []
	for neighbor in neighbors:
		if neighbor.node:
			var distance = neighbor.node.translation - translation
			var difference = distance.length() - neighbor.resting_length
			var relative_velocity = neighbor.node.velocity - velocity
			
			var spring_damping = relative_velocity.project(distance)
			
			# use for cloth stretching
			if difference > 0:
				# spring stiffness
				force += stiffness * difference * distance.normalized()
				# spring damping
				force += spring_damping * 1
			
			if difference > 15:
				remove_neighbors.append(neighbor)

	for neighbor in remove_neighbors:
		neighbors.erase(neighbor)
	
	# medium damping
	force -= velocity * medium_damping

func is_node_neighbor(node):
	for neighbor in neighbors:
		if neighbor.node == node:
			return true
	return false

func euler( delta ):
	add_central_force (velocity * delta)
	velocity += force * delta 

func symplectic_euler( delta ):
	velocity += force * delta
	add_central_force (velocity * delta)

func verlet( delta ):
	var new_translation  = 2*translation - previous_translation 
	new_translation     += force * pow( delta, 2.0 )
	
	previous_translation = translation
	add_central_force (force * pow( delta, 2.0 ))
	velocity          = (translation - previous_translation)/delta