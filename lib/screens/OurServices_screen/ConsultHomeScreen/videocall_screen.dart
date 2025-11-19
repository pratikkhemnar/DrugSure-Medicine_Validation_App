// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
//
// class ConsultScreen extends StatefulWidget {
//   final String peerUserId;
//   final String peerName;
//
//   ConsultScreen({required this.peerUserId, required this.peerName});
//
//   @override
//   _ConsultScreenState createState() => _ConsultScreenState();
// }
//
// class _ConsultScreenState extends State<ConsultScreen> {
//   late String currentUserId;
//   late String callId;
//   bool inCall = false;
//
//   @override
//   void initState() {
//     super.initState();
//     currentUserId = FirebaseAuth.instance.currentUser!.uid;
//
//     // Generate callId based on both users' IDs
//     callId = currentUserId.hashCode <= widget.peerUserId.hashCode
//         ? '${currentUserId}_${widget.peerUserId}'
//         : '${widget.peerUserId}_$currentUserId';
//   }
//
//   // Start video call
//   void startVideoCall() {
//     setState(() {
//       inCall = true;
//     });
//   }
//
//   // End video call
//   void endVideoCall() {
//     setState(() {
//       inCall = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Video Call with ${widget.peerName}"),
//         actions: [
//           IconButton(
//             icon: Icon(
//               inCall ? Icons.call_end : Icons.video_call,
//               color: Colors.white,
//             ),
//             onPressed: () {
//               if (inCall) {
//                 endVideoCall();
//               } else {
//                 startVideoCall();
//               }
//             },
//           ),
//         ],
//       ),
//       body: inCall
//           ? ZegoUIKitPrebuiltCall(
//         appID: 477172121, // Replace with your ZegoCloud AppID
//         appSign:
//         'ff5fd3e9252ba76292239f9ad4dfbbb5d4f21a0954e55234de8a4c9af4706161', // Replace with your AppSign
//         userID: currentUserId,
//         userName: 'Patient', // Use actual name dynamically if needed
//         callID: callId,
//         config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
//       )
//           : Center(
//         child: ElevatedButton.icon(
//           icon: Icon(Icons.video_call),
//           label: Text("Start Video Call"),
//           onPressed: startVideoCall,
//         ),
//       ),
//     );
//   }
// }
