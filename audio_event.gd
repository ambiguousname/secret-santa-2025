extends Node

signal played(name : String);

func play(name : String):
	played.emit(name);

enum AudioType {
	SFX,
	MUSIC
};

func get_volume_db(type : AudioType) -> float:
	var master : float = Settings.get_setting("master_volume", 100.0)/100.0;
	var volume = master;
	match type:
		AudioType.SFX:
			volume *= Settings.get_setting("sfx_volume", 100.0)/100.0;
		AudioType.MUSIC:
			volume *= Settings.get_setting("music_volume", 100.0)/100.0;
	volume = volume * 100;
	return -2.5 * log(101 - volume);
