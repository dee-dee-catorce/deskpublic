extends RapierRigidBody2D
@export
var skeletonRef: Skeleton2D
var rtLocked = false

func _ready() -> void:
	var stack := skeletonRef.get_modification_stack()
	var moredesc = self.find_children("*", "", true, false)
	for child in moredesc:
		if child is RigidBody2D:
			child.freeze = true

func _process(delta: float) -> void:
	if abs(linear_velocity.length()) > 800:
		rtEnable(false)

func rtEnable(val: bool):
	if rtLocked: return
	rtLocked = true

	var descendants = skeletonRef.find_children("*", "", true, false)
	var moredesc = self.find_children("*", "", true, false)

	for child in descendants:
		if child is RemoteTransform2D:
			var rtt: RemoteTransform2D = child
			rtt.update_position = val
			rtt.update_rotation = val

	for child in moredesc:
		if child is RigidBody2D:
			child.freeze = val
			if val == false:
				# give each bone the parent's velocity so it doesn't snap to rest
				child.linear_velocity = linear_velocity
				child.angular_velocity = angular_velocity
