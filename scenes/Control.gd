extends RichTextLabel

func _ready() -> void:
	text = get_parent().get_parent().get_parent().get_parent().get_parent().name
