import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bcrypt/bcrypt.dart'; // For password verification
import 'add_product_and_category.dart';
import 'create_new_account_screen.dart'; // Make sure you have this screen defined

// Function to verify a plaintext password against a bcrypt hash.
bool verifyPassword(String plainPassword, String hashedPassword) {
  return BCrypt.checkpw(plainPassword, hashedPassword);
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  /// Helper method to clear any current [MaterialBanner] before showing a new one.
  void _showTopMaterialBanner(String message, {bool isError = true}) {
    // First clear any existing banners
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

  /// Simple email format validation using a RegExp
  bool _isValidEmail(String email) {
    // A very basic email pattern check:
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    // Validation checks
    if (email.isEmpty || password.isEmpty) {
      _showTopMaterialBanner('Please fill in both fields');
      return;
    }

    if (!_isValidEmail(email)) {
      _showTopMaterialBanner('Please enter a valid email (e.g. admin@gmail.com)');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Uri url =
      Uri.parse('https://darnalbrojewelry.com/api/auth/get-all-user');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> users = jsonResponse['model'];

        bool isAuthenticated = false;
        for (var user in users) {
          if (user['username'] == email &&
              user['isAdmin'] == true &&
              verifyPassword(password, user['passwordHash'])) {
            isAuthenticated = true;
            break;
          }
        }

        if (isAuthenticated) {
          // Show success message on top of screen
          _showTopMaterialBanner('Login successful', isError: false);
          // Navigate after a short delay so user can see success banner.
          Future.delayed(const Duration(seconds: 1), () {
            // Clear banners before navigation.
            ScaffoldMessenger.of(context).clearMaterialBanners();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const AddDetailsScreen(),
              ),
            );
          });
        } else {
          _showTopMaterialBanner('Invalid credentials or not an admin');
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
    // Use SingleChildScrollView with a ConstrainedBox & IntrinsicHeight
    // so the content can scroll when the keyboard appears.
    return Scaffold(
      appBar: AppBar(

        // 1. Give the backward button a background color (based on Figma).
        leading: Container(

          child: IconButton(
            // Replace Icon with an asset image
            icon: Image.asset(
              'assets/back_icon.png', // Your image path
              width: 24,
              height: 24,
              color: Colors.black, // If you need to tint the image white
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // 2. Bold the Admin text
        title: const Text(
          'Admin',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                kToolbarHeight -
                MediaQuery.of(context).padding.top,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Logo
                Image.asset(
                  'assets/logo.png', // Replace with the actual asset path
                  height: 120,
                  width: 400,
                ),
                const SizedBox(height: 20),
                // 2. "Login" text style (check font size per Figma)
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 35),
                // Label for Email
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                // 3 & 4. Check the input field height & border color
                const SizedBox(height: 5),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Enter Email",
                    hintStyle: const TextStyle(fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15, // Adjust according to Figma
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      // 4. Adjust color based on Figma
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // Label for Password
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    hintStyle: const TextStyle(fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15, // Adjust according to Figma
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      // 4. Adjust color based on Figma
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // 5. Bold the Forgot Password text
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Forgot Password",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold, // Now bold
                      fontSize: 14,
                    ),
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
                // 6. Bold the Create New Account text
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AdminSignupScreen()),
                    );
                  },
                  child: const Text(
                    "Create New Account",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold, // Now bold
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
