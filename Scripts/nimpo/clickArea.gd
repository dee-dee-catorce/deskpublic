extends Control
class_name ClickAreaControl

"""

was on this shit for like 3 hours and some dude on reddit had the solution
"just make it passthrough whenever its over an object you want it to pass through"

why did i fucking think of that when i was killing myself on that damn plane!!???
"""


var cur: bool = false

func _process(_delta: float) -> void:
    if not get_parent().visible:
        change(false)
        return
    var mouse_pos: Vector2 = get_global_mouse_position()
    var inside: bool = (
        mouse_pos.x >= global_position.x and
        mouse_pos.x <= global_position.x + size.x and
        mouse_pos.y >= global_position.y and
        mouse_pos.y <= global_position.y + size.y
    )
    change(inside)

func change(t: bool) -> void:
    if t == cur:
        return
    cur = t
    if gbData.devMode:
        print(t)
    if t:
        GlobalVariable.clickZoneSum += 1
        pass
    else:
        GlobalVariable.clickZoneSum -= 1
        pass
    if gbData.devMode:
        print(GlobalVariable.clickZoneSum)
    TransparentWindow.SetClickThrough(GlobalVariable.clickZoneSum <= 0)
   # TransparentWindow.SetClickThrough(false)