import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:officeflutterapp/screens/user_login_screen.dart';
import 'main_screen_for_user_module.dart'; // Replace with your actual navigation target

class UserSignupScreen extends StatefulWidget {
  const UserSignupScreen({Key? key}) : super(key: key);

  @override
  _UserSignupScreenState createState() => _UserSignupScreenState();
}

class _UserSignupScreenState extends State<UserSignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController = TextEditingController();
  bool _isLoading = false;

  /// Helper function to validate email format.
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  /// Helper method to show a MaterialBanner at the top that auto-dismisses after 2 seconds.
  void _showTopMaterialBanner(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    final banner = MaterialBanner(
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
            ScaffoldMessenger.of(context).clearMaterialBanners();
          },
          child: const Text('DISMISS', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
    ScaffoldMessenger.of(context).showMaterialBanner(banner);
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).clearMaterialBanners();
    });
  }

  Future<void> _signUp() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String retypePassword = _retypePasswordController.text;

    if (email.isEmpty || password.isEmpty || retypePassword.isEmpty) {
      _showTopMaterialBanner("Please fill in all fields");
      return;
    }

    // Validate email format.
    if (!_isValidEmail(email)) {
      _showTopMaterialBanner("Please enter a valid email (e.g. user@example.com)");
      return;
    }

    if (password != retypePassword) {
      _showTopMaterialBanner("Passwords do not match");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Uri url = Uri.parse('https://darnalbrojewelry.com/api/auth/signup');
      final Map<String, dynamic> payload = {
        "username": email,
        "password": password,
        "isAdmin": false,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showTopMaterialBanner("Signup successful", isError: false);
        // Wait for banner to auto-dismiss then clear banners and navigate.
        Future.delayed(const Duration(seconds: 2), () {
          ScaffoldMessenger.of(context).clearMaterialBanners();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const UserLoginScreen()),
          );
        });
      } else {
        _showTopMaterialBanner("Signup failed: ${response.statusCode}");
      }
    } catch (e) {
      _showTopMaterialBanner("An error occurred: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, bool isPassword) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
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
    );
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
          child: IconButton(
            icon: Image.asset(
              'assets/back_icon.png', // Your image path
              width: 24,
              height: 24,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'User Signup',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          // Prevents overflow when keyboard appears.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/logo.png', // Replace with your actual asset path.
                height: 120,
              ),
              const SizedBox(height: 20),
              const Text(
                'Sign Up',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              _buildTextField(_emailController, 'Email', false),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              _buildTextField(_passwordController, 'Password', true),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Retype Password", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              _buildTextField(_retypePasswordController, 'Retype Password', true),
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
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
