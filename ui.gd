class_name UI extends Control

@onready var tcp_status : Label = $TCPStatus;

func update_tcp_status(text : String):
	tcp_status.text = text;
