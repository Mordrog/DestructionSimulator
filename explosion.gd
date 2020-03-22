extends Area

var timeout = 0.1

func _process(delta: float) -> void:
	timeout -= delta
	if timeout < 0:
		queue_free()

func _on_Explosion_body_entered(body: Node) -> void:
	if body is RigidBody:
		body.queue_free()
