import 'package:flutter/material.dart';
import 'package:officeflutterapp/screens/select_admin_user_screen.dart';
import 'admin_login_screen.dart';
import 'main_screen_for_user_module.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration(seconds: 5),
          () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScreen(userId: 0,),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5, // 30% of screen width
                child: Image.asset(
                  "assets/logo.png",
                  fit: BoxFit.contain, // Keeps aspect ratio
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.35), // Dynamic spacing
              CircularProgressIndicator(color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
