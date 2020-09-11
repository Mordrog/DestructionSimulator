extends Area

var timeout = 0.05
var num_of_shatter = 0

func _process(delta: float) -> void:
	timeout -= delta
	if timeout < 0:
		queue_free()

func _on_Explosion_body_entered(body: Node) -> void:
	if body is RigidBody:
		if body is MassPoint and num_of_shatter <= 0:
			body._shatter()
			num_of_shatter += 1
		else:
			body.queue_free()
