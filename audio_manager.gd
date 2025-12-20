extends Node

@onready var serious_button : AudioStreamPlayer = $SeriousButton;

func _ready() -> void:
	AudioEvent.played.connect(func(n : String):
		match n:
			"serious_button":
				serious_button.pitch_scale = 0.5 * randf() + 1.0;
				serious_button.play();
	);
