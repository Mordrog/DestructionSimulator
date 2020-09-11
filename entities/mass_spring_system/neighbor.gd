class Neighbor:
	var node setget set_node, get_node
	var resting_length
	var break_length
	
	func _init(node, resting_length, break_length) -> void:
		self.node = node
		self.resting_length = resting_length
		self.break_length = break_length
	
	func set_node(new_node):
		node = new_node
	
	func get_node():
		if is_instance_valid(node):
			return node
		else:
			return null
