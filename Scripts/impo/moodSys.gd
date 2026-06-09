extends Node
# yeah
# mood system or whatevah
# oh gosh
#variables
# tick = how much it increases/decreases every tick
#eyeNode = sprite for the eyes
#goes the same for mouthNode
@export var tick: float = 0
@export var eyeNode: Sprite2D
@export var mouthNode: Sprite2D


@onready var mood: float = gbData.data.save.mood
@onready var trust: float = gbData.data.save.trust

var funstuff = false
var shocked = false
var istalking = false
var currExpression: String = "default"
var currEye: int
var currMouth: int
@onready
var minmood = gbData.settings["minMood"]
@onready
var maxmood = gbData.settings["maxMood"]
signal test()
#these numbers represent what frame the eye or mouth should be for each expression
var eyes = {
	"shocked": {"open": 8, "closed": 1},
	"shockedandbitchingaboutit": {"open": 0, "closed": 1},
	"default": {"open": 2, "closed": 3},
	"reallyHappy": {"open": 4, "closed": 4},
	"crying": {"open": 5, "closed": 7},
	"wideEyed": {"open": 6, "closed": 6}
}
var heads = {
	"shocked": {"closed": 0, "open": 1},
	"shockedandbitchingaboutit": {"closed": 0, "open": 1},
	"default": {"closed": 2, "open": 3, "alt": 6},
	"reallyHappy": {"closed": 4, "open": 5},
	"crying": {"closed": 2, "open": 3}
}

func _ready() -> void:
	checkmood()
	blinkLoop()
	moodLoop()
	GlobalVariable.raisemood.connect(add)
	GlobalVariable.feed.connect(feed)
	

func switchEye(frame: int) -> void:
	currEye = frame
	if eyeNode:
		eyeNode.frame = frame

func switchMouth(frame: int) -> void:
	currMouth = frame
	if mouthNode:
		mouthNode.frame = frame

func blink() -> void:
	var expression := currExpression
	switchEye(
		eyes[expression].get(
			"closed",
			eyes[expression]["open"]
		)
	)
	await get_tree().create_timer(0.2).timeout

	if eyes.has(currExpression):
		switchEye(eyes[currExpression]["open"])

func blinkLoop() -> void:
	while is_inside_tree():
		await get_tree().create_timer(
			randf_range(2.0, 4.0)
		).timeout
		blink()

func talk() -> void:
	while istalking:
		if heads.has(currExpression):
			switchMouth(heads[currExpression]["closed"])
		await get_tree().create_timer(
			randf_range(0.08, 0.18)).timeout
		if not istalking:
			break
		if heads.has(currExpression):
			switchMouth(heads[currExpression]["open"])
		await get_tree().create_timer(
			randf_range(0.05, 0.12)).timeout

func _sync_mood() -> void:
	gbData.data.save.mood = mood
	minmood = gbData.settings["minMood"]
	maxmood = gbData.settings["maxMood"]
	gbData.savetodisk("user://SAVE.json", gbData.data)

func moodLoop() -> void:
	while true:
		await get_tree().create_timer(3).timeout

		var normalize = mood / 250.0
		tick = clamp(tick, -5.0, 5.0)
		funstuff = false


		#test.emit()

		
		mood = clamp(lerp(mood, 0.0, 0.01) + tick, minmood, maxmood)
		tick = lerp(tick, 0.0, 0.01)

		mood = snappedf(mood, 0.01)

		_sync_mood()

		if gbData.devMode:
			print(str("mood: ", mood))
			print(str("tick: ", tick))

		checkmood()

func checkmood() -> void:
	if funstuff or shocked:
		return

	if mood > 70:
		currExpression = "reallyHappy"
	elif mood >= -30:
		currExpression = "default"
	elif mood >= -70:
		currExpression = "crying"

	if heads.has(currExpression):
		switchMouth(heads[currExpression]["closed"])

# signals
func _on_dialogue_stoptalking() -> void:
	istalking = false
	if heads.has(currExpression):
		switchMouth(heads[currExpression]["closed"])

func _on_dialogue_starttalking() -> void:
	if istalking:
		return
	istalking = true
	talk()

func _on_char_ragdoll() -> void:
	mood -= 5
	tick -= .4
	gbData.data.save.trust -= 3
	_sync_mood()
	shockedEye()

	pass # Replace with function body.

func shockedEye():
		shocked = true
		if mood >= -30:
			currExpression = "shocked"
		elif mood >= -70:
			currExpression = "shockedandbitchingaboutit"
		switchMouth(heads[currExpression]["open"])
		switchEye(eyes[currExpression]["open"])
		await get_tree().create_timer(.3).timeout
		shocked = false
		checkmood()

func firstone():
	pass


func _on_other_hunger(hungry: int) -> void:
	if hungry < 60 and hungry >= 30:
		tick -= .5
	elif hungry < 30:
		tick -= 1
	pass # Replace with function body.

func add(moodAmount: int):
	mood += moodAmount
	if gbData.devMode:
		print("added")
func feed(opsdfosdfgopkdfg: int):
	tick += .3