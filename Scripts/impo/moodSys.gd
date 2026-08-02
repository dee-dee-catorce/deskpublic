extends Node
# yeah
# mood system or whatevah
# oh gosh

@export var tick: float = 0
@export var eyeNode: Sprite2D
@export var mouthNode: Sprite2D


@onready var mood: float = gbData.data.save.mood
@onready var trust: float = gbData.data.save.trust


@onready
var minmood = gbData.settings["minMood"]
@onready
var maxmood = gbData.settings["maxMood"]

#make sure things are updated

func _sync_mood() -> void:
	#gbData.data.save.mood = mood
	minmood = gbData.settings["minMood"]
	maxmood = gbData.settings["maxMood"]
	gbData.savetodisk("user://SAVE.json", gbData.data)


#main mood loop
func moodCheck() -> void:
		await get_tree().create_timer(10).timeout
		if gbData.settings.get("invincible", false):
			return

		mood += tempCalc()
		#showly neutralize in lerp but im going to be honesst they basically do nothing

		mood = snappedf(mood, 0.01)


		mood = clamp(mood, minmood, maxmood)
		if gbData.devMode:
			print(str("mood: ", mood))
			print(str("tick: ", calcmood(1.0)))
		if gbData.settings["lobotomize"]:
			mood = 0.0
		_sync_mood()

func tempCalc(total: float = 0.0):
	total = clamp(total, minmood, maxmood)
	return total

func calcmood(total: float):
	#health
	total -= clamp(((1.0 - (gbData.data.save["health"] * 0.01)) * 3), 0.0, 3)
	#hunger
	total -= clamp(((1.0 - (gbData.data.save["hunger"] * 0.01)) * 1), 0.0, 1)
	#trust
	total -= clamp(((1.0 - (gbData.data.save["trust"] * 0.01)) * 1), 0.0, 1)

	if gbData.data.save["trust"] >= 60.0:
		total += 0.25
	if gbData.data.save["hunger"] >= 85.0:
		total += 0.25
	#clamp to user settings
	total = clamp(total, minmood, maxmood)
	#undo all of it

	print(total)
	return total
