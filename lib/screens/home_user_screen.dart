import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:officeflutterapp/screens/user_login_screen.dart';
import 'admin_login_screen.dart';
import 'catalog_screen.dart';
import 'favourite_item_count.dart';
import 'favourites_screen.dart';
import 'main_screen_for_user_module.dart'; // For MainScreen
import 'catalog_categories.dart'; // For Category model
import 'product_model.dart'; // For Product model
// Import your Admin module

class JewelryHomePage extends StatefulWidget {
  final int userId;

  const JewelryHomePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<JewelryHomePage> createState() => _JewelryHomePageState();
}

class _JewelryHomePageState extends State<JewelryHomePage> {
  /// Fetch categories from /api/Categories.
  Future<List<Category>> _fetchCategories() async {
    final url = Uri.parse("https://darnalbrojewelry.com/api/Categories");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load categories. Status: ${response.statusCode}");
    }
  }

  /// Fetch 4-5 random products from /api/products.
  Future<List<Product>> _fetchRandomProducts() async {
    final url = Uri.parse("https://darnalbrojewelry.com/api/products");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<Product> allProducts =
      data.map((json) => Product.fromJson(json)).toList();
      allProducts.shuffle();
      int count = allProducts.length < 5 ? allProducts.length : 5;
      return allProducts.take(count).toList();
    } else {
      throw Exception("Failed to load products. Status: ${response.statusCode}");
    }
  }

  /// Fetch products that belong to the "Choker" category.
  Future<List<Product>> _fetchChokerProducts() async {
    // First, fetch all categories.
    final categories = await _fetchCategories();
    // Filter for categories with name "choker" (case-insensitive).
    final chokerCategories =
    categories.where((cat) => cat.name.toLowerCase() == "choker").toList();
    if (chokerCategories.isEmpty) {
      // If no choker category found, return an empty list.
      return [];
    }
    final chokerCategory = chokerCategories.first;

    // Fetch all products.
    final url = Uri.parse("https://darnalbrojewelry.com/api/products");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<Product> allProducts =
      data.map((json) => Product.fromJson(json)).toList();
      // Filter products that belong to the Choker category.
      return allProducts.where((p) => p.categoryId == chokerCategory.id).toList();
    } else {
      throw Exception("Failed to load products. Status: ${response.statusCode}");
    }
  }

  /// Fetch gold rate information from /api/Forex.
  Future<Map<String, double>> _fetchGoldRate() async {
    final url = Uri.parse("https://darnalbrojewelry.com/api/Forex");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final num price = jsonData["model"]["data"]["metal_prices"]["XAU"]["price"];
      double gramPrice = price.toDouble();
      double tolaPrice = gramPrice * 11.6;
      return {"gram": gramPrice, "tola": tolaPrice};
    } else {
      throw Exception("Failed to load forex. Status: ${response.statusCode}");
    }
  }

  /// Helper to build a product image widget.
  Widget _buildProductImage(Product product) {
    // If product.productImage starts with "http", assume it's a URL.
    if (product.productImage.toLowerCase().startsWith("http")) {
      return Image.network(
        product.productImage,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.broken_image, color: Colors.grey),
      );
    } else {
      try {
        final bytes = base64Decode(product.productImage);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return const Icon(Icons.image, color: Colors.grey);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom AppBar with flexibleSpace for large logo and icons.
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: AppBar(
          backgroundColor: Colors.red,
          elevation: 0,
          // Disable automatic leading and actions to use flexibleSpace.
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Stack(
              children: [
                // Centered large logo filling the AppBar vertically.
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/logoHome.png', // Replace with your actual asset.
                    height: 120,          // Adjust as needed.
                  ),
                ),
                // Left icon (bell/notifications) pinned at top-left.
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.red),
                      onPressed: () {
                        // TODO: Implement notifications action.
                      },
                    ),
                  ),
                ),
                // Admin button positioned near the top-right (to the left of Favorite).
                Positioned(
                  top: 8,
                  right: 70, // Adjust the offset as needed.
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (context) => AdminLoginScreen()),
                        );
                      },
                      child: Icon(
                        Icons.admin_panel_settings_sharp,
                        color: Colors.red,
                        size: 24, // Adjust size as needed.
                      ),
                    ),
                  ),
                ),

                // Right icon (heart/favorite) pinned at top-right.
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: FavoriteBadge(
                      userId: widget.userId.toString(),
                      onPressed: () {
                        // Clear banners if needed.
                        ScaffoldMessenger.of(context).clearMaterialBanners();

                        if (widget.userId == "0") {
                          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => UserLoginScreen()),
                                (route) => false,
                          );
                          return;
                        }
                        // Navigate to FavoriteScreen.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavoriteScreen(userId: widget.userId.toString()),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            goldRateCard(),
            const SizedBox(height: 10),
            categorySection(context),
            const SizedBox(height: 10),
            popularNewSection(context),
            const SizedBox(height: 10),
            chokerSection(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// Gold Rate Card: Displays the live gold rate fetched from /api/Forex.
  Widget goldRateCard() {
    return FutureBuilder<Map<String, double>>(
      future: _fetchGoldRate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
            child: Container(
              height: 120,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
            child: Container(
              height: 120,
              alignment: Alignment.center,
              child: Text("Error: ${snapshot.error}"),
            ),
          );
        } else if (snapshot.hasData) {
          final goldRates = snapshot.data!;
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Live Gold Rate',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF1CC00)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Color(0xFFF1CC00)),
                          onPressed: () {
                            setState(() {
                              // Trigger a new fetch by rebuilding the widget.
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text('Tola (11.6g) : ', style: TextStyle(fontSize: 18)),
                        Text(
                          '\$${goldRates["tola"]!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Gram : ', style: TextStyle(fontSize: 18)),
                        Text(
                          '\$${goldRates["gram"]!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  /// Category Section using FutureBuilder to fetch categories from API.
  Widget categorySection(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: _fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            height: 100,
            child: Center(child: Text("Error: ${snapshot.error}")),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: Text("No categories found.")),
          );
        } else {
          final categories = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Categories" title & "See All" button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Categories',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MainScreen(initialIndex: 1, userId: widget.userId),
                          ),
                        );
                      },
                      child: const Text('See All',
                          style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              // Horizontal list of categories.
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return Container(
                      width: 90,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.amber[800],
                            child: _buildCategoryCircleImage(cat),
                          ),
                          const SizedBox(height: 4),
                          Text(cat.name),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  /// Helper to build an image for the category CircleAvatar.
  Widget _buildCategoryCircleImage(Category cat) {
    if (cat.image.toLowerCase().startsWith("http")) {
      return ClipOval(
        child: Image.network(
          cat.image,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 30, color: Colors.white);
          },
        ),
      );
    } else if (cat.image.isNotEmpty && cat.image.toLowerCase() != 'string') {
      try {
        final bytes = base64Decode(cat.image);
        return ClipOval(
          child: Image.memory(
            bytes,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {
        return const Icon(Icons.image, size: 30, color: Colors.white);
      }
    } else {
      return const Icon(Icons.image, size: 30, color: Colors.white);
    }
  }

  /// Popular New Section: Fetches 4–5 random products.
  Widget popularNewSection(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _fetchRandomProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 250,
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Container(
            height: 250,
            child: Center(child: Text("Error: ${snapshot.error}")),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            height: 250,
            child: const Center(child: Text("No products available.")),
          );
        } else {
          final items = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading row with title and See All button.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular and New',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MainScreen(initialIndex: 1, userId: widget.userId),
                          ),
                        );
                      },
                      child: const Text(
                        'See All',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              // Horizontal list of products.
              Container(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final product = items[index];
                    return Container(
                      width: 180,
                      margin: const EdgeInsets.all(10),
                      child: Card(
                        color: Colors.white,
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildProductImage(product),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text("Weight: ${product.totalWeight} g"),
                                  const SizedBox(height: 5),
                                  Text(
                                    "\$${product.manualPrice.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  /// Choker Section: Fetch products that belong to the "Choker" category.
  Widget chokerSection(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _fetchChokerProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 140,
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          // Instead of showing an error, return an empty widget.
          return const SizedBox.shrink();
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // If no choker products found, do not display the section.
          return const SizedBox.shrink();
        } else {
          final products = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading row with title and See All button.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Choker',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MainScreen(initialIndex: 1, userId: widget.userId),
                          ),
                        );
                      },
                      child: const Text(
                        'See All',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Container(
                      width: 320,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _buildProductImage(product),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 5),
                                    Text("Weight: ${product.totalWeight} g"),
                                    const SizedBox(height: 5),
                                    Text(
                                      "\$${product.manualPrice.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
