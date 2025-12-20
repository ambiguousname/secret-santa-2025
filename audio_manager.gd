extends Node

@onready var serious_button : AudioStreamPlayer = $SeriousButton;
@onready var silly_button : AudioStreamPlayer = $SillyButton;
@onready var jump : AudioStreamPlayer = $Jump;
@onready var land : AudioStreamPlayer = $Land;
@onready var hit : AudioStreamPlayer = $Hit;

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
			"silly_button":
				silly_button.pitch_scale = 0.5 * randf() + 1.0;
				silly_button.volume_db = volume_db;
				silly_button.play();
			"jump":
				jump.pitch_scale = 0.5 * randf() + 1.0;
				jump.volume_db = volume_db;
				jump.play();
			"land":
				land.pitch_scale = 0.5 * randf() + 1.0;
				land.volume_db = volume_db;
				land.play();
			"hit":
				hit.volume_db = volume_db;
				hit.play();
	);
