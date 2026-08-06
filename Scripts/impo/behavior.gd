extends Node
@export var sleepParticle: CPUParticles2D

@onready var faceSys = $faceHandler
@onready var moodSys = $moodHandler
@onready var moveSys = $movementHandler
@onready var sleepHandler = $sleepManager
@onready var hungerHandler = $hungerHandler
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

## fguiosdfgiojsdgfo[jdfgio[jsdfgfjsdfgjbncvmbcvncv]]
var petId := ""

var isTired := false

var isSleeping := false
##Is the node currently in hunryg mode.
var isHungry := false

##Is the node currently in shocked mode.
var isSad := false

var isDead := false
#might be worth it change most of the timers in this script with variables
#so we can avoid magic numbers
##How long does it take the node to get up after being ragdolled.
var getUpTimer := 5.0
##How long does it take for the node to send dialogue after getting up.
var getUpTimerMsg := 1.4

var tick: float = 5


enum emotionz {
	normal, sad, sleep, tired, scared, panic, happy
}

var currentEmotion = emotionz.normal
func _ready() -> void:
	# Figure out which save slot this pet owns. The spawner (commands.gd /
	# skinSpawner.gd / main.gd's persistence loader) normally assigns petId
	# before this instance is added to the tree; if nothing did, this is a
	# brand-new pet, so allocate it a fresh save entry now.
	if petId == "":
		var skinName = GlobalVariable.userSkinPath.substr(0, len(GlobalVariable.userSkinPath) - 1) # remove "/" at end
		skinName = skinName.substr(skinName.rfind("/") + 1) # remove first half of path, getting just name
		petId = gbData.addPet(skinName)

	get_parent().get_parent().set_meta("itemName", petId)
	
	# Set debug text to Node's ID:
	#$"../textParent/DebugText".text = "Test"
	#print(get_parent().get_parent().get_children().find(self))
	connect("toggleDebugText", _on_debugToggle_signal)
	
	faceSys.setEmotion("default")
	
	moveSys.sigragdoll.connect(shock)

	moveSys.rigid.global_position.x = GlobalVariable.screenWidth / 2
	moveSys.rigid.global_position.y = - GlobalVariable.screenHeight * 2

	# moodSys/hungerHandler/sleepHandler each default to sensible template
	# values on their own; now that we know which "saw" entry is ours, load
	# this pet's actual saved stats into them.
	moodSys.loadFromSave(petId)
	hungerHandler.loadFromSave(petId)
	sleepHandler.loadFromSave(petId)

	tempRagdoll()
	wandering()
	passivetalk()
	checker()


func sleep():
	while get_tree():
			#print("2")
			if sleepHandler.sleepCheck() < 10.0:
				sleepParticle.emitting = false
				isSleeping = false
				moveSys.ragdoll(true)
				ragdolled = false
				break
			sleepParticle.emitting = true
			faceSys.setEmotion("sleep")
			moveSys.ragdoll(false)
			ragdolled = true
			sleepHandler.tiredness -= 0.125
			moodSys.mood += 0.025


			await get_tree().create_timer(tick / 7).timeout
	pass

func checker():
	while get_tree():
		#this was calling each function like 90 times per check which is why everyting was very extreme!
		#DONT DO THAT MISTAKE AGAIN!
		await get_tree().create_timer(tick).timeout
		hungerHandler.hungercheck()
		var sleepN = sleepHandler.sleepCheck()
		var moodN = moodSys.moodCheck(.5)
		if not shocked and not isSleeping:
			#sleep stuff
			currentEmotion = emotionz.normal
			if sleepN > 80.0:
				if !isTired:
					dialogueSys.pool = data.sleepy
					dialogueSys.send()
				isTired = true
				currentEmotion = emotionz.tired
				print("tired")
				if sleepHandler.sleepCheck() > 95.0:
					isSleeping = true
					print("sleeping")
					sleep()
			else:
				isTired = false

			#isSad s	
			if moodN < -20.0:
				isSad = true
				currentEmotion = emotionz.sad
			else:
				isSad = false

			if moodN > 50.0:
				currentEmotion = emotionz.happy

			faceSys.setEmotion(emotionz.keys()[currentEmotion])


func _physics_process(delta: float) -> void:
	if not ragdolled and (abs(moveSys.rigid.linear_velocity.x) > moveSys.ragdollspeed or beingDragged):
		tempRagdoll()

	if ragdolled:
		moveSys.dir = 0

func shock():
	shocked = true
	moodSys._tempVal(-5.0, 15)
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
			await get_tree().create_timer(randf_range(44.5, 66.5)).timeout
			if not beingDragged and not isSleeping and not shocked:
				dialogueSys.pool = data.Passive
				match currentEmotion:
					emotionz.normal:
						dialogueSys.pool = data.Passive
					emotionz.happy:
						dialogueSys.pool = data.HappyPassive
					emotionz.sad:
						dialogueSys.pool = data.VeryLowPassive
				dialogueSys.speedMod = 1.0
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
	if isSleeping:
		return
	#print("I JUST PET THE EXPIE ON HIS ", limb.name)
	faceSys.setEmotion("happy")
	moodSys.mood += 0.5
	moodSys._tempVal(5.0, 13)
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

		tween.tween_property(sprite, "scale", Vector2(1.07, 0.93), 0.08)
		tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25)
	
	if not dialogueSys.is_dialogue_playing():
		dialogueSys.pool = data.pet
		dialogueSys.speedMod = 0.7
		dialogueSys.send(2, false)
		
	await get_tree().create_timer(5).timeout
	faceSys.setEmotion("normal")

#ok this didnt really do anything before so im gonna edit it
func _on_debugToggle_signal():
	if $"../textParent/DebugText".text == "":
		$"../textParent/DebugText".text = "Test"
	else:
		$"../textParent/DebugText".text = ""

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
