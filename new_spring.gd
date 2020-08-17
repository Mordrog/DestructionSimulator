class NewSpring:
	var from_node setget set_from_node,get_from_node
	var to_node setget set_to_node,get_to_node
	var stiffness
	var resting_length
	var break_length
	var spring_node
	
	var force
	
	func _init(from_node, to_node, stiffness, resting_length, break_length, spring_node) -> void:
		self.from_node = from_node
		self.to_node = to_node
		self.stiffness = stiffness
		self.resting_length = resting_length
		self.break_length = break_length
		self.spring_node = spring_node
		
		self.force = Vector3.ZERO
	
	func set_from_node(new_from_node):
		from_node = new_from_node
	
	func get_from_node():
		if is_instance_valid(from_node):
			return from_node
		else:
			return null
	
	func set_to_node(new_to_node):
		to_node = new_to_node
	
	func get_to_node():
		if is_instance_valid(to_node):
			return to_node
		else:
			return null

	func _notification(what):
		if what == NOTIFICATION_PREDELETE:
			if is_instance_valid(self.spring_node):
				self.spring_node.queue_free()
			if is_instance_valid(from_node):
				from_node.force = Vector3.ZERO
				from_node.remove_neighbor(to_node)
			if is_instance_valid(to_node):
				to_node.force = Vector3.ZERO
				to_node.remove_neighbor(from_node)
