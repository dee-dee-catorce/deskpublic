extends Node

class_name SaveLoadSys


"""
###

This is the thing that handles saving and loading. 

Heres the steps that it does through:

    Loading:
        1: Check if there is a save file. If there is, load it into data
        2: Check for a translation file in deedee/expet/lang. If there is, load it into the translation system.
        3: If there isnt. load yapENG into text.
        
    Saving:
        1: Check if there is a save file. If there isnt, make one.
        2: Save data inside the data variable to the save file.

    Creating a new file:
        1: Read SaveTemplate.json.
        2: Apply save template to data. 
        3: Randomize some variables 
        4: Create a new JSON file based on whats in data


this shit sound like ai wrote it im sorry it sounds like that 


"""

var data = {}
var text = {}

var settings = {}

var template = "res://Scripts/singletons/SaveTemplate.json"

var devMode = true


var savePath = "user://SAVE.json"
var transPath = "user://TRANSLATION.json"
var conPath = "user://CONFIG.json"

func _ready():
	# Load save file
	if FileAccess.file_exists(savePath):
		data = loadjson(savePath)
		if gbData.devMode:
			newsave()
			pass
	else:
		newsave()
	
	# Load translation file
	if FileAccess.file_exists(transPath):
		text = loadjson(transPath)
		if gbData.devMode:
			newTrans()
	else:
		newTrans()

	# Load settings/config file
	if FileAccess.file_exists(conPath):
		settings = loadjson(conPath)
		if gbData.devMode:
			print("Settings loaded from disk")
	else:
		newConfig()

	InitAutosave()

func newsave():
	# Read the save template
	if template == null:
		print("template not found")
		return
	
	#set data json to template
	data = loadjson(template).duplicate(true)

	randomize()

	data.save["mood"] += randi_range(-5, 5)
	data.save["hunger"] -= randi_range(1, 5)
	data.save["trust"] += randi_range(-10, 0)

	savetodisk(savePath, data)

func newTrans():
	#fix this later make it bassdfjogsdjfoigjsdfgjosdifgjiosdfjg nvm its good as it
	var defaultTrans = "res://Scripts/singletons/yapENG.json"
	
	text = loadjson(defaultTrans).duplicate(true)
	savetodisk(transPath, text)

func newConfig():
	var configFile = "res://Scripts/singletons/config.json"

	settings = loadjson(configFile).duplicate(true)
	savetodisk(conPath, settings)
# my favorite helpers!

func loadjson(filepath: String):
	if FileAccess.file_exists(filepath):
		var datafile = FileAccess.open(filepath, FileAccess.READ)
		var parsedresult = JSON.parse_string(datafile.get_as_text())
		if parsedresult is Dictionary:
			return parsedresult
		else:
			if gbData.devMode:
				print("Error parsing JSON file: " + filepath)
			return {}
	else:
		if gbData.devMode:
			print("File not found: " + filepath)
		return {}

func savetodisk(path, dt):
		var file = FileAccess.open(path, FileAccess.WRITE)
		if file:
			var json_string = JSON.stringify(dt, "\t")
			file.store_line(json_string)
			file.close()


func InitAutosave():
	while true:
		await get_tree().create_timer(3.0).timeout
		if gbData.devMode:
			print("saved")
		savetodisk(savePath, data)
		savetodisk(conPath, settings)
