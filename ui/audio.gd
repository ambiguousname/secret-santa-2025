class_name Audio extends Control

@onready var master_volume : HSlider = %MasterVolume;

func _ready() -> void:
	master_volume.value = Settings.get_setting("master_volume", master_volume.value);
	master_volume.drag_ended.connect(func(changed : bool):
		if changed:
			Settings.set_setting("master_volume", master_volume.value);
			Settings.save();
			# TODO: Play sample SFX
	);
