@tool
extends Camera2D

@onready var tween : Tween = null
@onready var shakeTimer : Timer = null
@onready var screen_color : ColorRect = null

@export var shake_amount = 0
var default_offset = offset



func _enter_tree():
	reload()

func reload():
	if !is_in_group("camerashake"):
		add_to_group("camerashake")

func _ready():
	if !Engine.is_editor_hint():
		set_process(false)
		if shakeTimer == null and tween == null:
			var ShakeTimer := Timer.new()
			var ScreenColor := ColorRect.new()
			add_child(ScreenColor)
			add_child(ShakeTimer)
			ScreenColor.name = "Color"
			ShakeTimer.name = "Timer"
			screen_color = get_node("Color")
			shakeTimer = get_node("Timer")
			screen_color.visible = false
			screen_color.size = get_viewport_rect().size * 8000000000
			screen_color.global_position = -screen_color.size*.5
			shakeTimer.wait_time = 1
			shakeTimer.connect("timeout", Callable(self, "_on_Timer_timeout"))

func _process(delta):
	if !Engine.is_editor_hint():
		randomize()
		offset = Vector2(randf_range(-shake_amount,shake_amount),randf_range(-shake_amount,shake_amount)) * delta + default_offset


func shake(new_shake,shake_time = 0.4,shake_limit = 100,color = Color.TRANSPARENT,colored := false):
	if !Engine.is_editor_hint():
		get_tree().call_group("camshader","shake",new_shake/100,shake_time)
		screen_color.color = color
		if colored:
			screen_color.color.a = 0.1
		else:
			screen_color.color.a = 0
		screen_color.show()
		shake_amount += new_shake
		if shake_amount > shake_limit:
			shake_amount = shake_limit
	
		shakeTimer.wait_time = shake_time
	
		set_process(true)
		shakeTimer.start()


func _on_Timer_timeout():
	if !Engine.is_editor_hint():
		screen_color.hide()
		shake_amount = 0
		set_process(true)
		tween = create_tween()
		offset = default_offset
		tween.tween_property(self, "offset", offset, 0.1)
