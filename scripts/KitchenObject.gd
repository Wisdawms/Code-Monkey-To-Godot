class_name KitchenObject extends Node3D

@export_category("Kitchen Object")
@export var kitchen_object_so : KitchenObjectSO

func get_kitchen_object_so()->KitchenObjectSO:
	return kitchen_object_so
