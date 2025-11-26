// lib/doctor_consultancy/services/signaling_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Simple signaling wrapper around socket.io-client for flutter.
/// Emits/receives events: join-room, peer-joined, offer, answer, ice-candidate
class SignalingService {
  IO.Socket? socket;
  final String serverUrl;
  final void Function(String event, dynamic data)? onAnyEvent;

  SignalingService({
    required this.serverUrl,
    this.onAnyEvent,
  });

  void init() {
    print('[Signaling] init -> $serverUrl');
    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    socket?.onConnect((_) {
      print('[Signaling] connected: ${socket?.id}');
    });

    socket?.onDisconnect((_) {
      print('[Signaling] disconnected');
    });

    socket?.onError((err) {
      print('[Signaling] connect_error: $err');
    });

    // generic handler to view incoming traffic
    socket?.onAny((event, data) {
      print('[Signaling] onAny -> $event : $data');
      if (onAnyEvent != null) onAnyEvent!(event, data);
    });
  }

  void joinRoom(String roomId, String userId) {
    socket?.emit('join-room', {'roomId': roomId, 'userId': userId});
    print('[Signaling] joinRoom -> $roomId / $userId');
  }

  void sendOffer(String roomId, String from, Map<String, dynamic> sdp) {
    socket?.emit('offer', {'roomId': roomId, 'from': from, 'sdp': sdp});
    print('[Signaling] sendOffer');
  }

  void sendAnswer(String roomId, String from, Map<String, dynamic> sdp) {
    socket?.emit('answer', {'roomId': roomId, 'from': from, 'sdp': sdp});
    print('[Signaling] sendAnswer');
  }

  void sendIce(String roomId, String from, Map<String, dynamic> candidate) {
    socket?.emit('ice-candidate', {'roomId': roomId, 'from': from, 'candidate': candidate});
    // small log to avoid huge spam
  }

  void on(String event, Function(dynamic) cb) {
    socket?.on(event, (data) => cb(data));
  }

  void off(String event) {
    socket?.off(event);
  }

  void dispose() {
    try {
      socket?.disconnect();
      socket = null;
      print('[Signaling] disposed');
    } catch (e) {
      print('[Signaling] dispose error: $e');
    }
  }
}
