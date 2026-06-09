extends Node2D

@export var blendValue: float = .95
@export var skeletonRef: Skeleton2D
@export var animPlayer: AnimationPlayer
@export var headIK: Node2D

@export var boneStiffness: Dictionary = {}

var mouseDectDistance = 300
var getup = true
var rootBody: RigidBody2D
var boneBodies: Dictionary = {}
var ragdollOrigin: Vector2 = Vector2.ZERO
var moving := false
var settings = gbData.settings
var def = Vector2(-104, -12)
var itemsOfInterest: Array[RigidBody2D] = []
var interestValues: Dictionary = {}
var mouseinrange = false
# states
enum States {IDLE, KNOCKEDOUT, WALKING}

var currentState: States = States.IDLE
var movetarget: Vector2

var isWalking = false
var isKnockedOut = false

var dead = false
signal ragdoll()
signal fistint()
signal interest()

var randomwalking = false
var randomWalkTarget: float = 0.0
var idleTimer: float = 0.0

@export var idleWaitTime: float = 3.0
@export var randomWalkRange: float = 200.0

"""
this script is old compared to the rest of the project

and ill be honest, i had copilot write some of the stuff here because i couldnt figure it out myself at the time

looking back that was a horrible mistake as this script is shit. copilot has been disabled for a while as of the time im writing this

a replacement is in the works 
"""
func _ready():
	# pair all the bones to their rigidbodies
	pair("Hip", $Ragdoll/GBHB/LowerTorso)
	rootBody = $Ragdoll/GBHB

	pair("Back", $Ragdoll/GBHB/UpperTorso)
	pair("LegB", $Ragdoll/GBHB/BThigh)
	pair("ShinB", $Ragdoll/GBHB/BMD)
	pair("CalfB", $Ragdoll/GBHB/BCalf)
	pair("LegF", $Ragdoll/GBHB/FThigh)
	pair("RN", $Ragdoll/GBHB/FMD)
	pair("CalfF", $Ragdoll/GBHB/FCalf)
	pair("FUarm", $Ragdoll/GBHB/FUpperArm)
	pair("FFore", $Ragdoll/GBHB/FForeArm)
	pair("FHand", $Ragdoll/GBHB/FHand)
	pair("BUarm", $Ragdoll/GBHB/BUpperArm)
	pair("BFore", $Ragdoll/GBHB/BForeArm)
	pair("BHand", $Ragdoll/GBHB/BHand)
	pair("Head", $Ragdoll/GBHB/Head)


	#back bone needs to be stiff or it looks weird
	boneStiffness["Back"] = 1
	animPlayer.play("idle")
	rtEnable(true)

func _physics_process(delta):
	stateUpd()
	physState(delta)
	updateInterest()

	if not isKnockedOut:
		updateRandomWalk(delta)

	rootBody.linear_velocity = rootBody.linear_velocity.limit_length(500)

##### STATE STUFF

func stateUpd():
	var speed: float = rootBody.linear_velocity.length()
	var hSpeed: float = abs(rootBody.linear_velocity.x)

	# only do state stuff if were allowed to get up
	if getup == true:
		if speed > 400:
			setState(States.KNOCKEDOUT)
			#_setMove(true)
			getupF(3)
			ragdoll.emit()
		else:
			if hSpeed > 5:
				#_setMove(true)
				setState(States.WALKING)
			else:
				#_setMove(true)
				setState(States.IDLE)

func setState(newState: States):
	#dont do anything if were already in this state
	if newState == currentState:
		return

	currentState = newState
	if dead:
		currentState = States.KNOCKEDOUT
	#print("state changed to: ", currentState)

	if currentState == States.KNOCKEDOUT:
		blendValue = 0.0
		ragdollOrigin = rootBody.global_position
		isKnockedOut = true
		isWalking = false

	elif currentState == States.WALKING:
		blendValue = 0.99
		animPlayer.play("Walk")
		isWalking = true
		isKnockedOut = false
		#$Ragdoll/GBHB/Head/Difffuse.frame = 1

	elif currentState == States.IDLE:
		blendValue = 0.99
		animPlayer.play("idle")
		isWalking = false
		isKnockedOut = false
		#$Ragdoll/GBHB/Head/Difffuse.frame = 1

# recycled from my old game nuke train lmao
func physState(delta: float):
	if currentState == States.KNOCKEDOUT:
		var direction = $Ragdoll/GBHB/LowerTorso.global_position - rootBody.global_position

		# keep the torso from flying too far from root
		if direction.length() > 300:
			#$Ragdoll/GBHB/LowerTorso.global_position = rootBody.global_position + direction.limit_length(300)
			#no that made it look weird
			pass

	elif currentState == States.WALKING or currentState == States.IDLE:
		#this doesnt work. i took this as a placeholder  until i could get something better going
		#i never got rid of it and it doesnt work
		#well it works but its weird and i dont like it
		#if someone can  replace this thatd be cool
		skeletonRef.global_position = rootBody.global_position
	
		for boneNode in boneBodies:
			var body: RigidBody2D = boneBodies[boneNode]
			var bone: Bone2D = boneNode

			var animXform = skeletonRef.global_transform * getTotal(bone)
			var physXform = body.global_transform

			var stiffness: float = blendValue
			if boneStiffness.has(bone.name):
				stiffness = boneStiffness[bone.name]

			# fully animated
			if stiffness >= 0.99:
				driveBodyToTransform(body, animXform, delta)
			#ragdoll
			elif stiffness <= 0.01:
				bone.global_transform = physXform
			# blend between the two
			else:
				var blended = physXform.interpolate_with(animXform, stiffness)
				driveBodyToTransform(body, blended, delta)
				bone.global_transform = blended

func pair(boneName: String, body: RigidBody2D):
	var boneNode = skeletonRef.find_child(boneName, true, false) as Bone2D

	# if it cant find the bone just skip it i guess
	if boneNode == null:
		return

	boneBodies[boneNode] = body
	body.global_transform = boneNode.global_transform

func getTotal(bone: Bone2D) -> Transform2D:
	var xform: Transform2D = bone.transform
	var parent = bone.get_parent()

	while parent is Bone2D:
		xform = parent.transform * xform
		parent = parent.get_parent()

	return xform

func driveBodyToTransform(body: RigidBody2D, target, delta: float):
	# move body toward target
	var posError: Vector2 = target.origin - body.global_position
	body.linear_velocity = posError / delta * 0.8

	# rotate body toward target
	var angleError: float = angle_difference(body.global_rotation, target.get_rotation())
	body.angular_velocity = angleError / delta * 0.8


func getupF(time):
	getup = false
	await get_tree().create_timer(time).timeout
	getup = true


func updateInterest():
	if headIK == null or isKnockedOut:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_dir = mouse_pos - $Ragdoll/GBHB/LowerTorso.global_position
	var top_body = get_top_interest()

	if top_body != null and top_body:
		var target = top_body.global_position

		#_flip(target.x > tR.global_position.x)
		headIK.global_position = lerp(headIK.global_position, target, 0.2)

	elif mouse_dir.length() <= mouseDectDistance:
		#no idea that you could just put math here and it will return as true or false
		#thansk tiktok for telling me
		#_flip(mouse_dir.x > 0)
		headIK.global_position = lerp(headIK.global_position, mouse_pos, 0.2)
		if gbData.data.save.interactions == false:
			fistint.emit()
			mouseinrange = true
			gbData.data.save.interactions = true
	else:
		mouseinrange = false
		headIK.position = lerp(headIK.position, def, 0.2)

func get_top_interest() -> RigidBody2D:
	var top: RigidBody2D = null
	var topVal = 0

	for body in itemsOfInterest:
		var val = interestValues.get(body, 0)

		if val > topVal:
			topVal = val
			top = body

	# Default to mouse if the best target is too weak.
	if topVal < 4:
		return null
	if topVal < 7:
		interest.emit(topVal)

	return top

func stopMovement():
	rootBody.linear_velocity.x = move_toward(rootBody.linear_velocity.x, 0, 50)

func moveToX(x: float, force: float = 300.0):
	if abs(rootBody.global_position.x - x) <= 50:
		stopMovement()
		return

	var dir = sign(x - rootBody.global_position.x)
	rootBody.linear_velocity.x = move_toward(rootBody.linear_velocity.x, dir * force, force)

func updateRandomWalk(delta: float):
	if isKnockedOut:
		idleTimer = 0.0
		randomwalking = false
		return

	if randomwalking:
		moveToX(randomWalkTarget, 150)

		if abs(rootBody.global_position.x - randomWalkTarget) <= 50:
			randomwalking = false
			idleTimer = 0.0
	else:
		idleTimer += delta

		if idleTimer >= idleWaitTime:
			randomWalkTarget = rootBody.global_position.x + randf_range(-randomWalkRange, randomWalkRange)
			randomwalking = true

func _on_rapier_area_2d_body_entered(body: Node2D) -> void:
	if body.get_parent() == rootBody:
		return

	if not body is RigidBody2D:
		return

	var props = body.get_node_or_null("properties")

	if props == null:
		return

	var interestVal = props.get("interest")
	var carryable = props.get("carryable")

	if interestVal == null:
		return

	itemsOfInterest.append(body)
	interestValues[body] = interestVal

func _on_rapier_area_2d_body_exited(body: Node2D) -> void:
	if body is not RigidBody2D:
		return

	itemsOfInterest.erase(body)
	interestValues.erase(body)


func _on_interest() -> void:
	pass # Replace with function body.


func rtEnable(val: bool):
	var descendants = skeletonRef.find_children("*", "", true, false)

	for child in descendants:
		if child is RemoteTransform2D:
			var rtt: RemoteTransform2D = child

			#i forgot nvm i rememebr THIS was supposed to be for the dialogue before i changed how it works
			if child.name == "12":
				return

			rtt.update_position = not val
			rtt.update_rotation = not val
			rtt.update_scale = not val