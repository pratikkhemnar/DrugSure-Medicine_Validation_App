// lib/doctor_consultancy/screens/video_call_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:drugsuremva/doctor_consultancy/services/signaling_service.dart';

class VideoCallScreen extends StatefulWidget {
  final SignalingService signaling;
  final String roomId;
  final String localId;
  final bool isInitiator;

  const VideoCallScreen({
    super.key,
    required this.signaling,
    required this.roomId,
    required this.localId,
    required this.isInitiator,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _inCall = false;

  @override
  void initState() {
    super.initState();
    initRenderers();
    _setupSignalingListeners();
    _startLocalStreamAndMaybeCreateOffer();
  }

  @override
  void dispose() {
    _disposePeer();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    widget.signaling.dispose();
    super.dispose();
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<MediaStream> _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };
    return await navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  Future<void> _createPeerConnection() async {
    final configuration = <String, dynamic>{
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    };

    final pc = await createPeerConnection(configuration);

    pc.onIceCandidate = (RTCIceCandidate c) {
      if (c.candidate != null) {
        widget.signaling.sendIce(widget.roomId, widget.localId, {
          'candidate': c.candidate,
          'sdpMid': c.sdpMid,
          'sdpMLineIndex': c.sdpMLineIndex,
        });
      }
    };

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
        setState(() {});
      }
    };

    // add local tracks
    if (_localStream != null) {
      for (var t in _localStream!.getTracks()) {
        pc.addTrack(t, _localStream!);
      }
    }

    _peerConnection = pc;
  }

  void _setupSignalingListeners() {
    // Logging
    widget.signaling.onAnyEvent?.call('started-listeners', null);

    // When new peer joins — if initiator, create offer
    widget.signaling.on('peer-joined', (data) {
      print('[VideoCall] peer-joined: $data');
      // Optionally create offer if you are the initiator and someone joined
      if (widget.isInitiator) {
        _createOffer();
      }
    });

    // Handle incoming offer
    widget.signaling.on('offer', (data) async {
      print('[VideoCall] offer: $data');
      // data expected: { roomId, from, sdp }
      final sdp = data['sdp'] as Map<String, dynamic>?;
      if (sdp != null) {
        await _ensurePeer();
        await _peerConnection?.setRemoteDescription(RTCSessionDescription(sdp['sdp'], sdp['type']));
        final RTCSessionDescription answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);
        widget.signaling.sendAnswer(widget.roomId, widget.localId, {'sdp': answer.sdp, 'type': answer.type});
      }
    });

    // Handle incoming answer
    widget.signaling.on('answer', (data) async {
      print('[VideoCall] answer: $data');
      final sdp = data['sdp'] as Map<String, dynamic>?;
      if (sdp != null) {
        await _peerConnection?.setRemoteDescription(RTCSessionDescription(sdp['sdp'], sdp['type']));
      }
    });

    // ICE candidate from remote
    widget.signaling.on('ice-candidate', (data) async {
      try {
        final candidate = data['candidate'] ?? data['candidateMap'] ?? data;
        if (candidate != null) {
          final cand = RTCIceCandidate(candidate['candidate'], candidate['sdpMid'], candidate['sdpMLineIndex']);
          await _peerConnection?.addCandidate(cand);
        }
      } catch (e) {
        print('[VideoCall] addCandidate error $e');
      }
    });
  }

  Future<void> _ensurePeer() async {
    if (_peerConnection == null) {
      await _createPeerConnection();
    }
  }

  Future<void> _startLocalStreamAndMaybeCreateOffer() async {
    _localStream = await _getUserMedia();
    _localRenderer.srcObject = _localStream;
    setState(() {});
    await _ensurePeer();

    // If initiator and already someone in room? we'll create offer on peer-joined events.
    if (widget.isInitiator) {
      // either wait for peer-joined event or try to create an offer (works for simple tests)
      await Future.delayed(const Duration(milliseconds: 400));
      _createOffer();
    }
  }

  Future<void> _createOffer() async {
    try {
      await _ensurePeer();
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      // send offer via signaling
      widget.signaling.sendOffer(widget.roomId, widget.localId, {'sdp': offer.sdp, 'type': offer.type});
      print('[VideoCall] Offer sent');
    } catch (e) {
      print('[VideoCall] createOffer error $e');
    }
  }

  void _disposePeer() {
    try {
      _peerConnection?.close();
      _peerConnection = null;
      _localStream?.getTracks().forEach((t) => t.stop());
      _localStream = null;
    } catch (e) {
      print('[VideoCall] disposePeer error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end),
            onPressed: () {
              _disposePeer();
              widget.signaling.dispose();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
          ),
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    color: Colors.black87,
                    child: RTCVideoView(_localRenderer, mirror: true),
                  ),
                ),
                // optionally controls column
                Container(
                  width: 120,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _createOffer();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Re-offer'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          _disposePeer();
                          setState(() {});
                        },
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
