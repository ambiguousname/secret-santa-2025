extends Node

signal played(name : String);

func play(name : String):
	played.emit(name);

var volume_db : float:
	get():
		var volume : float = Settings.get_setting("master_volume", 100.0)/100.0;
		return log(volume + 0.0001);
