extends StaticBody2D

var screenWidth: int = DisplayServer.screen_get_usable_rect().size.x
var screenHeight: int = DisplayServer.screen_get_usable_rect().size.y

var taskbarPos: int = DisplayServer.screen_get_usable_rect().end.y


func _ready() -> void:
    position = Vector2(screenWidth, screenHeight / 2)