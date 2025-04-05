import 'package:flutter/material.dart';
import 'package:officeflutterapp/screens/catalog_navigator.dart';
import 'package:officeflutterapp/screens/sell_screen.dart';
import 'package:officeflutterapp/screens/aboutus_navigator.dart';
import 'package:officeflutterapp/screens/cart_screen.dart';
import 'package:officeflutterapp/screens/home_user_screen.dart';
// Import other screens as needed.

class MainScreen extends StatefulWidget {
  final int initialIndex; // To set the initial tab.
  final int userId;       // User ID to pass to each page.

  const MainScreen({
    Key? key,
    this.initialIndex = 0,
    required this.userId,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    // Initialize the pages list, passing userId to each screen that needs it.
    _pages = [
      JewelryHomePage(userId: widget.userId), // Home screen
      CatalogNavigator(
        userId: widget.userId,
        onExitCatalog: () {
          setState(() {
            _selectedIndex = 0; // Switch to Home tab when exiting Catalog.
          });
        },
      ),
      CartScreen(userId: widget.userId),
      SellScreen(),
      AboutUsNavigator(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the page corresponding to the selected tab.
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0), // For a floating effect.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFFF1CC00),
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.black,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            // Ensure the number of items matches the _pages list.
            items: const [
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/home_icon.png'),
                  size: 24,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/catalog_icon.png'),
                  size: 24,
                ),
                label: 'Catalog',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/cart_icon.png'),
                  size: 24,
                ),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/sell_icon.png'),
                  size: 24,
                ),
                label: 'Sell',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/aboutus_icon.png'),
                  size: 24,
                ),
                label: 'About Us',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
