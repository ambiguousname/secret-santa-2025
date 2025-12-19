class_name TCPClient extends Node

var peer : StreamPeerTCP = StreamPeerTCP.new();

enum Status {
	UNACKNOWLEDGED,
	AWAITING_ACKNOWLEDGEMENT,
	CONNECTED,
	DISCONNECTED
};

var _status : Status = Status.DISCONNECTED;

var should_connect : bool = false;
var has_connection : bool = false;

signal status_updated(s : Status);
signal game_state_update(d : Dictionary);

func connect_to_host() -> Error:
	print("Attempting to connect...");
	if peer.get_status() != 0:
		peer.disconnect_from_host();
	_status = Status.UNACKNOWLEDGED;
	status_updated.emit(_status);
	
	var res = peer.connect_to_host("127.0.0.1", 5121);
	if res != OK:
		# TODO: Error printing to user if socket is already in use.
		# TODO: Add config.toml to C# mod to configure port.
		printerr("Could not open TCP socket! Error: %s" % res);
	return res;

func disconnect_from_host():
	peer.disconnect_from_host();
	_status = Status.DISCONNECTED;
	status_updated.emit(_status);

const MAGIC_SEND : String = "BuddyClient";
const MAGIC_RECEIVE : String = "BuddyServer";

func _connected_process():
	if _status == Status.UNACKNOWLEDGED:
		print("Found server! Sending handshake...");
		peer.put_data(MAGIC_SEND.to_ascii_buffer());
		
		_status = Status.AWAITING_ACKNOWLEDGEMENT;
		status_updated.emit(_status);
	var available_bytes = peer.get_available_bytes();
	if available_bytes > 0:
		if _status == Status.AWAITING_ACKNOWLEDGEMENT && available_bytes >= MAGIC_RECEIVE.length():
			var out = peer.get_string(MAGIC_RECEIVE.length());
			if out != MAGIC_RECEIVE:
				print("Handshake failed! Got: %s" % out);
				peer.disconnect_from_host();
				return;
			print("Handshake succeeded!");
			has_connection = true;
			
			_status = Status.CONNECTED;
			status_updated.emit(_status);
			return;
		else:
			var d = JSON.parse_string(peer.get_string(available_bytes));
			if d != null:
				game_state_update.emit(d);
@onready var timer : Timer = $Timer;

func _ready() -> void:
	timer.timeout.connect(connect_to_host);

func _process(delta: float) -> void:
	if peer == null || should_connect == false:
		return;
	peer.poll();
	match peer.get_status():
		peer.STATUS_CONNECTING:
			pass;
		peer.STATUS_CONNECTED:
			_connected_process();
		peer.STATUS_ERROR:
			print("TCP Client is in error state! Most likely no host was found. Disconnecting...");
			peer.disconnect_from_host();
		peer.STATUS_NONE:
			if _status != Status.DISCONNECTED:
				_status = Status.DISCONNECTED;
				timer.start();
				status_updated.emit(_status);
				has_connection = false;
				print("Disconnected. Retrying in %f seconds..." % timer.wait_time);
				# Try again:
