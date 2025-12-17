class_name SettingsMenu extends Control

@onready var close : Button = $Close;
@onready var tabs : TabContainer = $TabContainer;
@onready var install : InstallServer = $TabContainer/InstallServer;

func _ready() -> void:
	tabs.set_tab_title(0, "Hollow Knight");
