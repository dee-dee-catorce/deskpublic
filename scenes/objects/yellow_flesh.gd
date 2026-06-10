extends RigidBody2D


func collide(body):
	if !body.get_meta("canEat", false): return
	if gbData.data.save["hunger"] < 90:
		gbData.data.save["hunger"] += 10
		gbData.data.save["trust"] += 5
		GlobalVariable.feedf(1)
		GlobalVariable.raisemoodF(1)
		queue_free()
