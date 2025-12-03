// lib/doctor_consultancy/services/signaling_service.dart
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SignalingService {
  IO.Socket? _socket;
  final String serverUrl;
  final Map<String, List<Function(dynamic)>> _listeners = {};
  final void Function(String event, dynamic data)? onAnyEvent;

  SignalingService({
    required this.serverUrl,
    this.onAnyEvent,
  });

  Future<void> init() async {
    try {
      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setTimeout(10000)
            .enableAutoConnect()
            .build(),
      );

      _socket?.onConnect((_) {
        debugPrint('[Signaling] Connected - ID: ${_socket?.id}');
      });

      _socket?.onDisconnect((_) {
        debugPrint('[Signaling] Disconnected');
      });

      _socket?.onConnectError((error) {
        debugPrint('[Signaling] Connect error: $error');
      });

      _socket?.onError((error) {
        debugPrint('[Signaling] Error: $error');
      });

      // Handle all incoming events
      _socket?.onAny((event, data) {
        debugPrint('[Signaling] Received: $event');
        onAnyEvent?.call(event, data);

        final listeners = _listeners[event];
        if (listeners != null) {
          for (final listener in listeners) {
            listener(data);
          }
        }
      });

      // Wait for connection
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('[Signaling] Init failed: $e');
      rethrow;
    }
  }

  void joinRoom(String roomId, String userId) {
    _socket?.emit('join-room', {
      'roomId': roomId,
      'userId': userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void sendOffer(String roomId, String from, Map<String, dynamic> sdp) {
    _socket?.emit('offer', {
      'roomId': roomId,
      'from': from,
      'sdp': sdp,
    });
  }

  void sendAnswer(String roomId, String from, Map<String, dynamic> sdp) {
    _socket?.emit('answer', {
      'roomId': roomId,
      'from': from,
      'sdp': sdp,
    });
  }

  void sendIce(String roomId, String from, Map<String, dynamic> candidate) {
    _socket?.emit('ice-candidate', {
      'roomId': roomId,
      'from': from,
      'candidate': candidate,
    });
  }

  void on(String event, Function(dynamic) callback) {
    _listeners.putIfAbsent(event, () => []).add(callback);
  }

  void off(String event, [Function(dynamic)? callback]) {
    final listeners = _listeners[event];
    if (listeners != null && callback != null) {
      listeners.remove(callback);
    } else {
      _listeners.remove(event);
    }
  }

  void dispose() {
    _socket?.disconnect();
    _socket = null;
    _listeners.clear();
    debugPrint('[Signaling] Disposed');
  }

  bool get isConnected => _socket?.connected == true;
}