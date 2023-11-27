class_name SoundManager extends Node

@onready var game_man : GameManager = Globals.find_node("GameManager") as GameManager
@onready var dev_man : DeliveryManager = Globals.find_node("DeliveryManager") as DeliveryManager
@onready var sfx : AudioStreamPlayer3D = get_child(0)
@export var audio_clips_references : AudioClipsRefsSO
@onready var player : MyPlayerClass = Globals.find_node("Player") as MyPlayerClass
var volume : float = 1.0
#@onready var this_counter : BaseCounter = get_parent()

func _ready() -> void:
	if game_man:
		game_man.sound_effects_volume_button.pressed.connect(on_sfx_vol_button_pressed)
		game_man.music_volume_button.pressed.connect(on_music_vol_button_pressed)
	if dev_man:
		dev_man.OrderDelivered.connect(OnOrderDelivered)
		dev_man.OrderFailed.connect(OnOrderFailed)
		
func OnOrderDelivered()->void:
	play_audio_at_pos("delivery_success", player.current_counter.position)
func OnOrderFailed()->void:
	play_audio_at_pos("delivery_fail", player.current_counter.position)
func play_audio_at_pos(audio_clip : String, position : Vector3, volume_mult: float = -20.0, loop : bool = false)->AudioStreamPlayer3D:
	var _new_sound : AudioStreamPlayer3D = AudioStreamPlayer3D.new() as AudioStreamPlayer3D
	var sound_file : AudioStream = audio_clips_references.get(str(audio_clip))[ randi_range(0, audio_clips_references.get(str(audio_clip)).size() -1 )  ]
	var sound_length : float = sound_file.get_length()
	add_child(_new_sound, true)	
	_new_sound.stream = sound_file
	_new_sound.position = position *.2
	_new_sound.volume_db = volume_mult * volume
	match loop:
		false:
			_new_sound.stream.loop_mode = 0
			_new_sound.finished.connect( destroy_audio.bind(_new_sound) )
		true:
			_new_sound.stream.loop_mode = 1
			_new_sound.stream.loop_end = sound_length*_new_sound.stream.mix_rate
	_new_sound.play()
	return _new_sound
func destroy_audio(this_sound : AudioStreamPlayer3D)->void:
	this_sound.queue_free()

#func play_audio_from_array(audio_clip : String, audio_array, volume, loop : bool = false)->void:
	## assuming I have AudioStreamPlayer3D
	#var _new_sound : AudioStreamPlayer3D = AudioStreamPlayer3D.new() as AudioStreamPlayer3D
	#var sound_file : AudioStream = audio_array.get( str(audio_clip) )[ randi_range(0, audio_array.get(str(audio_clip)).size() -1 )  ]
	#var sound_length : float = sound_file.get_length()
	#add_child(_new_sound)	

func on_sfx_vol_button_pressed()->void:
	pass

func on_music_vol_button_pressed()->void:
	pass
	
func change_volume()->void:
	volume += .1
	if volume > 1.0:
		volume = 0.0
