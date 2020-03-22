extends Area

onready var explosion_object = preload("res://Explosion.tscn") as PackedScene

var velocity = Vector3.ZERO
var timeout = 10

func _process(delta: float) -> void:
	timeout -= delta
	if timeout < 0:
		queue_free()

func _physics_process(delta: float) -> void:
	translation += velocity * delta

func _on_Missile_body_entered(body: Node) -> void:
	var new_explosion = explosion_object.instance()
	new_explosion.global_transform.origin = global_transform.origin
	get_parent().add_child(new_explosion)
	queue_free()
