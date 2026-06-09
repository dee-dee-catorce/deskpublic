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
alot of the code in this script was like taken from other projects random forums and people on discord and poorly glued together here

this was made like a while ago and ill be 100% honest some of the snippets here were ripped straight from googles ai

that was a very horrible mistake on my end this script is a complete mess and half of this stuff doesnt work properly

physmanager was my initial attempt at recoding this and it didnt work at all so im temporarily going back to this

this script will be replaced 


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


func _physics_process(delta):
	stateUpd()
	physState(delta)


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
		#if someone can  replace this thatd be
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



