import 'package:flutter/material.dart';
import 'package:officeflutterapp/screens/user_login_screen.dart';

import 'add_product_and_category.dart';
import 'admin_login_screen.dart';
import 'home_user_screen.dart';
import 'main_screen_for_user_module.dart';

class AdminUserScreen extends StatelessWidget {
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
              color: Colors.black, // If you need to tint the image white
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text('Admin'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Image.asset('assets/logo.png', height: 100),
            SizedBox(height: 200),

              SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AdminLoginScreen()),
                  );
                },
                child: Text('Admin', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => UserLoginScreen()),
                  );
                },
                child: Text('User', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),

          ],
        ),
      ),
    );
  }

}
