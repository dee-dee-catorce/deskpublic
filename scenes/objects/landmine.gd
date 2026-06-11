extends RigidBody2D


func collide(body):
	if !body.get_meta("triggerLandmine", false): return
	var dir: Vector2 = (body.position - position).normalized()
	var o = body.owner
	o.rootBody.linear_velocity = dir * 5000
	o.setState(o.States.KNOCKEDOUT)
	queue_free()
