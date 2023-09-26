@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("CombatArea","Area2D",preload("res://addons/combat_area/CombatArea2D.gd"),preload("res://addons/combat_area/CombatArea2DIcon.png"))
	add_custom_type("HealthBar","TextureProgressBar",preload("res://addons/combat_area/HealthBar.gd"),preload("res://addons/combat_area/HealthBarIcon.png"))
	add_custom_type("ScreenShakeCamera","Camera2D",preload("res://addons/combat_area/ScreenShakeCamera.gd"),preload("res://addons/combat_area/CameraShakeIcon.png"))
	
func _exit_tree():
	remove_custom_type("CombatArea")
	remove_custom_type("HealthBar")
	remove_custom_type("ScreenShakeCamera")
