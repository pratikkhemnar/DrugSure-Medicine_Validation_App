import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UnderWorking extends StatefulWidget {
  const UnderWorking({super.key});

  @override
  State<UnderWorking> createState() => _UnderWorkingState();
}

class _UnderWorkingState extends State<UnderWorking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Under Working ",style: TextStyle(fontSize: 24),),
      ),
    );
  }
}
