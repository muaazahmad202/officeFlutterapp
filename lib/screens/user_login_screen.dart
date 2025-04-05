import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bcrypt/bcrypt.dart'; // Add bcrypt package for password verification.

import 'user_signup_screen.dart';
import 'main_screen_for_user_module.dart'; // Update with your actual home screen.

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({Key? key}) : super(key: key);

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  int? _userId; // Store the logged-in user's id

  // Function to verify the plaintext password against the bcrypt hash.
  bool verifyPassword(String plainPassword, String hashedPassword) {
    return BCrypt.checkpw(plainPassword, hashedPassword);
  }

  /// Helper function to validate email format.
  bool _isValidEmail(String email) {
    // This regular expression is a basic check for email validity.
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
          child: const Text(
            'DISMISS',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
    ScaffoldMessenger.of(context).showMaterialBanner(banner);
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).clearMaterialBanners();
    });
  }

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    // Check if fields are empty.
    if (email.isEmpty || password.isEmpty) {
      _showTopMaterialBanner('Please fill in both fields');
      return;
    }

    // Email format validation.
    if (!_isValidEmail(email)) {
      _showTopMaterialBanner('Please enter a valid email (e.g. admin@gmail.com)');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the API to get all users.
      final Uri url = Uri.parse('https://darnalbrojewelry.com/api/auth/get-all-user');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // The API response contains keys: status, message, and model.
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> users = jsonResponse['model'];

        bool isAuthenticated = false;
        int? userId;

        // Look for a user with matching email, not an admin, and correct password.
        for (var user in users) {
          if (user['username'] == email &&
              user['isAdmin'] == false &&
              verifyPassword(password, user['passwordHash'])) {
            isAuthenticated = true;
            userId = user['id'];
            break;
          }
        }

        if (isAuthenticated && userId != null) {
          setState(() {
            _userId = userId;
          });
          _showTopMaterialBanner('Login successful', isError: false);
          int newUserId = userId;
          // Delay navigation until the banner is auto-dismissed, then clear banners before navigating.
          Future.delayed(const Duration(seconds: 2), () {
            ScaffoldMessenger.of(context).clearMaterialBanners();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainScreen(userId: newUserId)),
            );
          });
        } else {
          _showTopMaterialBanner('Invalid credentials');
        }
      } else {
        _showTopMaterialBanner('Error: ${response.statusCode}');
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          child: IconButton(
            // Replace Icon with an asset image
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
          'User Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          // Prevents overflow when the keyboard opens.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/logo.png', // Replace with your logo asset path.
                height: 120,
                width: 400,
              ),
              const SizedBox(height: 20),
              const Text(
                "Login",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Email",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Enter Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Password",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Forgot Password",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const UserSignupScreen()),
                  );
                },
                child: const Text(
                  "Create New Account",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
