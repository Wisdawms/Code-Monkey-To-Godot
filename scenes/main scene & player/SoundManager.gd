class_name SoundManager extends Node

@onready var sfx : AudioStreamPlayer3D
@export var audio_clips_references : AudioClipsRefsSO
@onready var sfx_volume : float = 1.0
@onready var music_volume : float = 0.0
@onready var clamped_volume : float = lerp(-50.0, -10.0, music_volume)


func _ready() -> void:
	game_man.OnGamePaused.connect(mute_audio)
	game_man.OnGameUnpaused.connect(mute_audio)
	if get_children():
		sfx = get_child(0)
	sfx_volume = PlayerPrefs.get_pref("sfx_vol", 0.7)
	music_volume = PlayerPrefs.get_pref("music_vol", 0.7)
	MusicManager.get_child(0).volume_db = lerp(-50.0, -10.0, music_volume)
	game_man.sound_effects_volume_button.text = "Sound Effects : " + str(sfx_volume * 10)
	game_man.music_volume_button.text = "Music : " +  str(music_volume * 10)
	game_man.sound_effects_volume_button.button_up.connect(on_sfx_vol_button_pressed)
	game_man.music_volume_button.button_up.connect(on_music_vol_button_pressed)
	dev_man.OrderDelivered.connect(OnOrderDelivered)
	dev_man.OrderFailed.connect(OnOrderFailed)
		
func OnOrderDelivered()->void:
	play_audio_at_pos("delivery_success", Globals.find_node("Player").current_counter.position)
func OnOrderFailed()->void:
	play_audio_at_pos("delivery_fail", Globals.find_node("Player").current_counter.position)
func play_audio_at_pos(audio_clip : String, position : Vector3, loop : bool = false, volume_mult: float = 5.0)->AudioStreamPlayer3D:
	var _new_sound : AudioStreamPlayer3D = AudioStreamPlayer3D.new() as AudioStreamPlayer3D
	var sound_file : AudioStream = audio_clips_references.get(str(audio_clip))[ randi_range(0, audio_clips_references.get(str(audio_clip)).size() -1 )  ]
	_new_sound.name = audio_clip
	var sound_length : float = sound_file.get_length()
	add_child(_new_sound, true)	
	_new_sound.stream = sound_file
	_new_sound.position = position *.2
	_new_sound.volume_db = volume_mult
	_new_sound.unit_size = 1 * sfx_volume
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

#func play_audio_from_array(audio_clip : String, audio_array, sfx_volume, loop : bool = false)->void:
	## assuming I have AudioStreamPlayer3D
	#var _new_sound : AudioStreamPlayer3D = AudioStreamPlayer3D.new() as AudioStreamPlayer3D
	#var sound_file : AudioStream = audio_array.get( str(audio_clip) )[ randi_range(0, audio_array.get(str(audio_clip)).size() -1 )  ]
	#var sound_length : float = sound_file.get_length()
	#add_child(_new_sound)	

func on_sfx_vol_button_pressed()->void:
	change_sfx_volume()
	
func on_music_vol_button_pressed()->void:
	change_music_volume()

func change_sfx_volume()->void:
	sfx_volume += .1
	if sfx_volume > 1.0:
		sfx_volume = 0.0
	game_man.sound_effects_volume_button.text = "Sound Effects : " + str(sfx_volume * 10)
	PlayerPrefs.set_pref("sfx_vol", sfx_volume)
	PlayerPrefs.save_data()
	
	
func change_music_volume()->void:
	music_volume += .1
	if music_volume > 1.0:
		music_volume = 0.0
	game_man.music_volume_button.text = "Music : " +  str(music_volume * 10)
	clamped_volume = lerp(-50.0, -10.0, music_volume)
	MusicManager.get_child(0).volume_db = clamped_volume
	PlayerPrefs.set_pref("music_vol", music_volume)
	PlayerPrefs.save_data()
	
func mute_audio()->void:
	for child in get_children():
		if child is AudioStreamPlayer3D:
			var old_vol = child.volume_db
			if game_man.is_game_paused:
				child.playing = false
			else:
				child.playing = true
