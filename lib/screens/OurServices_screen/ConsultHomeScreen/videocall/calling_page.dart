// import 'dart:math';
// import 'package:drugsuremva/screens/OurServices_screen/ConsultHomeScreen/videocall/constants.dart';
// import 'package:drugsuremva/screens/OurServices_screen/ConsultHomeScreen/videocall/video_screen.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
//
// class CallingPage extends StatefulWidget {
//   const CallingPage({super.key , required this.callId});
//
//   final String callId;
//   @override
//   State<CallingPage> createState() => _CallingPageState();
// }
//
// class _CallingPageState extends State<CallingPage> {
//   final userId =Random().nextInt(10000);
//   @override
//   Widget build(BuildContext context) {
//     return ZegoUIKitPrebuiltCall(
//       appID: AppInfo.appID, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
//       appSign: AppInfo.appSign, // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
//       userID: userId.toString(),
//       userName: 'user_name $userId',
//       callID: widget.callId,
//       // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
//       config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
//     );
//   }
// }
