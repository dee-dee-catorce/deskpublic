extends Control

var offset = Vector2.ZERO
var dragging = false
var first = true

func _ready():
	GlobalVariable.persistenceWarning.connect(signalRecieved)
	$ClickArea.enabled = self.visible
	
	position = Vector2i(GlobalVariable.screenWidth / 4, GlobalVariable.screenHeight / 4)

func _process(_delta: float):
	if dragging:
		global_position = get_global_mouse_position() - offset

func _downDrag():
	if gbData.devMode:
		print("dragging")
	offset = get_global_mouse_position() - global_position
	dragging = true
	move_to_front()

func _upDrag():
	dragging = false

func signalRecieved():
	if first:
		first = false
		self.visible = true
		$ClickArea.enabled = self.visible
		print("Showing persistence warning (concerning number of expies)")


func _on_yes_pressed():
	self.visible = false
	$ClickArea.enabled = self.visible
	GlobalVariable.persistenceWarning.emit()

func _on_no_pressed():
	self.visible = false
	$ClickArea.enabled = self.visible
	gbData.data["saw"] = {}
	gbData.addPet("Default")
	GlobalVariable.persistenceWarning.emit()
