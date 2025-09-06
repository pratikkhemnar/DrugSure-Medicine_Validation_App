import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EHomescreen extends StatefulWidget {
  const EHomescreen({super.key});

  @override
  State<EHomescreen> createState() => _EHomescreenState();
}

class _EHomescreenState extends State<EHomescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping"),
      ),
    );
  }
}
