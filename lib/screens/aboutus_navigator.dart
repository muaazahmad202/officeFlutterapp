// about_us_navigator.dart

import 'package:flutter/material.dart';
import 'aboutus_screen.dart';
import 'appointment_screen.dart';

class AboutUsNavigator extends StatelessWidget {
  const AboutUsNavigator({Key? key, required int userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      // The initial route is '/aboutUs', which shows the AboutUsScreen.
      initialRoute: '/aboutUs',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/aboutUs':
            return MaterialPageRoute(
              builder: (context) => const AboutUsScreen(),
            );
          case '/appointment':
            return MaterialPageRoute(
              builder: (context) => const AppointmentScreen(),
            );
          default:
          // If somehow an unknown route is pushed, fall back to AboutUsScreen.
            return MaterialPageRoute(
              builder: (context) => const AboutUsScreen(),
            );
        }
      },
    );
  }
}
