extends Node2D

var peer : StreamPeerTCP = StreamPeerTCP.new();
var sent_acknowledgement : bool = false;
var acknowledged : bool = false;
func _ready() -> void:
	var res = peer.connect_to_host("127.0.0.1", 5121);
	if res != OK:
		print("Could not open TCP socket! Error: %s" % res);

const MAGIC_SEND : String = "BuddyClient";
const MAGIC_RECEIVE : String = "BuddyServer";

func _connected_process():
	if !sent_acknowledgement:
		print("Found server! Sending handshake...");
		peer.put_data(MAGIC_SEND.to_ascii_buffer());
		sent_acknowledgement = true;
	var available_bytes = peer.get_available_bytes();
	if available_bytes > 0:
		if !acknowledged && available_bytes >= MAGIC_RECEIVE.length():
			var out = peer.get_string(MAGIC_RECEIVE.length());
			if out != MAGIC_RECEIVE:
				print("Handshake failed! Got: %s" % out);
				peer.disconnect_from_host();
				return;
			print("Handshake succeeded!");
			acknowledged = true;
			return;
		else:
			pass;

func _process(delta: float) -> void:
	if peer == null:
		return;
	peer.poll();
	var status = peer.get_status();
	match peer.get_status():
		peer.STATUS_CONNECTED:
			_connected_process();
		peer.STATUS_ERROR:
			print("TCP Client is in error state!");
			peer.disconnect_from_host();
		peer.STATUS_NONE:
			# TODO: reconnect attempts.
			pass;
