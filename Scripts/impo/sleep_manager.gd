extends Node

@onready var tiredness: float = gbData.data.save.tired

var maxtired := 100.0
var mintired := 0.0
#@onready var trust: float = gbData.data.save.trust
var likelihood:=0

func sleepCheck():
		if gbData.settings["sleepEnabled"]:
			await get_tree().create_timer(5).timeout
			tiredness += 0.2
			print(tiredness)
			tiredness = clamp(tiredness, mintired, maxtired)
			pass
			return tiredness
		else:
			return maxtired
