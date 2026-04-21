import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateAdminAccount extends StatefulWidget {
  const CreateAdminAccount({super.key});

  @override
  State<CreateAdminAccount> createState() => _CreateAdminAccountState();
}

class _CreateAdminAccountState extends State<CreateAdminAccount> {
  final formGlobalKey = GlobalKey<FormState>();
  final TextEditingController nameTextEditingController = TextEditingController();
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController passTextEditingController = TextEditingController();
  final TextEditingController phoneTextEditingController = TextEditingController();
  final TextEditingController adminCodeController = TextEditingController();

  bool isLoading = false;
  final String secretAdminCode = "ADMIN123"; // Change this to your secret code

  Future<String> createAdminAccount(String name, String email, String pass, String phone, String adminCode) async {
    if (adminCode != secretAdminCode) {
      return "Invalid admin creation code";
    }

    try {
      setState(() => isLoading = true);
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      await saveAdminData(name, email, phone);
      setState(() => isLoading = false);
      return "Admin Account Created Successfully";
    } on FirebaseAuthException catch (ecp) {
      setState(() => isLoading = false);
      return ecp.message.toString();
    }
  }

  Future<void> saveAdminData(String name, String email, String phone) async {
    try {
      Map<String, dynamic> adminData = {
        "uid": FirebaseAuth.instance.currentUser!.uid,
        "name": name,
        "email": email,
        "phone": phone,
        "profileImage": "",
        "role": "admin",
        "createdAt": FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance
          .collection("admins")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(adminData);
    } catch (ecp) {
      print("Failed to save admin data: $ecp");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Create Admin Account", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: formGlobalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.admin_panel_settings, size: 80, color: Colors.teal),
                  const SizedBox(height: 10),
                  Text(
                    "Create Admin Account",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Name
                  TextFormField(
                    controller: nameTextEditingController,
                    validator: (value) =>
                    value!.isEmpty ? "Name cannot be empty." : null,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person),
                      labelText: "Full Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Email
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

                  // Phone
                  TextFormField(
                    controller: phoneTextEditingController,
                    validator: (value) =>
                    value!.isEmpty ? "Phone number cannot be empty." : null,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone),
                      labelText: "Phone Number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password
                  TextFormField(
                    controller: passTextEditingController,
                    validator: (value) => value!.length < 6
                        ? "Password should be at least 6 characters"
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
                  const SizedBox(height: 15),

                  // Admin Creation Code
                  TextFormField(
                    controller: adminCodeController,
                    validator: (value) =>
                    value!.isEmpty ? "Admin creation code required" : null,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.security),
                      labelText: "Admin Creation Code",
                      hintText: "Enter secret admin code",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Create Admin Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                        if (formGlobalKey.currentState!.validate()) {
                          createAdminAccount(
                            nameTextEditingController.text.trim(),
                            emailTextEditingController.text.trim(),
                            passTextEditingController.text.trim(),
                            phoneTextEditingController.text.trim(),
                            adminCodeController.text.trim(),
                          ).then((status) {
                            if (status == "Admin Account Created Successfully") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(status)),
                              );
                              Navigator.pushReplacementNamed(context, "/login");
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
                            "Create Admin Account",
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}