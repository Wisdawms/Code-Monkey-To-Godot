class_name SoundManager extends Node

@onready var dev_man : DeliveryManager = Globals.find_node("DeliveryManager") as DeliveryManager
@onready var sfx : AudioStreamPlayer3D = get_child(0)
@export var audio_clips_references : AudioClipsRefsSO
@onready var player : MyPlayerClass = Globals.find_node("Player") as MyPlayerClass
#@onready var this_counter : BaseCounter = get_parent()

func _ready() -> void:
	dev_man.OrderDelivered.connect(OnOrderDelivered)
	dev_man.OrderFailed.connect(OnOrderFailed)
	
func OnOrderDelivered()->void:
	play_audio_at_pos("delivery_success", player.current_counter.position)
func OnOrderFailed()->void:
	play_audio_at_pos("delivery_fail", player.current_counter.position)

func play_audio_at_pos(audio_clip : String, position : Vector3, volume: float = -20.0)->void:
	var _new_sound : AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	_new_sound.position = position *.2
	_new_sound.volume_db = volume
	_new_sound.stream = audio_clips_references.get(str(audio_clip))[ randi_range(0, audio_clips_references.get(str(audio_clip)).size() -1 )  ]
	add_child(_new_sound)
	_new_sound.play()
