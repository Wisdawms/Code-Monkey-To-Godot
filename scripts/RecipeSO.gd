class_name RecipeSO extends Resource

@export var kitchen_object_so_list : Array[KitchenObjectSO] : get = sort_ingredients
@export var recipe_name : String
@export var order_time : float
@export var price : float

func sort_ingredients()->Array[KitchenObjectSO]:
	kitchen_object_so_list.sort()
	return kitchen_object_so_list
