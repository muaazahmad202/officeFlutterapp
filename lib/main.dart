import 'package:flutter/material.dart';
import 'package:officeflutterapp/screens/admin_login_screen.dart';
import 'package:officeflutterapp/screens/cartModel.dart';
import 'package:officeflutterapp/screens/splash_screen.dart';

import 'package:provider/provider.dart'; // Corrected import

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: SplashScreen(), // Calling AdminLoginScreen from another file
      debugShowCheckedModeBanner: false,
    );
  }
}
