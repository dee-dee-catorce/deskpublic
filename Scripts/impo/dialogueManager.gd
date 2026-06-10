extends Node

class_name Dialogue
@onready
var data = gbData.text.diaGlobal

@export
var richtextlabel: RichTextLabel

@export
var textspeed: float = 0.04


#@export
#AnimationPlayer
#the stuff that will cause the text to delay
var pause: Array = [

	",",
	".",
	"!"
	#etc

]

#guess what this does
var isTyping: bool = false
@onready
var mood = gbData.data.save.mood
var pool: Array = []
var speedMod: float = 1.0
signal starttalking()
signal stoptalking()


func _ready() -> void:
	richtextlabel.visible_characters = 10
	richtextlabel.add_theme_font_size_override("normal_font_size", gbData.settings.expieDialogueSize)

	if gbData.data.save.firstime == 0:
		await get_tree().create_timer(6).timeout
		firstTime()
		gbData.data.save.firstime = 1
	pass
	GlobalVariable.pet.connect(petResponse)
	GlobalVariable.feed.connect(feed)
	passive()

#ripped straight from a tutorial

var tr: int = 0

func typeOut(string: String, speed_multiplier: float = 1.0):
		tr += 1
		var h = tr

		richtextlabel.add_theme_font_size_override("normal_font_size", gbData.settings.expieDialogueSize)
		isTyping = true
		richtextlabel.text = string
		richtextlabel.visible_characters = 0

		starttalking.emit()

		var i = 0
		while i < string.length():
			if tr != h:
				return

			if string[i] == "[":
				while i < string.length() and string[i] != "]":
					i += 1
				i += 1
				continue

			richtextlabel.visible_characters += 1
			var current_char = string[i]

			var wait = textspeed * speed_multiplier
			if current_char in pause:
				wait *= 8

			await get_tree().create_timer(wait).timeout
			i += 1

		if tr != h:
			return
			

		isTyping = false
		stoptalking.emit()
		await get_tree().create_timer(string.length() * 0.2).timeout

		if tr == h:
			richtextlabel.visible_characters = 0

func _on_mood_test() -> void:
	#print(data)
	if mood >= 30:
		pool = data.HappyPassive
		speedMod = 1.2

	send()

	pass # Replace with function body.


func send():
	if pool.size() > 0:
		typeOut(pool.pick_random(), speedMod)


func _on_char_ragdoll() -> void:
	if mood >= -10:
		pool = data.Ragdolled1
		speedMod = 1.5
	else:
		pool = data.Ragdolled3

	send()
	
	pass # Replace with function body.

func firstTime():
	pool = data.Intro
	speedMod = 1.2
	send()

func _on_other_hunger(hungry: int) -> void:
	if hungry < 60 and hungry >= 30:
		pool = data.Hungry
		speedMod = 1.2
	elif hungry < 30:
		pool = data.VeryHungry
		speedMod = 1.5
	send()

	
	pass # Replace with function body.


func _on_char_fistint() -> void:
	print("fistint")
	pool = data.FirstInteraction
	speedMod = 1.5
	send()
	pass # Replace with function body.


func _on_char_interest() -> void:
	pool = data.Interest1
	speedMod = 1.5
	send()


func petResponse(t: bool):
	if t:
		pool = data.Pet
		speedMod = 1
	else:
		pool = data.PetRejection
		speedMod = 1.5
		

	send()
pass # Replace with function body.

func feed(_t: bool):
	if mood <= -50:
		pool = data.Interested
	else:
		pool = data.FoodGood
	speedMod = 1.2
	send()
	pass

func passive():
	while true:
		await get_tree().create_timer(randi_range(20, 60)).timeout
		if mood > 50:
			pool = data.HappyPassive
			speedMod = 1.2
		elif mood >= 0:
			pool = data.MidPassive
			speedMod = 1
		elif mood >= -25:
			pool = data.LowPassive
			speedMod = .8
		elif mood >= -50:
			pool = data.VeryLowPassive
			speedMod = .7
		send()