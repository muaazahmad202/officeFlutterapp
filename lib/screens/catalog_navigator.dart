import 'package:flutter/material.dart';
import 'package:officeflutterapp/screens/catalog_screen.dart';

// A custom widget (PopScope) might be your own widget or from a package.
// For demonstration, let's assume it's a custom widget that triggers onPopInvoked.
class PopScope extends StatelessWidget {
  final Widget child;
  final ValueChanged<bool> onPopInvoked;

  const PopScope({
    Key? key,
    required this.child,
    required this.onPopInvoked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        onPopInvoked(true);
        return false;
      },
      child: child,
    );
  }
}

class CatalogNavigator extends StatelessWidget {
  final VoidCallback onExitCatalog;
  final int userId;

  const CatalogNavigator({
    Key? key,
    required this.onExitCatalog,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool didPop) {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        } else {
          // When there are no routes to pop in the nested navigator,
          // invoke the callback (e.g., switch the MainScreen's tab).
          onExitCatalog();
        }
      },
      child: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          // Pass userId to CategoryScreen.
          return MaterialPageRoute(
            builder: (context) => CategoryScreen(userId: userId),
          );
        },
      ),
    );
  }
}
