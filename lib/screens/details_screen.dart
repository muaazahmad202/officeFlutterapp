import 'package:flutter/material.dart';
import 'package:officeflutterapp/screens/product_model.dart';
import 'package:officeflutterapp/screens/user_login_screen.dart';
import 'package:provider/provider.dart';
import 'cartModel.dart';
import 'favourite_item_count.dart';
import 'favourites_screen.dart';
import 'new_helper_function_for_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String userId;

  const ProductDetailScreen({Key? key, required this.product, required this.userId})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // For demonstration, we’ll just have 1 image in _images.
  // If you have multiple images, store them here and implement PageView.
  late final List<String> _images;

  // Track current page if you use a PageView for multiple images.
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _images = [widget.product.productImage];
  }

  @override
  Widget build(BuildContext context) {
    // We'll build this screen using a Stack to layer:
    // 1) A red background at the top
    // 2) The curved white container at the bottom
    // 3) The product image in the center
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
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
        backgroundColor: Colors.red,
        actions: [
          FavoriteBadge(
            userId: widget.userId,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteScreen(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      // The main background is red
      backgroundColor: Colors.red,
      body: SafeArea(
        child: Stack(
          children: [
            // 1) The top bar (AppBar) with "Details" in the center
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildCustomAppBar(context),
            ),

            // 2) The main red background extends the entire screen
            Positioned.fill(
              child: Container(color: Colors.red),
            ),

            // 3) The curved white container at the bottom
            Positioned(
              top: MediaQuery.sizeOf(context).height * 0.35, // Adjust to your taste
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _buildProductDetails(context),
              ),
            ),

            // 4) The main product image positioned above the white container, centered horizontally.
            Positioned(
              top: 40, // slightly below the AppBar
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  child: buildProductImage(
                    widget.product.productImage,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // 5) Optional: left/right arrow buttons if you have multiple images.
            if (_images.length > 0) _buildArrowButtons(),

            // 6) Optional: Dot indicator if you have multiple images.
            if (_images.length > 0) _buildDotIndicator(),
          ],
        ),
      ),
    );
  }

  /// Builds the custom "Details" AppBar with a back arrow and a favorite icon.
  Widget _buildCustomAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const Text(
          'Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.favorite, color: Colors.white),
          onPressed: () {
            // Handle favorite if needed.
          },
        ),
      ],
    );
  }

  /// Builds the white container’s content: Name, Price, Weight, Description, etc.
  Widget _buildProductDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name & Price in one row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.product.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${widget.product.manualPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Weight: ${widget.product.totalWeight} Grams",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            "Description",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.productDescription,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          // "Call to Order" section
          Center(
            child: Column(
              children: [
                const Text(
                  "Call To Order",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "0413983999",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Add To Cart button with userId check.
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                // Check if userId is "0"; if so, redirect to the login screen.
                if (widget.userId == "0") {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => UserLoginScreen()),
                        (route) => false,
                  );
                  return;
                }

                // Otherwise, add the product to the cart.
                final cartModel = Provider.of<CartModel>(context, listen: false);
                await cartModel.addItem(widget.product, quantity: 1);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Added to Cart!")),
                );
              },
              child: const Text(
                "Add To Cart",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// (Optional) Builds left/right arrow buttons if you have multiple images.
  Widget _buildArrowButtons() {
    return Positioned(
      left: 0,
      right: 0,
      top: 120, // near the image
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              if (_currentPage > 0) {
                _currentPage--;
                _pageController.animateToPage(
                  _currentPage,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            icon: const Icon(Icons.arrow_left, color: Colors.white, size: 30),
          ),
          IconButton(
            onPressed: () {
              if (_currentPage < _images.length - 1) {
                _currentPage++;
                _pageController.animateToPage(
                  _currentPage,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            icon: const Icon(Icons.arrow_right, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  /// (Optional) Builds the dot indicator for multiple images.
  Widget _buildDotIndicator() {
    return Positioned(
      top: 270, // just below the image
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _images.length,
              (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index ? Colors.yellow : Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
