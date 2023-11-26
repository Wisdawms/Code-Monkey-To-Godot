class_name LoadingScene extends CanvasLayer

@onready var target_scene : String = "res://scenes/main scene & player/main_scene.tscn"
@onready var progress_bar := $VBoxContainer/ProgressBar
@onready var progress : Array[float]
@onready var loading_status := 0

func _ready() -> void:
	ResourceLoader.load_threaded_request(target_scene)
	
func _process(delta: float) -> void:
	loading_status = ResourceLoader.load_threaded_get_status(target_scene, progress)
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] * 100
		ResourceLoader.THREAD_LOAD_LOADED:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(target_scene))
		ResourceLoader.THREAD_LOAD_FAILED:
			print("ERROR! Could not load target scene.")

