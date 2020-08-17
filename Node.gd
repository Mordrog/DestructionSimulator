tool
extends RigidBody
class_name PointMass

onready var brick_material = preload("res://Brick3.material")
onready var Neighbor = preload("res://Neighbor.gd")
onready var brick_fractured = preload("res://BrickFractured.tscn")

export(float) var size = 5 setget set_size
export(bool) var is_static = false setget set_is_static

var gravity:Vector3 = Vector3(0, -9800*2, 0)
var force                := Vector3.ZERO


var last_linear_velocity = Vector3.ZERO

var neighbors:Array = []

func set_size(new_size):
	if new_size > 0:
		size = new_size
		update_block()

func set_is_static(new_value):
	is_static = new_value
	if new_value:
		mode = RigidBody.MODE_STATIC
	else:
		mode = RigidBody.MODE_RIGID

func update_block():
	var new_cube = CubeMesh.new()
	new_cube.size = Vector3(size, size, size)
	new_cube.material = brick_material
	$MeshInstance.mesh = new_cube
	$MeshInstance.set_material_override(brick_material)

	var new_box = BoxShape.new()
	new_box.extents = Vector3(size, size, size)/2
	$CollisionShape.shape = new_box

func add_neighbor(point_mass, break_length):
	var resting_length = (point_mass.translation - translation).length()
	neighbors.append(Neighbor.Neighbor.new(point_mass, resting_length, break_length))

func remove_neighbor(node):
	for neighbor in neighbors:
		if neighbor.node == node:
			neighbors.erase(neighbor)

func is_node_neighbor(node):
	for neighbor in neighbors:
		if neighbor.node == node:
			return true
	return false

func _ready():
	update_block()

func _process(delta):
	for neighbor in neighbors:
		if not neighbor.node:
			neighbors.erase(neighbor)


func _physics_process(delta: float) -> void:
	last_linear_velocity = linear_velocity
	if not Engine.editor_hint and not is_static:
		var val_force = force
		val_force += gravity
		add_central_force(force * pow( delta, 2.0 ))

func shatter(additional_velocity = Vector3.ZERO):
	var fractured_brick = brick_fractured.instance()
	get_parent().add_child(fractured_brick)
	fractured_brick.scale = scale*size/2.5
	fractured_brick.transform = transform
	for brick_part in fractured_brick.get_children():
			brick_part.linear_velocity = linear_velocity + additional_velocity
				
	queue_free()

func _on_Brick_body_entered(body: Node) -> void:
	var impact_force = last_linear_velocity.length()
	
	if body is RigidBody:
		impact_force -= body.linear_velocity.length()

	impact_force = abs(impact_force)
	if impact_force > Global.fracture_impact_force_breakpoint:
		shatter()