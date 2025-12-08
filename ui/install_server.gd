extends Control

@onready var install : Button = $Grid/Install;

@onready var mods_dir : Button = $Grid/ModsDir/Button;
@onready var mods_dir_edit : LineEdit = $Grid/ModsDir/LineEdit;
@onready var mods_dir_label : Label = $Grid/StepThree;

@onready var file_diag : FileDialog = $FileDialog;

const FAIL : String = "❌";
const SUCCEED : String = "✅";
var fail_label : LabelSettings = preload("uid://co2wg8bh6obmh");
var succeed_label : LabelSettings = preload("uid://dtp60wsp8bcae");

func _ready() -> void:
	install.pressed.connect(func():
		OS.shell_open("https://github.com/fifty-six/Scarab/releases");
	);
	
	mods_dir.pressed.connect(func():
		file_diag.popup_centered();
	);
	
	file_diag.dir_selected.connect(func(dir : String):
		mods_dir_edit.text = dir;
	);

func _folder_select_fail():
	pass;
