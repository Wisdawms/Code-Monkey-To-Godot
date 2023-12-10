extends Node

@onready var parent : Object = get_parent()

func custom_tween(node : Object, property:String, target, duration : float)->void:
	var tween : Tween = create_tween()
	tween.tween_property(node, property, target, duration)
	await tween.finished
	print("tween finished!")
	if parent is Label3D:
		if parent.text == "Welcome to my game :)":
			await get_tree().create_timer(2.0).timeout
			parent.text == ""
			custom_tween.call(parent, "text", "Hope you enjoy!", 1.0)
		elif parent.text == "Hope you enjoy!":
			await get_tree().create_timer(2.0).timeout
			custom_tween.call(parent, "text", "", 1.0)

func _ready() -> void:
	if parent is Label3D:
		custom_tween.call(parent, "text", "Welcome to my game :)", 4.0)
		custom_tween.call(parent, "modulate", Color.BLUE, 4.0)
