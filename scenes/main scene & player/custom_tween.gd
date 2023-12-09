extends Node

var custom_tween : Callable = tween
@onready var parent : Object = get_parent()

func tween(node : Object, property:String, target, duration : float)->void:
	var twee : Tween = create_tween()
	twee.tween_property(node, property, target, duration)
	await twee.finished
	print("tween finished!")
	await get_tree().create_timer(2.0).timeout
	custom_tween.call(parent, "text", "", 1.0)

func _ready() -> void:
	custom_tween.call(parent, "text", "Welcome to the game :)", 4.0)
	custom_tween.call(parent, "modulate", Color.BLUE, 4.0)
