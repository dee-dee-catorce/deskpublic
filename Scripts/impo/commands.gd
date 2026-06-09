extends Node

@export var root: Control

"""
    ###

    there was a bunch of bullshit planning on how i would go about this and there ended up being an addon that did literally
    everything i was planning on adding

    here you go

    https://github.com/4d49/godot-console


    this script just registers a bunch of commands and contains their the functions for their code

    to create a custom command, create a function that contains ur code, and then register it in _ready
    ###
"""

func _log(strang: String):
	return strang

func _cust(cmd: String):
	return cmd


func _setmood(val: float):
	gbData.data.save.mood = val
	gbData.savetodisk("user://SAVE.json", gbData.data)
	return val

func _additem():
# add crate only for now
	var scene = preload("res://scenes/objects/crate.tscn")
	var instance = scene.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.position = get_viewport().get_mouse_position()
					

func resize(nx, ny):
	var ex = str(nx).to_float()
	var ey = str(ny).to_float()
	root.size.x = ex
	root.size.y = ey

	#save to config

	gbData.settings.ConsoleSize.x = ex
	gbData.settings.ConsoleSize.y = ey


	#debugshit
	if gbData.devMode == true:
		print(gbData.settings.ConsoleSize.x)
		print(gbData.settings.ConsoleSize.y)

	# please work please

	gbData.savetodisk("user://CONFIG.json", gbData.settings)
	return "resized"

func deathLoop():
	Console.execute("log I_HATE_YOU")
	await get_tree().create_timer(.1).timeout
	deathLoop()

func _ready():
	Console.create_command("log", _log, "Log a string to the console.")
	Console.create_command("resizeConsole", resize, "resize the console")
	##Console.create_command("killExpie", killExpie, "Yeha")
	Console.create_command("setMood", _setmood, "Set the mood of the expie i dont even think this works")
	Console.create_command("spawn", _additem, "spawn shit")
	#Console.create_command("deathLoop", deathLoop, "please dont crash")
	Console.execute("help")
	#setting stuff that would probably have a better solution to it

	applySettings()

func applySettings():
	## resize
	root.size.x = gbData.settings.ConsoleSize.x
	root.size.y = gbData.settings.ConsoleSize.y
