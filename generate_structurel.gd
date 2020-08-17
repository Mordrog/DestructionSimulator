tool
extends Spatial

export(float) var block_size = 5 setget set_block_size

export(float) var stiffness = 20000
export(float) var break_length = 2

export(Vector3) var structure_dimension = Vector3(4, 7, 4) setget set_structure_dimension

var spring_system
export(NodePath) var spring_system_path

var spring_object  := load("res://Link.tscn") as PackedScene
var point_mass_object := load("res://Brick.tscn") as PackedScene



func _ready() -> void:
	if has_node(spring_system_path):
		spring_system = get_node(spring_system_path)
	rebuild_structure()

func set_structure_dimension(new_structure_dimension):
	if new_structure_dimension.x >= 0 && new_structure_dimension.y >= 0 && new_structure_dimension.z >= 0:
		structure_dimension = new_structure_dimension
		if Engine.is_editor_hint():
			rebuild_structure()

func set_block_size(new_block_size):
	if new_block_size > 0:
		block_size = new_block_size
		if Engine.is_editor_hint():
			rebuild_structure()

func rebuild_structure():
	for child in $PointMasses.get_children():
		child.queue_free()
	for child in $Springs.get_children():
		child.queue_free()
	
	var structure = []
	structure.resize(structure_dimension.x)
	for x in range(structure_dimension.x):
		structure[x] = []
		structure[x].resize(structure_dimension.y)
		for y in range(structure_dimension.y):
			structure[x][y] = []
			structure[x][y].resize(structure_dimension.z)
	
	var start_y = block_size/2
	var start_x = -(structure_dimension.x/2 * block_size) + block_size/2
	var start_z = -(structure_dimension.z/2 * block_size) + block_size/2
	for y in range(structure_dimension.y):
		for x in range(structure_dimension.x):
			for z in range(structure_dimension.z):
				var new_point_mass := point_mass_object.instance()
				new_point_mass.size = block_size
				if y == 0:
					new_point_mass.is_static = true
				new_point_mass.translation = Vector3(start_x + (x * block_size), start_y + (y * block_size), start_z + (z * block_size))
				$PointMasses.add_child(new_point_mass)
				structure[x][y][z] = new_point_mass
	
	for y in range(structure_dimension.y):
		for x in range(structure_dimension.x):
			for z in range(structure_dimension.z):
				if y > 0:
					var new_spring := spring_object.instance()
					new_spring.initialize(structure[x][y][z], structure[x][y - 1][z])
					spring_system.add_spring(structure[x][y][z], structure[x][y - 1][z], stiffness, break_length, new_spring)
					$Springs.add_child(new_spring)
				if x > 0:
					var new_spring := spring_object.instance()
					new_spring.initialize(structure[x][y][z], structure[x - 1][y][z])
					spring_system.add_spring(structure[x][y][z], structure[x - 1][y][z], stiffness, break_length, new_spring)
					$Springs.add_child(new_spring)
				if z > 0:
					var new_spring := spring_object.instance()
					new_spring.initialize(structure[x][y][z], structure[x][y][z - 1])
					spring_system.add_spring(structure[x][y][z], structure[x][y][z - 1], stiffness, break_length, new_spring)
					$Springs.add_child(new_spring)
#				if y > 0 and z > 0 and x > 0:
#					var new_spring := spring_object.instance()
#					new_spring.initialize(structure[x][y][z], structure[x - 1][y - 1][z - 1])
#					spring_system.add_spring(structure[x][y][z], structure[x - 1][y - 1][z - 1], stiffness, break_length/2, new_spring)
#					$Springs.add_child(new_spring)
#				if y > 0 and z > 0 and x < structure_dimension.x - 1:
#					var new_spring := spring_object.instance()
#					new_spring.initialize(structure[x][y][z], structure[x + 1][y - 1][z - 1])
#					spring_system.add_spring(structure[x][y][z], structure[x + 1][y - 1][z - 1], stiffness, break_length/2, new_spring)
#					$Springs.add_child(new_spring)

#func _physics_process(delta):
#	if not Engine.editor_hint:
#		for child in $PointMasses.get_children():
#			child.get_force()
#
#		for child in $PointMasses.get_children():
#			child.verlet(delta)
