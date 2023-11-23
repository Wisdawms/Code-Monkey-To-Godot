extends Node

@export var can_replace_objects_on_normal_counter_bool : bool = true
@export var can_replace_objects_on_cutting_counter_bool : bool = true
@export var can_replace_objects_on_frying_counter_bool : bool = true
@export var reset_prog_on_change : bool = true

func can_replace_objects_on_cutting_counter(counter : BaseCounter)->bool:
	return counter.type == "Cutting_Counter" and can_replace_objects_on_cutting_counter_bool
func can_replace_objects_on_normal_counter(counter:BaseCounter)->bool:
	return counter.type == "Clear_Counter" or counter.type == "Container_Counter" and can_replace_objects_on_normal_counter_bool
func can_replace_objects_on_frying_counter(counter:BaseCounter)->bool:
	return counter.type == "Stove_Counter" and can_replace_objects_on_frying_counter_bool
