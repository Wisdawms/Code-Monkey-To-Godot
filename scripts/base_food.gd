class_name BaseFood extends Node3D

@export_category("BaseFood")

@export var object_name : String
@export var default_name : String
#@onready var object_name : String : get = getter_name
@export var Ingredients : Array[KitchenObjectSO]
@export var SO_List : Array[KitchenObjectSO]
var cutting_prog : float = 0
@onready var fry_timer: Timer = get_node("FryTimer")
@export var sliced: bool
@export var icon : CompressedTexture2D

@export var has_been_on_frying : bool = false
@onready var on_counter : BaseCounter
var files_array : Array = []

func _ready() -> void:
	get_sos()

func _process(_delta: float) -> void:
	if get_parent().get_parent().is_in_group("counters"):
		on_counter = get_parent().get_parent()
	else: on_counter = null
	
func get_sos():
	if object_name != "Plate":
		for a in DirAccess.get_files_at("res://resources/"):
			var default = load("res://resources/"+a)
			if default is KitchenObjectSO:
				SO_List.append(default)
		for b in DirAccess.get_files_at("res://resources/slices/"):
			var slices = load("res://resources/slices/"+b)
			if slices is KitchenObjectSO:
				SO_List.append(slices)

func get_kitchen_object_so()->KitchenObjectSO:
	for so in SO_List:
		if self.object_name == so.object_name:
			return so
	return null

func add_ingredient(kitchen_object_so : KitchenObjectSO)->void:
	if object_name == "Plate":
		Ingredients.append(kitchen_object_so)
