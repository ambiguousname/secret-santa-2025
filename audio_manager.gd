extends Node

@onready var serious_button : AudioStreamPlayer = $SeriousButton;
@onready var silly_button : AudioStreamPlayer = $SillyButton;
@onready var jump : AudioStreamPlayer = $Jump;
@onready var land : AudioStreamPlayer = $Land;
@onready var hit : AudioStreamPlayer = $Hit;
@onready var win : AudioStreamPlayer = $Win;
@onready var lose : AudioStreamPlayer = $Lose;

func _ready() -> void:
	AudioEvent.played.connect(func(n : String):
		if Settings.get_setting("master_volume", 100.0) <= 0 || Settings.get_setting("sfx_volume", 100.0) <= 0.0:
			return;
		var volume_db = AudioEvent.get_volume_db(AudioEvent.AudioType.SFX);
		match n:
			"serious_button":
				serious_button.pitch_scale = 0.5 * randf() + 1.0;
				serious_button.volume_db = volume_db - 5.0;
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
			"win":
				win.volume_db = volume_db;
				win.play();
			"lose":
				lose.volume_db = volume_db;
				lose.play();
			"music_volume_test":
				serious_button.pitch_scale = 0.5 * randf() + 1.0;
				serious_button.volume_db = AudioEvent.get_volume_db(AudioEvent.AudioType.MUSIC) - 5.0;
				serious_button.play();
	);
