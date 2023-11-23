class_name BaseFood extends Node3D

@export_category("BaseFood")
@export var kitchen_object_so : KitchenObjectSO
@export var object_name : String
@export var default_name : String
#@onready var object_name : String : get = getter_name
var cutting_prog : float = 0
@onready var fry_timer: Timer = get_node("FryTimer")
@export var sliced: bool
@export var icon : CompressedTexture2D

@export var has_been_on_frying : bool = false
@onready var on_counter : BaseCounter

func _process(_delta: float) -> void:
	if get_parent().get_parent().is_in_group("counters"):
		on_counter = get_parent().get_parent()
	else: on_counter = null

#func getter_name()->String:
	#if sliced:
		#return default_name + "Slices"
	#return default_name
	
