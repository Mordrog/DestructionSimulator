tool
extends Spatial

export(NodePath) var from_node:NodePath setget set_from
export(NodePath) var to_node:NodePath setget set_to

var from:PointMass
var to:PointMass

func set_from(new_from_node:NodePath):
	from_node = new_from_node
	if Engine.editor_hint && has_node(new_from_node):
		from = get_node(new_from_node) as PointMass

func set_to(new_to_node:NodePath):
	to_node = new_to_node
	if Engine.editor_hint && has_node(new_to_node):
		to = get_node(new_to_node) as PointMass

func initialize(from:PointMass, to:PointMass):
	self.from = from as PointMass
	self.to   = to as PointMass

func _ready():
	if !from:
		from = get_node(from_node) as PointMass
	if !to:
		to = get_node(to_node) as PointMass
	from.add_neighbor(to)
	to.add_neighbor(from)

func _process(delta):
	if is_instance_valid(from) and is_instance_valid(to):
		if to.is_node_neighbor(from) and from.is_node_neighbor(to):
			translation = (from.translation + to.translation)/2
			if (-to.global_transform.basis.z != Vector3.FORWARD):
				look_at(to.global_transform.origin, Vector3.FORWARD)
			var relation_vector := from.translation - to.translation
			scale.z = relation_vector.length()/2
		else:
			queue_free()
	else:
		queue_free()