extends Node2D

@onready
var settings = gbData.settings
@export
var console: Node
# Called when the node enters the scene tree for the first time.
func _ready():
	if gbData.settings["messageEnabled"] == true:
		OS.alert("DD14 here \n \n This project is in a VERY VERY EARLY state, expect a lot of weird stuff. \n\n 
		 This is an open source project and I encourage you to add your own features by downloading the github repo at https://github.com/dee-dee-catorce. \n\n
		 I am fine with the distribution of modded copies as long as I am credited and they aren't a virus or something \n\n 
		 I apologize if this project didnt meet expectations, I promised alot without taking into consideration that this is my 2nd ever godot project")
	
	GlobalVariable.console.connect(yeah)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func yeah(t: bool):
	console.visible = true
	print("yeah")
