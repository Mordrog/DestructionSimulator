tool
extends MassPoint

export(Material) var brick_material:Material
export(PackedScene) var brick_fractured_node:PackedScene

export(float) var size = 5 setget set_size

var last_linear_velocity = Vector3.ZERO


func set_size(new_size):
	if new_size > 0:
		size = new_size
		update_block_size(size)

func update_block_size(size: float):
	var new_cube = CubeMesh.new()
	new_cube.size = Vector3(size, size, size)
	new_cube.material = brick_material
	$MeshInstance.mesh = new_cube
	$MeshInstance.set_material_override(brick_material)

	var new_box = BoxShape.new()
	new_box.extents = Vector3(size, size, size)/2
	$CollisionShape.shape = new_box


func _ready():
	update_block_size(size)

func _physics_process(delta: float) -> void:
	last_linear_velocity = linear_velocity


func _shatter(additional_velocity = Vector3.ZERO):
	var fractured_brick = brick_fractured_node.instance()
	get_parent().add_child(fractured_brick)
	fractured_brick.scale = scale*size/2.5
	fractured_brick.transform = transform
	for brick_part in fractured_brick.get_children():
			brick_part.linear_velocity = linear_velocity + additional_velocity

	queue_free()


func _on_Brick_body_entered(body: Node) -> void:
	var impact_velocity = last_linear_velocity
	
	if body is RigidBody:
		impact_velocity -= body.linear_velocity

	var impact_force = impact_velocity.length()
	if impact_force > Global.fracture_impact_force_breakpoint:
		_shatter()