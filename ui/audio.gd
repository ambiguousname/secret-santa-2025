class_name Audio extends Control

@onready var master_volume : HSlider = %MasterVolume;
@onready var sfx_volume : HSlider = %SFXVolume;
@onready var music_volume : HSlider = %MusicVolume;

func _ready() -> void:
	master_volume.value = Settings.get_setting("master_volume", master_volume.value);
	master_volume.drag_ended.connect(func(changed : bool):
		if changed:
			Settings.set_setting("master_volume", master_volume.value);
			Settings.save();
			AudioEvent.play("serious_button");
	);
	
	sfx_volume.value = Settings.get_setting("sfx_volume", sfx_volume.value);
	sfx_volume.drag_ended.connect(func(changed: bool):
		if changed:
			Settings.set_setting("sfx_volume", sfx_volume.value);
			Settings.save();
			AudioEvent.play("serious_button");
	);
	
	music_volume.value = Settings.get_setting("music_volume", music_volume.value);
	music_volume.drag_ended.connect(func(changed: bool):
		if changed:
			Settings.set_setting("music_volume", music_volume.value);
			Settings.save();
			AudioEvent.play("music_volume_test");
	);
	
	
