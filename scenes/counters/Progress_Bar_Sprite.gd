extends Sprite3D
@onready var parent : BaseCounter = $"../.." as BaseCounter
@onready var shown : bool = false
func _ready() -> void:
	if texture:
		texture = get_child(-1).get_texture()
	if material_override:
		material_override.albedo_texture = get_child(-1).get_texture()
	parent.connect("OnProgressChanged", parent.on_cut)

func _show()->void:
	$prog_anim.play("show")
func _hide()->void:
	$prog_anim.play("hide")
