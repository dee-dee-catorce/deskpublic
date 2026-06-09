extends Node

# Manages hunger and trust decay
"""

"""
@onready var data = gbData.data
@onready var settings = gbData.settings

var tRtick: float = 0


signal die()

signal hunger(hungry: int)
func _ready():
	await get_tree().create_timer(1).timeout
	lowerhunger()
	trustcalc()
	
var hungry = false
var starved = false

func lowerhunger():
	while true:
		await get_tree().create_timer(3.0).timeout
		gbData.data.save["hunger"] -= settings["hungerDecayRate"]
		
		var h = gbData.data.save["hunger"]
		
		if h >= 60: hungry = false
		if h >= 30: starved = false
		
		if h < 60 and not hungry:
			hungry = true
			hunger.emit(h)
			print("hungry")

		
		if h < 30 and not starved:
			starved = true
			hunger.emit(h)
			print("starved")

		if hungry:
			gbData.data.save["health"] -= .05
		if starved:
			gbData.data.save["health"] -= .1

		print(h)


func trustcalc():
		while true:
			await get_tree().create_timer(3).timeout
			

			var moodfactor = data.save.mood / 100.0
			var hungerfactor = (data.save.hunger - 50.0) / 50.0
			var healthfactor = (data.save.health - 50.0) / 50.0
			

			tRtick = (moodfactor * 0.5) + (hungerfactor * 0.3) + (healthfactor * 0.2)
			tRtick *= 3
			if starved:
				tRtick -= 0.5
			elif hungry:
				tRtick -= 0.2
			
			data.save.trust = clamp(data.save.trust + tRtick, 0.0, 100.0)
			
			if gbData.devMode:
				print("tRtick: ", tRtick)
				print("trust: ", data.save.trust)

		
func normalize_value(val: float, min_val: float, max_val: float) -> float:
	if max_val == min_val:
		return 0.0 # Prevent division by zero error
	return (val - min_val) / (max_val - min_val)
