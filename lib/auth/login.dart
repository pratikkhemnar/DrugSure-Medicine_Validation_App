import 'package:drugsuremva/E-commers%20Screen/providers/user_provider_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formGlobalKey = GlobalKey<FormState>();
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController passTextEditingController = TextEditingController();

  bool isLoading = false;
  String selectedRole = "user"; // "user" or "admin"

  Future<String> loginWithEmailAndPass(String email, String pass, BuildContext context) async {
    try {
      setState(() => isLoading = true);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      // Check user role from Firestore
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(selectedRole == "admin" ? "admins" : "users")
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        // If user doesn't exist in selected role collection
        await FirebaseAuth.instance.signOut();
        setState(() => isLoading = false);
        return "No account found with this role. Please check your login type.";
      }

      // Get user role from database
      String userRole = userDoc.get('role') ?? 'user';

      setState(() => isLoading = false);

      if (selectedRole == "admin" && userRole == "admin") {
        Provider.of<UserProvider>(context, listen: false).getUserData();
        return "Admin Login Successful";
      } else if (selectedRole == "user" && userRole == "user") {
        Provider.of<UserProvider>(context, listen: false).getUserData();
        return "User Login Successful";
      } else {
        await FirebaseAuth.instance.signOut();
        return "Invalid role selected for this account";
      }
    } on FirebaseAuthException catch (ecp) {
      setState(() => isLoading = false);
      return ecp.message.toString();
    } catch (e) {
      setState(() => isLoading = false);
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: formGlobalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.local_hospital, size: 100, color: Colors.teal),
                  const SizedBox(height: 10),

                  Text(
                    "DrugSure",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Welcome Back",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Login to continue using DrugSure",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Role Selection
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedRole = "user";
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: selectedRole == "user"
                                    ? LinearGradient(
                                  colors: [Colors.teal, Colors.green.shade400],
                                )
                                    : null,
                                color: selectedRole == "user" ? null : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "User Login",
                                  style: GoogleFonts.poppins(
                                    color: selectedRole == "user" ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedRole = "admin";
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: selectedRole == "admin"
                                    ? LinearGradient(
                                  colors: [Colors.teal, Colors.green.shade400],
                                )
                                    : null,
                                color: selectedRole == "admin" ? null : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "Admin Login",
                                  style: GoogleFonts.poppins(
                                    color: selectedRole == "admin" ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Email Field
                  TextFormField(
                    controller: emailTextEditingController,
                    validator: (value) =>
                    value!.isEmpty ? "Email cannot be empty." : null,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Password Field
                  TextFormField(
                    controller: passTextEditingController,
                    validator: (value) => value!.length < 6
                        ? "Password must be at least 6 characters long."
                        : null,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                        if (formGlobalKey.currentState!.validate()) {
                          loginWithEmailAndPass(
                              emailTextEditingController.text.trim(),
                              passTextEditingController.text.trim(),
                              context
                          ).then((status) {
                            if (status == "User Login Successful") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("You are logged in successfully."),
                                ),
                              );
                              Navigator.pushReplacementNamed(context, "/mainhomescreen");
                            } else if (status == "Admin Login Successful") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Admin logged in successfully."),
                                ),
                              );
                              Navigator.pushReplacementNamed(context, "/adminDashboard");
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(status)),
                              );
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.teal, Colors.green.shade400],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : Text(
                            "Login",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: GoogleFonts.poppins(),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/signup");
                        },
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Create Admin Account Link (for first admin setup)
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.pushNamed(context, "/createAdmin");
                  //   },
                  //   child: Text(
                  //     "Create Admin Account",
                  //     style: GoogleFonts.poppins(
                  //       fontWeight: FontWeight.w600,
                  //       color: Colors.orange.shade700,
                  //       fontSize: 12,
                  //     ),
                  //   ),
                  // ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}