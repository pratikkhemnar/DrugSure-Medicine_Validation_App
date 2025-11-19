// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'calling_page.dart';
//
// class VideoScreen extends StatefulWidget {
//   const VideoScreen({super.key});
//
//   @override
//   State<VideoScreen> createState() => _VideoScreenState();
// }
//
// class _VideoScreenState extends State<VideoScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController _textController = TextEditingController();
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.cyan,
//         title: const Text("Video Consult" , style: TextStyle(fontWeight: FontWeight.bold),),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(padding: EdgeInsets.symmetric(horizontal: 20),
//             child: TextField(
//               controller: _textController,
//               decoration: InputDecoration(
//                 labelText: 'Enter call id to join',
//                 border: OutlineInputBorder()
//               ),
//             ),),
//             SizedBox(height: 20,),
//             ElevatedButton(onPressed: (){
//               Navigator.of(context).push(MaterialPageRoute(builder: (context) =>CallingPage(callId : _textController.text)));
//             }, child: const Text("Join")
//             ),
//
//
//           ],
//         ),
//       ),
//     );
//   }
// }
