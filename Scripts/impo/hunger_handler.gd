extends Node

@onready var tiredness: float = gbData.data.save.hunger

var maxhunger := 100.0
var minhunger := 0.0
#@onready var trust: float = gbData.data.save.trust


func hungercheck():
		if gbData.settings["hungerEnabled"]:
			await get_tree().create_timer(5).timeout
			tiredness += 0.2
			print(tiredness)
			tiredness = clamp(tiredness, minhunger, maxhunger)
			pass
			return tiredness
		else:
			return 50
