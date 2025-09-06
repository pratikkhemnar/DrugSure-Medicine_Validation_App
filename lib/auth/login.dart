import 'package:drugsuremva/auth/createAccount.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formGlobalKey = GlobalKey<FormState>();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Icon(Icons.login,size: 120,color:Colors.green),
              SizedBox(height: 20,),

              Text("Welcome Back",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 6,),

              Text("Login in to Continue",
                style: TextStyle(
                  fontSize: 16,color: Colors.grey.shade600
                ),
              ),
              Form(
                  key: formGlobalKey,
                  child: Column(
                    children: [
                      SizedBox(height: 10,),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          validator: (value) => value!.isEmpty ? "Email connot be empty." : null,
                          controller: emailTextEditingController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text("Email")
                          ),
                        ),
                      ),

                      SizedBox(height: 10,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          validator: (value) => value!.length < 6 ? "Pass should have at least 6 digits" : null,
                          obscureText: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text("Password")
                          ),
                        ),
                      ),

                      SizedBox(height: 20,),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * .9,
                        height: 50,
                        child: ElevatedButton(onPressed: (){

                        },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white
                          ),
                          child: Text("Login",style: TextStyle(fontSize: 16),),
                        ),
                      ),

                      SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(onPressed: (){
                            Navigator.pushNamed(context, "/signup");
                          }, child: Text("Sign Up"))
                        ],
                      ),

                      SizedBox(height: 30,)

                    ],
                  )),



            ],
          ),
        ),
      ),

    );
  }
}
