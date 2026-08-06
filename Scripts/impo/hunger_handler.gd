extends Node

@onready var hungry: float = 0.0

var maxhunger := 100.0
var minhunger := 0.0
#@onready var trust: float = gbData.data.save.trust
var petId: String = ""
var pet
func loadFromSave(id: String) -> void:
	petId = id
	pet = gbData.data["saw"][petId]
	hungry = pet.get("hunger", hungry)


func hungercheck():
		if gbData.settings["hungerEnabled"]:
			#await get_tree().create_timer(5).timeout
			hungry -= 0.1
			print(str(hungry) + " hunger")
			hungry = snappedf(hungry, 0.01)
			hungry = clamp(hungry, minhunger, maxhunger)
			pet.hunger = hungry
			gbData.savetodisk("user://SAVE.json", gbData.data)
			pass
			return hungry
		else:
			return 50
