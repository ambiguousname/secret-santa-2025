class_name ItemDisplay extends Button

var texture : Texture2D:
	set(v):
		self.add_theme_icon_override("icon", v);
