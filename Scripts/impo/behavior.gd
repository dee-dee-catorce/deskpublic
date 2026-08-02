extends Node


@onready var faceSys = $faceHandler
@onready var moodSys = $moodHandler
@onready var moveSys = $movementHandler
@onready var sleepHandler = $movementHandler
@onready var dialogueSys = $dialogue
@onready var hunger = $dialogue

@onready var data = gbData.text.diaGlobal

@onready var settings = gbData.settings

##Timer used for keeping time since the last recent pet.
@onready var pet_timer: Timer = $petTimer
##How much does the pet timer last. Keep it higher getUpTimer so the wrong dialogue
##doesn't get sent.
var pet_timer_inc := 10.0
##How many times has the node been pet recently.
var pet_count := 0

##Is the node being currently dragged.
var beingDragged := false
##Is the node currently in ragdoll mode.
var ragdolled := false
##Did the node get launched by the player.
var launchflag := false
##Is the node currently in wandering mode.
var wander := true
##Is the node currently in shocked mode.
var shocked := false

var isSleeping := false
##Is the node currently in hunryg mode.
var isHungry := false

##Is the node currently in shocked mode.
var isSad := false
#might be worth it change most of the timers in this script with variables
#so we can avoid magic numbers
##How long does it take the node to get up after being ragdolled.
var getUpTimer := 5.0
##How long does it take for the node to send dialogue after getting up.
var getUpTimerMsg := 3.0

var tick: float = 5.0

func _ready() -> void:
	# Persistence logging:
	var userSkinPath = GlobalVariable.userSkinPath.substr(0, len(GlobalVariable.userSkinPath) - 1) # remove "/" at end
	var skinName = userSkinPath.substr(userSkinPath.rfind("/") + 1) # remove first half of path, getting just name
	if !gbData.temp["expies"].has(skinName): gbData.temp["expies"][skinName] = 0 # check if skin has been spawned yet
	gbData.temp["expies"][skinName] += 1 # update number of skins
	# ---
	
	faceSys.setEmotion("default")
	
	moveSys.sigragdoll.connect(shock)

	moveSys.rigid.global_position.x = GlobalVariable.screenWidth / 2
	moveSys.rigid.global_position.y = - GlobalVariable.screenHeight * 2
	tempRagdoll()
	wandering()
	passivetalk()

func checker():
	await get_tree().create_timer(tick).timeout
	pass


func _physics_process(delta: float) -> void:
	if not ragdolled and (abs(moveSys.rigid.linear_velocity.x) > moveSys.ragdollspeed or beingDragged):
		tempRagdoll()

	if ragdolled:
		moveSys.dir = 0

func shock():
	if shocked:
		return
	shocked = true

	faceSys.setEmotion("panic")

	dialogueSys.pool = data.screamBIG
	dialogueSys.speedMod = 1.3
	dialogueSys.send()
	AudioManager.play_random(AudioManager.expie_whine)
	await get_tree().create_timer(2).timeout
	faceSys.setEmotion("scared")
	await get_tree().create_timer(5).timeout
	faceSys.setEmotion("sad")
	await get_tree().create_timer(13).timeout
	faceSys.setEmotion("normal")

	shocked = false

func tempRagdoll() -> void:
	moveSys.ragdoll(false)
	ragdolled = true
	moveSys.rigid.collision_layer = 0
	moveSys.rigid.collision_mask = 0
	moveSys.rigid.freeze = true
	while true:
		await get_tree().create_timer(getUpTimer + randf_range(0, 5)).timeout
		if beingDragged:
			AudioManager.play_random(AudioManager.expie_whine)
			dialogueSys.pool = data.beingDragged
			dialogueSys.send(10, false)
			#fix the weird ghost collision during ragdoll
			continue
		if moveSys.rigidtorso.linear_velocity.length() > 10.0:
			continue
		break
	moveSys.rigid.collision_layer = 2
	moveSys.rigid.collision_mask = 1
	moveSys.rigid.freeze = false
	moveSys.rigid.linear_velocity.x = 0.0
	moveSys.rigid.linear_velocity.y = 0.0
	moveSys.rigid.global_position.x = moveSys.rigidtorso.global_position.x
	moveSys.rigid.global_position.y = moveSys.rigidtorso.global_position.y
	moveSys.ragdoll(true)

	ragdolled = false
	await get_tree().create_timer(getUpTimerMsg).timeout

	if launchflag:
		if not pet_timer.is_stopped() and pet_count >= 5:
			dialogueSys.pool = data.getUpPet
		else:
			dialogueSys.pool = data.getUp

	else:
		dialogueSys.pool = data.start
	dialogueSys.speedMod = 1.3
	dialogueSys.send()
	AudioManager.play_random(AudioManager.expie_whine)
	launchflag = true
	pet_count = 0
	pet_timer.stop()


func passivetalk():
	while true:
		if !gbData.settings["mutePassive"]:
			await get_tree().create_timer(randf_range(1.5, 20.5)).timeout
			if not beingDragged:
				dialogueSys.pool = data.lastmoments
				dialogueSys.speedMod = 1.3
				dialogueSys.send()
		else:
			await get_tree().create_timer(5.0).timeout

func wandering():
	while get_tree():
		if wander:
			await get_tree().create_timer(randi_range(4, 8)).timeout

			var center = GlobalVariable.screenWidth / 2.0
			var ex = moveSys.rigid.global_position.x
			var offset = ex - center
			var th = GlobalVariable.screenWidth * 0.25

			if offset > th:
				moveSys.dir = -1
			elif offset < -th:
				moveSys.dir = 1
			else:
				moveSys.dir = randi_range(-1, 1)

			await get_tree().create_timer(randf_range(.5, 2.0)).timeout
			moveSys.dir = 0
		else:
			await get_tree().create_timer(randi_range(4, 8)).timeout

func petLimb(limb: RigidBody2D):
	AudioManager.play_sfx(AudioManager.thudwoosh)
	if randf() < 0.5:
		AudioManager.play_random(AudioManager.expie_bark, 0.25, 0, 1, true, 0.5, 'exp_pet')
	else:
		AudioManager.play_random(AudioManager.expie_whine, 0.25, 0, 1, true, 1, 'exp_pet')
		
	#print("I JUST PET THE EXPIE ON HIS ", limb.name)
	faceSys.setEmotion("happy")
	pet_timer.start(pet_timer_inc)
	pet_count += 1
	
	#we can't tween the actual rigid body, its position doesn't update while tweening
	var sprite := limb.get_node_or_null("Sprite2D") as CanvasItem
	if not sprite:
		# if we fuck up, grab the first child node that isn't a CollisionShape2D
		for child in limb.get_children():
			if child is CanvasItem and not child is CollisionShape2D:
				sprite = child
				break

	if sprite:
		var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

		tween.tween_property(sprite, "scale", Vector2(1.15, 0.85), 0.08)
		tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25)
	
	if not dialogueSys.is_dialogue_playing():
		dialogueSys.pool = data.pet
		dialogueSys.speedMod = 0.7
		dialogueSys.send(2, false)
		
	await get_tree().create_timer(5).timeout
	faceSys.setEmotion("normal")

func struggle():
	while get_tree():
		randomize()
		await get_tree().create_timer(.1).timeout
		if ragdolled:
			var random_torque = randf_range(-1500.0, 1500.0)
			moveSys.rigidtorso.apply_torque(random_torque)

			var random_force = Vector2(randf_range(-1, 1), randf_range(-1, -2.0))
			moveSys.rigidtorso.apply_central_impulse(random_force * .3)

			await get_tree().create_timer(randf_range(.5, 1.2), false).timeout
