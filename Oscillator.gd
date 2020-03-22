extends Spatial

func _physics_process(delta):
	for child in get_children():
		if !child.is_static:
			child.get_force()
		
	for child in get_children():
		if !child.is_static:
			child.verlet(delta)