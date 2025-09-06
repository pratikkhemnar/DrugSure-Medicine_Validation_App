import 'package:drugsuremva/E-commers%20Screen/E_HomeScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child: Center(
          child: Column(
            children: [
              Text("Hello"),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>EHomescreen()));
              }, child: Text("Ecommerce"))
            ],
        
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag),label: 'E-Commerce',),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag),label: 'E-Commerce')
      ]),
    );
  }
}
