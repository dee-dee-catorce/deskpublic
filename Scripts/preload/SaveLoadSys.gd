extends Node

class_name SaveLoadSys


"""
the text wall that was here was literally never correct in the first place. 
idk what i was on when i wrote it


heres the saving stuffs.,


"""

var temp = {"expies": {}} # temp dictionary, not to be saved but used instead used to store things like expies currently spawned (to add to save if setting is enabled mid-play)

var data = {}
var text = {}
var settings = {}

var skinData = []

var template = "res://Scripts/singletons/SaveTemplate.json"


# DO NOT FORGET TO DISABLE THIS WHENBUILDING 
var devMode = true


const savePath = "user://SAVE.json"
const transPath = "user://TRANSLATION.json"
const conPath = "user://CONFIG.json"
const skinfilepath = "user://skin"


func _ready():
	# Load save file
	if FileAccess.file_exists(savePath):
		data = loadjson(savePath)
		var templateData = loadjson(template)
		fixMissing(data, templateData) 
		# template does not include any expies so if persistance is enabled, we don't spawn the default.
		# below adds a single expie if there are none defined in save.json
		if data["save"]["expies"] == {}: data["save"]["expies"] = {"Default": 1} # force a default expie to spawn if no expie data on load. avoids crash

	else:
		newsave()
	
	# Load translation file
	if FileAccess.file_exists(transPath):
		text = loadjson(transPath)
		fixMissing(text, loadjson("res://Scripts/singletons/TEMPDialogue.json"))
	else:
		newTrans()

	# Load settings/config file
	if FileAccess.file_exists(conPath):
		settings = loadjson(conPath)
		fixMissing(settings, loadjson("res://Scripts/singletons/config.json"))
	else:
		newConfig()

	if DirAccess.dir_exists_absolute(skinfilepath):
		skinData = loadSkin()
	else:
		newSkinFile()


	InitAutosave()

#this bug fuxking sucks so im removing it once and for all
#automatically detect if the user is missing a setting or something related to that
#should fix the shocked face bug PERMANANTLY
func fixMissing(base: Dictionary, default: Dictionary):
	for key in default.keys():
		if not base.has(key):
			base[key] = default[key]
		elif typeof(base[key]) == TYPE_DICTIONARY and typeof(default[key]) == TYPE_DICTIONARY:
			fixMissing(base[key], default[key])

func newsave():
	# Read the save template
	if not ResourceLoader.exists(template):
		print("template not found at: ", template)
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
	var defaultTrans = "res://Scripts/singletons/TEMPDialogue.json"
	
	text = loadjson(defaultTrans).duplicate(true)
	savetodisk(transPath, text)

func newConfig():
	var configFile = "res://Scripts/singletons/config.json"

	settings = loadjson(configFile).duplicate(true)
	savetodisk(conPath, settings)

func newSkinFile():
	var readMeF = skinfilepath + "/READ.txt"
	

	if not DirAccess.dir_exists_absolute(skinfilepath):
		var error = DirAccess.make_dir_recursive_absolute(skinfilepath)
		
		if error == OK:
			var txt = FileAccess.open(readMeF, FileAccess.WRITE)
			

			if txt:
				txt.store_line("""Drop the Body folder of your skin into this folder!


In theory, everything on https://skin.cat-bot.de/ should be compatible with this!

If you want multiple skins, just rename your 'Body' folder to whatever you want to call it, then use the skin spawner.
(however you have to keep a 'Body' folder with any skin in it for it to work!)
If you have both a 'Body' and 'Head' folder, combine the files inside them into a new folder and drag them in here.

If your skin is only on the head, try restarting the app. That usually fixes it.""")
				txt.close()
	
	var folder_to_copy = "res://assets/Body"
	
	var new_dir_path: String = "user://skin/Body"
	DirAccess.make_dir_absolute(new_dir_path)
	
	#Copy each file and folder into the new folder
	var old_files: PackedStringArray = DirAccess.get_files_at(folder_to_copy)
	for f: String in old_files:
		DirAccess.copy_absolute(folder_to_copy + "/" + f, new_dir_path + "/" + f)
	var old_directories: PackedStringArray = DirAccess.get_directories_at(folder_to_copy)


func loadSkin():
		var _ifliterallyanythingisthere = false
		var added = []
		var pt = skinfilepath + "/Body"
		if DirAccess.dir_exists_absolute(pt):
			var files = DirAccess.get_files_at(pt)
			for file in files:
				if file.get_extension().to_lower() == "png":
					_ifliterallyanythingisthere = true
					added.append(pt.path_join(file))
			
		return added


# my favorite helpers!
#theyre gone nvm
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
		if gbData.settings.expiePersistence: # check if persistence is enabled
			gbData.data["save"]["expies"] = gbData.temp.expies # copy temp expie data to save
		
		savetodisk(savePath, data)
		savetodisk(conPath, settings)


func killEverything():
	newsave()
	newTrans()
	newSkinFile()
	newConfig()

func outdated():
	if settings.outdated:
		print("already outdated")
		return
	settings.outdated = true
	killEverything()

func checkupdated():
	if !settings.outdated: return
	print("version is current")
	settings.outdated = false
