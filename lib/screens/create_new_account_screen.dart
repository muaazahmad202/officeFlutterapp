import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admin_login_screen.dart'; // Update this to your actual next screen

class AdminSignupScreen extends StatefulWidget {
  const AdminSignupScreen({Key? key}) : super(key: key);

  @override
  _AdminSignupScreenState createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends State<AdminSignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController = TextEditingController();

  bool _isLoading = false;

  /// Helper method to show a MaterialBanner at the top.
  void _showTopMaterialBanner(String message, {bool isError = true}) {
    // Clear existing banners
    ScaffoldMessenger.of(context).clearMaterialBanners();

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        actions: [
          TextButton(
            onPressed: () {
              // This clears all material banners, ensuring the banner is removed.
              ScaffoldMessenger.of(context).clearMaterialBanners();
            },
            child: const Text(
              'DISMISS',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Simple email format validation using a RegExp.
  bool _isValidEmail(String email) {
    // A very basic pattern check: [text]@[text].[text]
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  Future<void> _signup() async {
    final String username = _emailController.text.trim();
    final String password = _passwordController.text;
    final String retypePassword = _retypePasswordController.text;

    // Check for empty fields.
    if (username.isEmpty || password.isEmpty || retypePassword.isEmpty) {
      _showTopMaterialBanner('Please fill all fields');
      return;
    }

    // Email format validation.
    if (!_isValidEmail(username)) {
      _showTopMaterialBanner('Invalid email format');
      return;
    }

    // Check if passwords match.
    if (password != retypePassword) {
      _showTopMaterialBanner('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final Uri url = Uri.parse('https://darnalbrojewelry.com/api/auth/adminsignup');
    final Map<String, dynamic> payload = {
      "username": username,
      "password": password,
      "isAdmin": true,
    };

    try {
      final http.Response response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showTopMaterialBanner('Signup successful', isError: false);
        // Navigate to the next screen after a short delay so the user can see the success banner.
        Future.delayed(const Duration(seconds: 1), () {
          // Clear any MaterialBanners before navigation.
          ScaffoldMessenger.of(context).clearMaterialBanners();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
          );
        });
      } else {
        _showTopMaterialBanner('Signup failed: ${response.statusCode}');
      }
    } catch (e) {
      _showTopMaterialBanner('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            // Optionally give it a background color if desired:
            // color: Colors.red,
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/back_icon.png', // Replace with your image path
              width: 24,
              height: 24,
              color: Colors.black, // Tint the image if needed
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text('Admin Signup'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          // Wrap in SingleChildScrollView to avoid overflow when the keyboard appears.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/logo.png',
                height: 120,
                width: 400,),
              const SizedBox(height: 20),
              const Text(
                'Sign Up',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Enter Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Retype Password", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _retypePasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Retype Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  //onPressed: _isLoading ? null : _signup,
                  onPressed: () {
                    // Clear any existing banners.
                    ScaffoldMessenger.of(context).clearMaterialBanners();
                    // Create and show a MaterialBanner.
                    final banner = MaterialBanner(
                      content: const Text(
                        "Can't create Admin Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: Colors.red,
                      actions: [
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).clearMaterialBanners();
                          },
                          child: const Text(
                            "DISMISS",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                    ScaffoldMessenger.of(context).showMaterialBanner(banner);
                    // Auto-dismiss after 2 seconds.
                    Future.delayed(const Duration(seconds: 2), () {
                      ScaffoldMessenger.of(context).clearMaterialBanners();
                    });
                  },

                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
