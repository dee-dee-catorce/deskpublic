extends Node

# thank you randoms on discord
@onready

var settings = gbData.settings


var sMAP = {
	"deathBool": {"key": "deathEnabled", "type": "toggle"},
	"expieFontSize": {"key": "expieDialogueSize", "type": "text"},
	"hungerRate": {"key": "hungerDecayRate", "type": "text"},
	"openAlert": {"key": "messageEnabled", "type": "toggle"},
	"minMood": {"key": "minMood", "type": "text"},
	"maxMood": {"key": "maxMood", "type": "text"},
	# "s":      { "key": "someVolume",          "type": "slider" },
}


func _ready() -> void:
	if gbData.devMode:
		#print("Settings ", settings)
		pass
	_initset()


func _initset() -> void:
	for node_name in sMAP:
		var node = findSettingN(node_name)
		if node == null:
			continue

		var entry = sMAP[node_name]
		var key = entry["key"]
		var type = entry["type"]

		match type:
			"toggle":
				node.button_pressed = settings.get(key, false)
				node.toggled.connect(func(on): sett(key, on))

			"text":
				node.text = str(settings.get(key, ""))
				node.text_submitted.connect(func(val): sett(key, float(val)))

			"slider":
				node.value = settings.get(key, node.min_value)
				node.value_changed.connect(func(val): sett(key, val))


# 
func findSettingN(node_name: String) -> Node:
	for child in $ItemList.get_children():
		if child.name == node_name:
			return child
	return null


func sett(key: String, value) -> void:
	settings[key] = value
	_saveSettings()


func _saveSettings() -> void:
	gbData.savetodisk(gbData.conPath, gbData.settings)
	if gbData.devMode:
		print("Settings saved")
