extends Control

@onready var install : Button = $Grid/Install;

@onready var mods_dir : Button = $Grid/ModsDir/Button;
@onready var mods_dir_edit : LineEdit = $Grid/ModsDir/LineEdit;
@onready var mods_dir_label : Label = $Grid/StepTwo;

@onready var file_diag : FileDialog = $FileDialog;

const FAIL : String = "❌";
const SUCCEED : String = "✅";
var fail_label : LabelSettings = preload("uid://co2wg8bh6obmh");
var succeed_label : LabelSettings = preload("uid://dtp60wsp8bcae");

func _ready() -> void:
	mods_dir_edit.text = Settings.get_setting("mods_dir", "");
	_test_folder(Settings.get_setting("mods_dir", ""));
	
	install.pressed.connect(func():
		OS.shell_open("https://github.com/fifty-six/Scarab/releases");
	);
	
	mods_dir.pressed.connect(func():
		file_diag.popup_centered();
	);
	
	file_diag.dir_selected.connect(_test_folder);

func _test_folder(dir : String):
	var folder_name : String = dir.get_file();
	
	if folder_name != "Mods":
		match folder_name:
			"Managed":
				dir = dir.path_join("Mods");
			"hollow_knight_Data":
				dir = dir.path_join("Managed/Mods");
			"Hollow Knight":
				dir = dir.path_join("hollow_knight_Data/Managed/Mods");
			_:
				_folder_select_fail();
		pass;
	
	if !DirAccess.dir_exists_absolute(dir) || !DirAccess.dir_exists_absolute(dir.path_join("../../../../Hollow Knight")):
		_folder_select_fail();
		return;
	
	mods_dir_edit.text = dir;
	Settings.set_setting("mods_dir", dir);
	Settings.save();
	
	_folder_select_succeed();

@onready var initial_mods_dir_text : String = mods_dir_label.text;
func _folder_select_fail():
	mods_dir_label.label_settings = fail_label;
	mods_dir_label.text = "%s %s" % [FAIL, initial_mods_dir_text];

func _folder_select_succeed():
	mods_dir_label.label_settings = succeed_label;
	mods_dir_label.text = "%s %s" % [SUCCEED, initial_mods_dir_text];
