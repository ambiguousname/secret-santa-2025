class_name InstallServer extends Control

@onready var install : Button = $Grid/Install;

@onready var mods_dir : Button = $Grid/ModsDir/Button;
@onready var mods_dir_edit : LineEdit = $Grid/ModsDir/LineEdit;
@onready var mods_dir_label : Label = $Grid/StepTwo;

@onready var install_server : Button = $Grid/ServerInstall;
@onready var install_server_label : Label = $Grid/StepThree;

@onready var file_diag : FileDialog = $FileDialog;

@onready var error_text : RichTextLabel = $ErrorText;

const FAIL : String = "❌";
const SUCCEED : String = "✅";
var fail_label : LabelSettings = preload("uid://co2wg8bh6obmh");
var succeed_label : LabelSettings = preload("uid://dtp60wsp8bcae");

const LIB_NAME : String = "BuddyServer.dll";
signal connectable_changed(can_connect : bool);
var connectable : bool:
	get():
		return FileAccess.file_exists(Settings.get_setting("mods_dir", "").path_join("BuddyServer/%s" % LIB_NAME));

func _ready() -> void:
	var mods_dir_set = Settings.get_setting("mods_dir", "");
	if mods_dir_set != "":
		mods_dir_edit.text = mods_dir_set;
		_test_folder(mods_dir_set);
	
	# TODO: Verify hash of DLL if mods dir is valid.
	
	install.pressed.connect(func():
		OS.shell_open("https://github.com/fifty-six/Scarab/releases");
	);
	
	mods_dir.pressed.connect(func():
		file_diag.popup_centered();
	);
	
	file_diag.dir_selected.connect(_test_folder);
	
	mods_dir_edit.text_submitted.connect(_test_folder);
	
	install_server.pressed.connect(func(): 
		var exe_loc : String = OS.get_executable_path().get_base_dir();
		if OS.get_name() == "macOS":
			exe_loc = exe_loc.path_join("../../../");
		
		var lib_loc = exe_loc.path_join(LIB_NAME);
		var dir = Settings.get_setting("mods_dir", "");
		if dir == "" || !DirAccess.dir_exists_absolute(dir):
			_install_server_fail();
			error_text.text = "[color=red]Could not install server. Directory \"[code]%s[/code]\" does not exist.[/color]" % dir;
			return;
		var mod_dir = dir.path_join("BuddyServer");
		
		var make_res : Error = DirAccess.make_dir_recursive_absolute(mod_dir);
		if make_res != OK:
			_install_server_fail();
			error_text.text = "[color=red]Could not install server. Could not create BuddyServer folder in Directory \"[code]%s[/code]\". Error code %d" % [dir, make_res];
			return;
		
		var res : Error = DirAccess.copy_absolute(lib_loc, mod_dir.path_join(LIB_NAME));
		if res != OK:
			_install_server_fail();
			error_text.text = "[color=red]Could not install server. Copy of BuddyServer.dll failed. Error code %d" % res;
			return;
		_install_server_succeeded();
	);
	if connectable:
		_install_server_succeeded();

func _test_folder(dir : String):
	var folder_name : String = dir.get_file();
	
	var os_name = OS.get_name();
	if folder_name != "Mods":
		match os_name:
			"Windows":
				match folder_name:
					"Managed":
						dir = dir.path_join("Mods");
					"hollow_knight_Data":
						dir = dir.path_join("Managed/Mods");
					"Hollow Knight":
						dir = dir.path_join("hollow_knight_Data/Managed/Mods");
					_:
						error_text.text = "[color=red]Could not set mods folder. Folder %s not recognized (try finding hollow_knight_Data folder)[/color]" % dir;
						_folder_select_fail();
			"macOS":
				match folder_name:
					"Managed":
						dir = dir.path_join("Mods");
					"Hollow Knight":
						dir = dir.path_join("hollow_knight.app/Contents/Resources/Data/Managed/Mods");
					"hollow_knight.app":
						dir = dir.path_join("Contents/Resources/Data/Managed/Mods");
					_:
						error_text.text = "[color=red]Could not set mods folder. Folder %s not recognized (try finding hollow_knight.app file)[/color]" % dir;
						_folder_select_fail();
			_:
				error_text.text = "[color=red]Could not set mods folder. Directory %s not recognized.[/color]" % dir;
				_folder_select_fail();
	
	# If everything but "Mods" exists, make a mods folder:
	if DirAccess.dir_exists_absolute(dir.path_join("..")):
		DirAccess.make_dir_absolute(dir);
	if !DirAccess.dir_exists_absolute(dir):
		error_text.text = "[color=red]Could not set mods folder. Directory \"%s\" does not exist.[/color]" % dir;
		_folder_select_fail();
		return;
	
	if os_name == "Windows" && !DirAccess.dir_exists_absolute(dir.path_join("../../../../Hollow Knight")):
		error_text.text = "[color=red]Could not set mods folder. Mods folder does not exist in Hollow Knight game folder.[/color]" % dir;
		_folder_select_fail();
		return;
	if os_name == "macOS" && !DirAccess.dir_exists_absolute(dir.path_join("../../../../../../hollow_knight.app")):
		error_text.text = "[color=red]Could not set mods folder. Mods folder does not exist in [code]hollow_knight.app[/code].[/color]" % dir;
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
	connectable_changed.emit(false);

func _folder_select_succeed():
	mods_dir_label.label_settings = succeed_label;
	mods_dir_label.text = "%s %s" % [SUCCEED, initial_mods_dir_text];

@onready var initial_server_text : String = install_server_label.text;
func _install_server_fail():
	install_server_label.label_settings = fail_label;
	install_server_label.text = "%s %s" % [FAIL, initial_server_text];
	connectable_changed.emit(false);

func _install_server_succeeded():
	install_server_label.label_settings = succeed_label;
	install_server_label.text = "%s %s" % [SUCCEED, initial_server_text];
	connectable_changed.emit(true);
