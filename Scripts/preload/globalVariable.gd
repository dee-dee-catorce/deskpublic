extends Node


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
