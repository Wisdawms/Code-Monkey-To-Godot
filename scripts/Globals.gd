extends Node

var run_once : bool = true

func find_node(node_name : String)->Object:
	return get_tree().get_root().find_child(node_name, true, false)

func call_once(function : String)->void:
	call(function)
