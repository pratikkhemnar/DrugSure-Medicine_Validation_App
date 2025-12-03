// lib/doctor_consultancy/screens/video_call_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/signaling_service.dart';

class VideoCallScreen extends StatefulWidget {
  final SignalingService signaling;
  final String roomId;
  final String localId;
  final String doctorName;

  const VideoCallScreen({
    super.key,
    required this.signaling,
    required this.roomId,
    required this.localId,
    required this.doctorName,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _isConnected = false;
  bool _isMuted = false;
  bool _isVideoOff = false;
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  String _callStatus = 'Connecting...';

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    try {
      await Future.wait([
        _localRenderer.initialize(),
        _remoteRenderer.initialize(),
      ]);

      await _setupLocalStream();
      await _setupPeerConnection();
      _setupSignalingListeners();
      _startCallTimer();
    } catch (e) {
      _updateStatus('Failed to initialize: $e');
    }
  }

  Future<void> _setupLocalStream() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 640},
          'height': {'ideal': 480},
        },
      });

      _localRenderer.srcObject = _localStream;
      if (mounted) setState(() {});
    } catch (e) {
      _updateStatus('Camera/Mic access failed');
    }
  }

  Future<void> _setupPeerConnection() async {
    try {
      final config = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
        ],
      };

      _peerConnection = await createPeerConnection(config);

      _peerConnection!.onIceCandidate = (candidate) {
        if (candidate.candidate != null) {
          widget.signaling.sendIce(widget.roomId, widget.localId, {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          });
        }
      };

      _peerConnection!.onIceConnectionState = (state) {
        if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
          _updateStatus('Connected');
          setState(() => _isConnected = true);
        } else if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
          _updateStatus('Connection failed');
        }
      };

      _peerConnection!.onTrack = (event) {
        if (event.streams.isNotEmpty) {
          _remoteRenderer.srcObject = event.streams[0];
          if (mounted) setState(() {});
        }
      };

      if (_localStream != null) {
        for (var track in _localStream!.getTracks()) {
          _peerConnection!.addTrack(track, _localStream!);
        }
      }

      // Create offer after short delay
      await Future.delayed(const Duration(milliseconds: 500));
      await _createOffer();
    } catch (e) {
      _updateStatus('Peer connection failed: $e');
    }
  }

  void _setupSignalingListeners() {
    widget.signaling.on('offer', _handleOffer);
    widget.signaling.on('answer', _handleAnswer);
    widget.signaling.on('ice-candidate', _handleIceCandidate);
    widget.signaling.on('peer-joined', (data) => debugPrint('Peer joined: $data'));
  }

  Future<void> _handleOffer(dynamic data) async {
    try {
      final sdp = data['sdp'] as Map<String, dynamic>?;
      if (sdp == null) return;

      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']),
      );

      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      widget.signaling.sendAnswer(widget.roomId, widget.localId, {
        'sdp': answer.sdp,
        'type': answer.type,
      });
    } catch (e) {
      debugPrint('Offer handling error: $e');
    }
  }

  Future<void> _handleAnswer(dynamic data) async {
    try {
      final sdp = data['sdp'] as Map<String, dynamic>?;
      if (sdp == null) return;

      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']),
      );
    } catch (e) {
      debugPrint('Answer handling error: $e');
    }
  }

  Future<void> _handleIceCandidate(dynamic data) async {
    try {
      final candidate = data['candidate'];
      if (candidate != null) {
        final iceCandidate = RTCIceCandidate(
          candidate['candidate'],
          candidate['sdpMid'],
          candidate['sdpMLineIndex'],
        );
        await _peerConnection?.addCandidate(iceCandidate);
      }
    } catch (e) {
      debugPrint('ICE candidate error: $e');
    }
  }

  Future<void> _createOffer() async {
    try {
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      widget.signaling.sendOffer(widget.roomId, widget.localId, {
        'sdp': offer.sdp,
        'type': offer.type,
      });
    } catch (e) {
      debugPrint('Create offer error: $e');
    }
  }

  void _toggleMute() {
    if (_localStream == null) return;

    final audioTracks = _localStream!.getAudioTracks();
    if (audioTracks.isNotEmpty) {
      audioTracks.first.enabled = _isMuted;
      setState(() => _isMuted = !_isMuted);
    }
  }

  void _toggleVideo() {
    if (_localStream == null) return;

    final videoTracks = _localStream!.getVideoTracks();
    if (videoTracks.isNotEmpty) {
      videoTracks.first.enabled = _isVideoOff;
      setState(() => _isVideoOff = !_isVideoOff);
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _callDuration += const Duration(seconds: 1));
      }
    });
  }

  void _updateStatus(String status) {
    if (mounted) {
      setState(() => _callStatus = status);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _endCall() async {
    _callTimer?.cancel();

    try {
      _peerConnection?.close();
      _localStream?.getTracks().forEach((track) => track.stop());
      widget.signaling.dispose();
    } catch (e) {
      debugPrint('Error ending call: $e');
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _peerConnection?.close();
    _localStream?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    widget.signaling.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote Video
            Positioned.fill(
              child: _isConnected
                  ? RTCVideoView(
                _remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )
                  : Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.doctorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _callStatus,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      if (!_isConnected)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Local Video Preview
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: RTCVideoView(
                    _localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ),

            // Top Info Bar
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _formatDuration(_callDuration),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Controls
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    color: _isMuted ? Colors.white : Colors.blue,
                    backgroundColor: _isMuted ? Colors.red : Colors.white,
                    onPressed: _toggleMute,
                  ),
                  const SizedBox(width: 20),
                  _ControlButton(
                    icon: Icons.call_end,
                    color: Colors.white,
                    backgroundColor: Colors.red,
                    size: 56,
                    onPressed: _endCall,
                  ),
                  const SizedBox(width: 20),
                  _ControlButton(
                    icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                    color: _isVideoOff ? Colors.white : Colors.blue,
                    backgroundColor: _isVideoOff ? Colors.red : Colors.white,
                    onPressed: _toggleVideo,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.size = 48,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}