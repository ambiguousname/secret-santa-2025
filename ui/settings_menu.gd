class_name SettingsMenu extends Control

@onready var close : Button = $Close;
@onready var install : InstallServer = $InstallServer;

func _ready() -> void:
	close.pressed.connect(func():
		self.visible = false;
	);
