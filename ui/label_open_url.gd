extends RichTextLabel

func _ready() -> void:
	self.meta_clicked.connect(_meta_clicked);

func _meta_clicked(meta : String):
	if meta.begins_with("./"):
		var exe_loc : String = OS.get_executable_path().get_base_dir();
		if OS.get_name() == "macOS":
			exe_loc = exe_loc.path_join("../../../");
		OS.shell_open(exe_loc.path_join(meta));
	else:
		OS.shell_open(meta);
