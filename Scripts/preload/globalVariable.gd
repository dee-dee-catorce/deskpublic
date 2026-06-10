extends Node

#i probably shouldve put these here earlier but better late than never

#ill fix the scripts that redefine these when it bothers me enough
var screenWidth: int = DisplayServer.screen_get_usable_rect().size.x
var screenHeight: int = DisplayServer.screen_get_usable_rect().size.y

var taskbarPos: int = DisplayServer.screen_get_usable_rect().end.y

var clickZoneSum: int = 0


signal pet(t: bool)
signal console(t: bool)
signal raisemood(t: int)
signal feed(t: int)
#signal bus shit this probably has like one thing in it
func petf(t: bool):
    pet.emit(t)

func consoleF(t: bool):
    console.emit(t)

func raisemoodF(t: int):
    raisemood.emit(t)

func feedf(t: int):
    feed.emit(t)
