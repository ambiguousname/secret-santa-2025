extends Node

@onready var serious_button : AudioStreamPlayer = $SeriousButton;

func _ready() -> void:
	AudioEvent.played.connect(func(n : String):
		var volume : float = Settings.get_setting("master_volume", 100.0)/100.0;
		var volume_db = log(volume + 0.0001);
		if volume <= 0:
			return;
		match n:
			"serious_button":
				serious_button.pitch_scale = 0.5 * randf() + 1.0;
				serious_button.volume_db = volume_db;
				serious_button.play();
	);
