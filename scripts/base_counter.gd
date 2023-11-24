class_name BaseCounter extends Node3D


#region [    Signals    ]
signal OnProgressChanged
signal OnInteractAlt (interactor : MyPlayerClass)
signal OnInteract (interactor : MyPlayerClass)
signal OnHover (interactor : MyPlayerClass)
signal OnUnhover (interactor : MyPlayerClass)
signal OnItemChanged ( interactor : MyPlayerClass, counter : BaseCounter)
#endregion

#region [   Variables   ]

#region Counter Settings
@export_subgroup("Counter_Settings")
@export_enum("Counter", "Food") var handle_prog_on = "Food"
@export_enum("Clear_Counter", "Cutting_Counter", "Container_Counter", "Trash_Bin", "Stove_Counter", "Plates_Counter") var type : String
@export_category("Plates_Counter_Settings")
@export var spawn_plate_timer_max : float = 4.0
@export var plate_amount_max: int = 4
#endregion

#region Debugging
@export_subgroup("for_debugging")
var spawn_plate_timer : float
@export var _is_frying : bool
@export var plates_on_top_offset_y : float
@export var food_on_plates_offset_y : float = 0.15
@export var hovered : bool
var is_burning_meat: bool
var cutting_prog : float = 0
var run_once : bool = true
var interactor : MyPlayerClass
@onready var player_obj : String = "nothing"
@onready var current_counter_obj : String = "nothing"
var item : BaseFood
@export var Kitchen_Object : KitchenObjectSO : set = set_ko
var cut_recipe_so : CuttingRecipeSO
var frying_recipe_so : FryingRecipeSO
#endregion

#region Getting nodes
@export_subgroup("getting_nodes")
@onready var counter_top_point: Marker3D = $CounterTopPoint
@onready var prog_bar: ProgressBar = $counter_hud/prog_bar_sprite/SubViewport/Control/ProgressBar
@onready var prog_bar_sprite : Sprite3D = $counter_hud/prog_bar_sprite
@onready var fry_timer: Timer = get_node("FryTimer")
@onready var stove_anims : AnimationPlayer = $StoveAnims
@onready var anim_tree : AnimationTree = $knife_anim/AnimationTree
@onready var stove_on_visual : MeshInstance3D = get_node("Stove/StoveOnVisual")
var mesh_instances : Array
@export_subgroup("Recipes")
@export var CuttingRecipeSOArray : Array[CuttingRecipeSO]
@export var FryingRecipeSOArray : Array[FryingRecipeSO]
#endregion

#endregion

#region [    Methods For Handling Stuff    ]

func handle_spawning_plates(delta)->void:
	if type == "Plates_Counter":
		if counter_top_point.get_child_count() < plate_amount_max:
			spawn_plate_timer += delta
			if spawn_plate_timer > spawn_plate_timer_max:
				spawn_food_on_container(counter_top_point.get_child_count())
				spawn_plate_timer = 0.0
		else:
			pass
			#print("Reached maximum number of plates on counter!")

func handle_stove_on_and_off_animation()->void:
	if run_once:
		if type == "Stove_Counter":
			if counter_has_object():
				if is_frying():
					if stove_anims.current_animation != "StoveOn":
						stove_anims.play("StoveOn")
						run_once = false

				elif not is_frying() and stove_anims.current_animation != "StoveOff":
							stove_anims.play("StoveOff")
							run_once = false	
				else:
					if stove_anims.current_animation != "StoveOff":
						run_once = false
						stove_anims.play("StoveOff")

			else:
				if stove_anims.current_animation != "StoveOff":
						run_once = false
						stove_anims.play("StoveOff")

func handle_burning_meat_effects()->void:
	if type == "Stove_Counter" and counter_has_object():
		if current_counter_obj == "MeatPattyCooked":
			if is_frying() and not is_burning_meat:
				print("Your meat is burning yo!", " It will turn into ", get_output_from_input(current_counter_obj).object_name)
				prog_bar.get("theme_override_styles/fill/bg_color").set_bg_color(Color(0.63137257099152, 0, 0.19607843458652))
				is_burning_meat = true
		else:
			prog_bar.get("theme_override_styles/fill/bg_color").set_bg_color(Color(0.63137257099152, 0.39215686917305, 0.19607843458652))
			if is_burning_meat:
				is_burning_meat = false


func set_current_player_and_counter_obj()->void:
	if counter_has_object():
		current_counter_obj = self.item.object_name
	else: current_counter_obj = "nothing"
	if player_has_object(interactor):
		player_obj = interactor.item_holding.object_name
	else: player_obj = "nothing"


func get_output_from_input(input : String) -> Resource: # returns the output of KitchenObjectSO's input
	match type:
		"Cutting_Counter":
			for cutting_recipe : Resource in CuttingRecipeSOArray: # iterates through the recipe list
				# and then chcecks if the input (the kitchen item) exists as an input in the list
				if cutting_recipe.input != null and cutting_recipe.input.object_name == input:
					return cutting_recipe.output #returns the output of that input from the recipe list
		"Stove_Counter":
			for frying_recipe : Resource in FryingRecipeSOArray: # iterates through the recipe list
				# and then chcecks if the input (the kitchen item) exists as an input in the list
				if frying_recipe.input != null and frying_recipe.input.object_name == input:
					return frying_recipe.output #returns the output of that input from the recipe list
	return null

func get_recipe_so_with_input(input : String) -> Resource: # returns FryingRecipeSO or CuttingRecipeSO
	match type:
		"Cutting_Counter":
			for cutting_recipe : Resource in CuttingRecipeSOArray: # iterates through the recipe list
				# and then chcecks if the input (the kitchen item) exists as an input in the list
				if cutting_recipe.input != null and cutting_recipe.input.object_name == input:
					return cutting_recipe #returns the output of that input from the recipe list
		"Stove_Counter":
			for frying_recipe : Resource in FryingRecipeSOArray: # iterates through the recipe list
				# and then chcecks if the input (the kitchen item) exists as an input in the list
				if frying_recipe.input != null and frying_recipe.input.object_name == input:
					return frying_recipe #returns the output of that input from the recipe list
	return null

func set_ko(new_ko : KitchenObjectSO)->void: # change kitchen object icon when kitchen object is changed
	Kitchen_Object = new_ko # useless
	if type == "Container_Counter":
		get_node("Counter_Lid/Sprite3D").material_override.albedo_texture = Kitchen_Object.Icon

func set_recipe_so()->void:
	if counter_has_object():
		match type:
			"Cutting_Counter":
				cut_recipe_so = get_recipe_so_with_input(self.item.object_name)
			"Stove_Counter":
				frying_recipe_so = get_recipe_so_with_input(self.item.object_name)

func get_all_children(in_node : Object ,arr: Array =[]) -> Array:
	arr.push_back(in_node)
	for child : Object in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

func handle_lerp_progress_bar()->void:
	if prog_bar:
		if counter_has_object(): # for cutting counter first maybe
			match handle_prog_on:
				"Food":
					match type:
						"Cutting_Counter":
							if prog_bar.value != item.cutting_prog:
								prog_bar.value = lerp(prog_bar.value, item.cutting_prog, 0.15)
						"Stove_Counter":
							if prog_bar.value != item.fry_timer.time_left:
								prog_bar.value = lerp(prog_bar.value, item.fry_timer.time_left, 0.15)
				"Counter":
					match type:
						"Cutting_Counter":
							if prog_bar.value != item.cutting_prog:
								prog_bar.value = lerp(prog_bar.value, cutting_prog, 0.15)
						"Stove_Counter":
							if prog_bar.value != item.fry_timer.time_left:
								prog_bar.value = lerp(prog_bar.value, fry_timer.time_left, 0.15)

		else: prog_bar.value = lerp(prog_bar.value, 0.0, 0.15)

func handle_prog_sprite_visibility()->void:
	match type:
		"Cutting_Counter":
			prog_bar.get("theme_override_styles/fill/bg_color").set_bg_color(Color(0.63137257099152, 0.39215686917305, 0.19607843458652))
			if counter_has_object():
				match handle_prog_on:
					"Food":
						if not prog_bar_sprite.shown and item.cutting_prog != 0 and item.cutting_prog < cut_recipe_so.cutting_prog_max:
							prog_bar_sprite._show()
							prog_bar_sprite.shown = true
							print("Show Progress Bar")
						elif prog_bar_sprite.shown and item.cutting_prog == 0:
							prog_bar_sprite._hide()
							prog_bar_sprite.shown = false
							print("Hide Progress Bar")
					"Counter":
						if run_once and cutting_prog != 0 and cutting_prog < cut_recipe_so.cutting_prog_max:
							prog_bar_sprite._show()
							prog_bar_sprite.shown = true
							print("Show Progress Bar")
							run_once = false
						elif prog_bar_sprite.shown and cutting_prog == 0:
							prog_bar_sprite._hide()
							prog_bar_sprite.shown = false
							print("Hide Progress Bar")
		"Stove_Counter":
			if is_frying():
				if prog_bar_sprite and not prog_bar_sprite.shown:
					prog_bar_sprite._show()
					prog_bar_sprite.shown = true
					print("Show Progress Bar")
	if not counter_has_object(): # hides prog bar sprite if no object on it
		if prog_bar_sprite and prog_bar_sprite.shown:
				print("Hide Progress Bar")
				prog_bar_sprite._hide()
				prog_bar_sprite.shown = false

func handle_prog_bar_max_value()->void:
	if type == "Cutting_Counter" and cut_recipe_so:
		prog_bar.max_value = cut_recipe_so.cutting_prog_max
	if "Stove_Counter" and frying_recipe_so :
		prog_bar.max_value = frying_recipe_so.frying_timer_max


#endregion

#region [   Signal Methods   ]

func is_frying()->bool:
	if type == "Stove_Counter" and item:
		match handle_prog_on:
			"Food":
				if counter_has_object():
					return item.fry_timer.time_left != 0
				else: return false
			"Counter":
				return counter_has_object() and fry_timer.time_left != 0
	return false

func _on_fry_timer_timeout() -> void:
	if type == "Stove_Counter":
		item = counter_top_point.get_child(-1)
		var input  : BaseFood = item
		var output : KitchenObjectSO
		if counter_has_object():
			output = get_output_from_input(self.item.object_name)
		if counter_has_object():
			if output:
				var spawn : Object = output.prefab.instantiate()
				item.queue_free()
				counter_top_point.add_child(spawn, true)
				print("A ", input.object_name, " has been cooked into ", output.object_name ,"!")
				if output.object_name == "MeatPattyBurned": print("You burnt your meat!!! :(")
				match handle_prog_on:
					"Food":
						item.fry_timer.stop()
					"Counter":
						item.fry_timer.stop()
				OnItemChanged.emit()
			else: 
				match handle_prog_on:
					"Food":
						item.fry_timer.stop()
					"Counter":
						fry_timer.stop()

func on_cut(prog_normalized: float)->void:
	
	if anim_tree:
		var state_machine : AnimationNodeStateMachinePlayback = anim_tree["parameters/playback"]
		state_machine.travel("knife_cut")
	print("CUT") 


func handle_reset_prog()->void:
	if type == "Cutting_Counter": # reset cutting prog on change
		if Settings.reset_prog_on_change:
			match handle_prog_on:
				"Counter": # reset cutting_prog when item changes
					cutting_prog = 0
				"Food":
					if player_has_object(interactor):
						interactor.item_holding.cutting_prog = 0
	if type == "Stove_Counter" and item: # reset frying prog on change
		match handle_prog_on:
			"Food":
				if not Settings.reset_prog_on_change:
					item.fry_timer.paused = true
				elif Settings.reset_prog_on_change:
					item.fry_timer.stop()
			"Counter":
				if not Settings.reset_prog_on_change:
					self.fry_timer.paused = true
				elif Settings.reset_prog_on_change:
					fry_timer.stop()
	

func ItemHasChanged()->void:
	if type == "Cutting_Counter":
		if Settings.reset_prog_on_change:
			match handle_prog_on:
				"Counter": # reset cutting_prog when item changes
					cutting_prog = 0
				"Food":
					if player_has_object(interactor):
						interactor.item_holding.cutting_prog = 0

	fry_item_if_possible()

	
	if item and type == "Stove_Counter":
		match handle_prog_on:
			"Food":
				item.fry_timer.timeout.connect(_on_fry_timer_timeout)
			"Counter":
				fry_timer.timeout.connect(_on_fry_timer_timeout)
	
	print("Player was holding ", player_obj," and interacted with ", self.name, " which had ", current_counter_obj)
	run_once = true
func Hover(interactor : MyPlayerClass)->void: # setting up the hover on counter mechanics ( visuals )
	if player_has_object(interactor) and type == "Stove_Counter" :
		frying_recipe_so = get_recipe_so_with_input(interactor.item_holding.object_name)
	interactor.current_counter = self
	hovered = true
	
	for mesh : Node3D in mesh_instances:
		if mesh is MeshInstance3D:
			mesh.get_active_material(0).set("emission_enabled", hovered)
		elif mesh is Sprite3D:
			mesh.material_override.set("emission_enabled", hovered)
	#print("hovered")
	
func Unhover(interactor : MyPlayerClass)->void:
	interactor.current_counter = null
	hovered = false
	
	for mesh : Node3D in mesh_instances:
		if mesh is MeshInstance3D:
			mesh.get_active_material(0).set("emission_enabled", hovered)
		else:
			mesh.material_override.set("emission_enabled", hovered)
	#print("unhovered")

func interact(interactor : MyPlayerClass)->void:	
	item = counter_top_point.get_child(-1)
	plates_on_top_offset_y = counter_top_point.get_child_count() *.5
	
	var item_one : BaseFood = item
	var item_two : BaseFood = interactor.item_holding
	
	
	if not player_has_object(interactor): # handles taking an item from counter
		if counter_has_object(): # if counter has kitchen object
			take_item(interactor)
	elif not counter_has_object(): # handles giving counter an item
		if player_has_object(interactor):
			if Kitchen_Object !=null and type == "Container_Counter": # for containers
				if interactor.item_holding.default_name != Kitchen_Object.object_name:
					print("You are holding (", interactor.item_holding.default_name, ") This (", self.name, ") only takes a (", self.Kitchen_Object.object_name, ")")
					return
				
			if not has_recipe(interactor) and type == "Cutting_Counter":
				print("This food item is not part of a recipe list that can be sliced.")
				return
			elif not has_frying_recipe(interactor) and type == "Stove_Counter":
				print("This food item is not part of a recipe list that can be fried.")
				return
			else: pass
			give_item(interactor)

	elif counter_has_object() and player_has_object(interactor): # replace two objects
		if Settings.can_replace_objects_on_cutting_counter(self): # cutting counter
			replace_item(interactor)
		elif Settings.can_replace_objects_on_normal_counter(self): # normal counters
			replace_item(interactor)
		elif Settings.can_replace_objects_on_frying_counter(self): # normal counters
			replace_item(interactor)
		else: 
			if type == "Plates_Counter":
				if player_obj == "Plate":
					print("This counter only produces plates")
					return
				else: 
					# take plate from plate counter and put food on it
					pass
			print ( "Replacing two items on a (", self.type ,") is disabled in the settings" )
	if not counter_has_object() and not player_has_object(interactor): # handles spawning an item
		if not type == "Container_Counter":
			print( "There's nothing on this counter" )
		elif type == "Container_Counter" and Kitchen_Object != null:
			spawn_food_on_container()
		else: print("This Base Container Counter does not have a Kitchen Object SO")

func interact_alt(interactor : MyPlayerClass)->void:
	if type == "Cutting_Counter": # for cutting counter interaction_alt
		if counter_has_object():
			if not player_has_object(interactor):
				if cut_recipe_so and item and get_output_from_input(self.item.object_name):
					match handle_prog_on:
						"Food":
							item.cutting_prog += 1
						"Counter":
							cutting_prog += 1
					var output : KitchenObjectSO = get_output_from_input(self.item.object_name)
					emit_signal("OnProgressChanged", item.cutting_prog as float / cut_recipe_so.cutting_prog_max as float)
					match handle_prog_on:
						"Food":
							if item.cutting_prog >= cut_recipe_so.cutting_prog_max: # if reached max cut progress, then cut the object finally
								var spawn : Object = output.prefab.instantiate()
								item.queue_free()
								counter_top_point.add_child(spawn, true)
								item.cutting_prog = 0
								OnItemChanged.emit()
								print( "You sliced this (", item.default_name, ") into (", spawn.object_name, ")" )
						"Counter":
							if cutting_prog >= cut_recipe_so.cutting_prog_max: # if reached max cut progress, then cut the object finally
								var spawn : Object = output.prefab.instantiate()
								item.queue_free()
								counter_top_point.add_child(spawn,true)
								cutting_prog = 0
								OnItemChanged.emit()
								print( "You sliced this (", item.default_name, ") into (", spawn.object_name, ")" )
				else: 
					match handle_prog_on:
						"Food":
							item.cutting_prog = 0
						"Counter":
							cutting_prog = 0
					print("Invalid Recipe (Can't slice) for this ", item.object_name)
			else: print("You are holding an item. ", "It is a ", interactor.item_holding.object_name)
		elif not counter_has_object() and player_has_object(interactor): print("You are holding an item. ", "It is a ", interactor.item_holding.object_name)
		else: print("nothing on this counter to slice")

	elif type == "Stove_Counter":
		if not player_has_object(interactor):
			if counter_has_object():
				# do nothing basically
				pass
			else : print("Can't alt-interact with this counter")
		else: print("You are holding an item, and you can't alt-interact with this stove :)")
		#                        old slice logic
		#var spawn : Object
		#var slices_folder : String = "res://scenes/food/slices/"
		#if counter_has_object() and item != null:
			#var sliced_object : PackedScene = load( slices_folder + item.default_name + "Slices" + ".tscn" )
			#if sliced_object != null and not player_has_object(interactor): # destroy object and replace with sliced version
				#if item.sliced == false:
					#item.queue_free()
					#print("Cut ", item.object_name, " into ", item.slice_name)
					#spawn = sliced_object.instantiate()
					#counter_top_point.add_child(spawn)
				#else: print("This (", item.default_name, ") is already sliced.")
			#elif not player_has_object(interactor) and sliced_object == null and counter_has_object():
				#print ("Can't slice this (", item.object_name, ")")
			#elif player_has_object(interactor) and counter_has_object() and sliced_object == null:
				#print("You are holding an item + Can't slice this")
			#elif player_has_object(interactor) and counter_has_object() and sliced_object != null:
				#print("You are holding an item.")
	else:
		print("Can't Alt_Interact with this counter")


#endregion

#region [    Boolean Methods    ]

func has_frying_recipe(interactor : MyPlayerClass)->bool:
	if FryingRecipeSOArray != null:
		var array1 : Array = []
		var names : Array = []
		var to_check : String
		if interactor.item_holding:
			to_check = interactor.item_holding.default_name
		array1.append_array(FryingRecipeSOArray)
		for e : FryingRecipeSO in array1:
			names.append(e.input.object_name)
		names.sort()
		if to_check:
			var index_in_array2 : int = names.find( to_check )

			if index_in_array2 != -1:
				return true
			else:
				return false
	return false

func has_recipe(interactor : MyPlayerClass)->bool:
	if CuttingRecipeSOArray != null:
		var array1 : Array = []
		var names : Array = []
		var to_check : String
		if interactor.item_holding:
			to_check = interactor.item_holding.default_name
		array1.append_array(CuttingRecipeSOArray)
		for e : CuttingRecipeSO in array1:
			names.append(e.input.object_name)
		names.sort()
		if to_check:
			var index_in_array2 : int = names.find( to_check )

			if index_in_array2 != -1:
				return true
			else:
				return false
	return false

func counter_has_object()->bool:
	return item != null

func player_has_object(interactor : MyPlayerClass)->bool:
	return interactor.item_holding != null

#endregion

#region [    Do Methods    ]
func give_item(interactor : MyPlayerClass )->void:
	
	if type == "Container_Counter":
		if Kitchen_Object != null:
			if interactor.item_holding.default_name != Kitchen_Object.object_name:
				print("You are holding (", interactor.item_holding.object_name, ") This counter takes (", Kitchen_Object.object_name, ")")
				return
		else:
			print("This container counter has no kitchen object")
			return
	elif type == "Trash_Bin":
		interactor.item_holding.queue_free()
		print("Placed item in trash bin.")
		OnItemChanged.emit()
		return

	interactor.item_holding.reparent(self.get_node("CounterTopPoint") )
	interactor.item_holding.position = Vector3(0, plates_on_top_offset_y, 0)
	interactor.item_holding.rotation = Vector3.ZERO
	print ( "Placed (", interactor.item_holding.object_name, ") on (", self.name, ")")
	OnItemChanged.emit()

func take_item(interactor : MyPlayerClass)->void:
	handle_reset_prog()
	item.reparent(interactor.hold_item_marker)
	item.position = interactor.hold_item_marker.position * .2
	item.rotation = Vector3.ZERO
	print("Removed (", item.object_name ,") from (", self.name, ")")
	OnItemChanged.emit()

func replace_item(interactor : MyPlayerClass)->void:
	var item_one : BaseFood = item
	var item_two : BaseFood = interactor.item_holding
	
	
	if type == "Cutting_Counter" and has_recipe(interactor) or type == "Stove_Counter" and has_frying_recipe(interactor) or Settings.can_replace_objects_on_normal_counter(self):
		if item_one.default_name != item_two.default_name and type == "Container_Counter":
			if Kitchen_Object != null:
				
				if item_two.object_name == "Plate" and item_one.object_name != "Plate":
					if item_two.valid_kitchen_object_so_list.has(item_one.get_kitchen_object_so()):
						if not item_two.Ingredients.has(item_one.get_kitchen_object_so()):
							print("Put ", item_one.object_name, " on ", item_two.name)
							item_two.add_ingredient(item_one.get_kitchen_object_so())
							item_one.queue_free()
							OnItemChanged.emit()
							return
						else: print("Plate already has this item")
					else:
						print("Can't put ", item_one.object_name, " on ", item_two.name)
						return
						
				print("You are holding (", interactor.item_holding.object_name, ") This counter takes (", Kitchen_Object.object_name, ")")
				return
				
						
		# [  plate-food system  ]
		if item_one.object_name == "Plate" and item_two.object_name != "Plate": # if plate on counter and player holding food
			if not item_one.Ingredients.has(item_two.get_kitchen_object_so()) and item_one.valid_kitchen_object_so_list.has(item_two.get_kitchen_object_so()): # if plate is empty
				#item_two.reparent( item_one.get_node("plate_content") ) # place ( food ) on plate
				#item_two.position = Vector3(0, item_one.get_node("plate_content").get_child_count() * food_on_plates_offset_y , 0) 
				#item_two.rotation = Vector3.ZERO # reset rotation
				print("Placed ", item_two.object_name, " on ", item_one.object_name)
				item_one.add_ingredient(item_two.get_kitchen_object_so())
				item_two.queue_free()
				OnItemChanged.emit()
				return
		elif item_two.object_name == "Plate" and item_one.object_name != "Plate": # if holding plate and there's food on counter
			# place food on plate 
			if not item_two.Ingredients.has(item_one.get_kitchen_object_so()) and item_two.valid_kitchen_object_so_list.has(item_one.get_kitchen_object_so()) : # if plate on player is empty
				#item_one.reparent( item_two.get_node("plate_content") ) # place food on player's plate
				#item_one.position = Vector3(0, item_two.get_node("plate_content").get_child_count() *  food_on_plates_offset_y , 0)
				#item_one.rotation = Vector3.ZERO
				# if place plate on counter when picking up food is enabled [ NOT NEEDED NOW ]
				#item_two.reparent( counter_top_point ) # then place plate on counter
				#item_two.position = Vector3.ZERO
				#item_two.rotation = Vector3.ZERO
				print("Placed ", item_two.object_name, " on ", item_one.object_name)
				item_two.add_ingredient(item_one.get_kitchen_object_so())
				item_one.queue_free()
				return
		
		
		item_one.reparent(interactor.hold_item_marker)
		item_two.reparent( self.get_node("CounterTopPoint") )
		item_one.position = interactor.hold_item_marker.position * .2
		item_two.position = Vector3.ZERO
		item_one.rotation = Vector3.ZERO
		item_two.rotation = Vector3.ZERO
		print ( "Replaced (", item_one.object_name ,") with (", item_two.object_name, ") on (", self.name, ")")
		OnItemChanged.emit()
		
	# for placing food from stove or cutting counter to plate
	elif not has_frying_recipe(interactor) or not has_recipe(interactor) and type == "Cutting_Counter" or type == "Stove_Counter" and item_two.object_name == "Plate" and Settings.can_replace_objects_on_normal_counter(self):
		if not item_two.Ingredients.has(item_one.get_kitchen_object_so()) and item_two.valid_kitchen_object_so_list.has(item_one.get_kitchen_object_so()) : # if plate on player is empty
				#item_one.reparent( item_two.get_node("plate_content") ) # place food on player's plate
				#item_one.position = Vector3(0, item_two.get_node("plate_content").get_child_count() * food_on_plates_offset_y  , 0)
				#item_one.rotation = Vector3.ZERO
				# if place plate on counter when picking up food is enabled [ NOT NEEDED NOW ]
				#item_two.reparent( counter_top_point ) # then place plate on counter
				#item_two.position = Vector3.ZERO
				#item_two.rotation = Vector3.ZERO
				print("Placed ", item_two.object_name, " on ", item_one.object_name)
				item_two.add_ingredient(item_one.get_kitchen_object_so())
				item_one.queue_free()
				OnItemChanged.emit()
				return
				
	else: print("This food item cannot be placed here.")
	

func fry_item_if_possible()->void:
	if type == "Stove_Counter" and not is_frying():
		item = counter_top_point.get_child(-1)
		if counter_has_object():
			frying_recipe_so = get_recipe_so_with_input(item.object_name)
			if not item.has_been_on_frying:
				if frying_recipe_so:
					item.has_been_on_frying = true
					print("started frying")
					match handle_prog_on:
						"Food":
							item.fry_timer.start(frying_recipe_so.frying_timer_max) # initialize wait timer for food item fry timer
						"Counter":
							self.fry_timer.start(frying_recipe_so.frying_timer_max) # initialize wait timer for food item fry timer
				else: 
					if prog_bar_sprite and prog_bar_sprite.shown == true:
						prog_bar_sprite._hide()
						prog_bar_sprite.shown = false
			elif item.has_been_on_frying:
				match handle_prog_on:
					"Food":
						if Settings.reset_prog_on_change:
							item.fry_timer.paused = false
							item.fry_timer.start(frying_recipe_so.frying_timer_max)
						else:
							item.fry_timer.paused = false
					"Counter":
						if Settings.reset_prog_on_change:
							self.fry_timer.paused = false
							self.fry_timer.start(frying_recipe_so.frying_timer_max)
						else:
							self.fry_timer.paused = false
			if prog_bar_sprite and prog_bar_sprite.shown == true:
				prog_bar_sprite._hide()
				prog_bar_sprite.shown = false

func spawn_food_on_container(plates_on_top_offset_y : int = 1)->void:
	var anim_player : AnimationPlayer = $CounterAnimations
	if type == "Container_Counter" and anim_player != null:
		anim_player.play("ContainerOpenClose")
	var object : Object = Kitchen_Object.prefab.instantiate()
	counter_top_point.add_child(object, true)
	if type == "Plates_Counter":
		object.position = Vector3(0.0, 0.05 * plates_on_top_offset_y, 0.0)
		object.rotation.y = randf_range(0.0, 360.0)
	print("Spawned (", Kitchen_Object.object_name , ") on ", self.name )
	OnItemChanged.emit()

#endregion


func _process(delta: float) -> void:
	
	handle_spawning_plates(delta)
	
	if counter_top_point.get_child_count() != 0:
		item = counter_top_point.get_child(-1)
	else: item = null
	
	interactor = Globals.find_node("Player")
	handle_lerp_progress_bar()
	handle_prog_bar_max_value()
	set_recipe_so()
	handle_stove_on_and_off_animation()
	handle_burning_meat_effects()
	handle_prog_sprite_visibility()
	set_current_player_and_counter_obj()
func _ready() -> void:
	OnItemChanged.connect(ItemHasChanged)
	for child : Object in get_all_children(self):
		if child is MeshInstance3D:
			if child.mesh.surface_get_material(0) != null:
				mesh_instances.append(child)
				child.mesh.surface_set_material( 0, child.mesh.surface_get_material(0).duplicate() )
				child.get_active_material(0).resource_local_to_scene = true
				child.get_active_material(0).set("emission_enabled", false) # set default to false
		elif child is Sprite3D and child.material_override:
			mesh_instances.append(child)
			child.material_override.set("emission_enabled", false) # set default to false
			
	$counter_name.text = name
	connect("OnHover", Hover)
	connect("OnUnhover", Unhover)
	connect("OnInteract", interact)
	connect("OnInteractAlt", interact_alt)
	
