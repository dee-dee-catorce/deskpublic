extends Sprite2D

const icons = [
	preload("res://icons/SpeechBubble0.png"),
	preload("res://icons/SpeechBubble1.png"),
	preload("res://icons/SpeechBubble2.png"),
	preload("res://icons/SpeechBubble3.png"),
]

var _index := 0
var _timer := 0.0
var _flashTween: Tween

func _ready() -> void:
	visible = false
	texture = icons[0]

func _process(delta: float) -> void:
	var yap = _getYap()
	if yap == null or not yap.iconVisible():
		visible = false
		_index = 0
		return
	visible = true
	_timer += delta
	if _timer >= 0.25:
		_timer = 0.0
		_index = (_index + 1) % icons.size()
		texture = icons[_index]

func flashMoodTint(increased: bool) -> void:
	if _flashTween != null and _flashTween.is_valid():
		_flashTween.kill()
	modulate = Color.WHITE
	_flashTween = create_tween()
	_flashTween.tween_property(self, "modulate", Color(0.5, 1.0, 0.5) if increased else Color(1.0, 0.5, 0.5), 0.25)
	_flashTween.tween_interval(0.4)
	_flashTween.tween_property(self, "modulate", Color.WHITE, 0.5)

func _getYap():
	var root = get_parent().get_parent()
	var behavior = root.get_node_or_null("behavior")
	if behavior == null:
		return null
	return behavior.get_node_or_null("yapHandler")