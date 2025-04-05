import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:officeflutterapp/screens/user_login_screen.dart';
import 'catalog_screen.dart';
import 'favourite_item_count.dart';
import 'favourites_screen.dart';
import 'details_screen.dart'; // Updated ProductDetailScreen
import 'http_client_for_test.dart';
import 'new_helper_function_for_image.dart'; // if needed
import 'product_model.dart';
import 'catalog_categories.dart'; // Exports the Category model


/// Helper function that fixes a Base64 string by:
/// 1. Removing any data URI scheme (e.g. "data:image/jpeg;base64,") if present.
/// 2. Trimming any whitespace.
/// 3. Checking if the string is a known placeholder (like "string") or empty.
/// 4. Adding '=' padding if its length is not a multiple of 4.
String fixBase64(String? base64Str) {
  if (base64Str == null ||
      base64Str.trim().isEmpty ||
      base64Str.toLowerCase() == 'string') {
    throw Exception('Invalid Base64 image string');
  }
  // Remove data URI prefix if present.
  if (base64Str.contains(',')) {
    base64Str = base64Str.split(',').last;
  }
  base64Str = base64Str.trim();
  // Pad the string if necessary (Base64 length should be a multiple of 4)
  int remainder = base64Str.length % 4;
  if (remainder > 0) {
    base64Str = base64Str.padRight(base64Str.length + (4 - remainder), '=');
  }
  return base64Str;
}

/// Helper function to decode a Base64 image string to bytes.
Future<Uint8List> getImageBytes(String? base64Str) async {
  try {
    final fixed = fixBase64(base64Str);
    return base64Decode(fixed);
  } catch (e) {
    throw Exception('Error decoding base64 image: $e');
  }
}

class ChokerScreen extends StatefulWidget {
  final Category category; // Full Category object
  final String userId; // Current user id passed from login

  const ChokerScreen({
    Key? key,
    required this.category,
    required this.userId,
  }) : super(key: key);

  @override
  State<ChokerScreen> createState() => _ChokerScreenState();
}

class _ChokerScreenState extends State<ChokerScreen> {
  /// A set to track product IDs that are marked as favorites.
  Set<int> _favoriteProductIds = {};

  /// Helper method to show a MaterialBanner at the top that auto-dismisses after 2 seconds.
  void _showTopMaterialBanner(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    final banner = MaterialBanner(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      actions: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).clearMaterialBanners();
          },
          child: const Text('DISMISS', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
    ScaffoldMessenger.of(context).showMaterialBanner(banner);
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).clearMaterialBanners();
    });
  }

  /// Fetch all products from the API, then filter by categoryId.
  Future<List<Product>> fetchProducts() async {
    final client = createIOClient();
    const String apiUrl = 'https://darnalbrojewelry.com/api/products';
    final response = await client.get(Uri.parse(apiUrl));

    debugPrint("Response length: ${response.body.length}");
    // Use response.bodyBytes to ensure proper UTF-8 decoding.
    final decodedBody = utf8.decode(response.bodyBytes);
    debugPrint("Response status: ${response.statusCode}");
    debugPrint("Response body: $decodedBody");

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(decodedBody);
      final List<Product> allProducts =
      jsonData.map((e) => Product.fromJson(e)).toList();

      // Filter products with a matching categoryId.
      final List<Product> filteredProducts = allProducts
          .where((product) => product.categoryId == widget.category.id)
          .toList();

      debugPrint("Filtered products count: ${filteredProducts.length}");
      if (filteredProducts.isNotEmpty) {
        debugPrint("First product image string: ${filteredProducts.first.productImage}");
      }
      return filteredProducts;
    } else {
      throw Exception('Failed to load products');
    }
  }

  /// Build the UI for each product item with favorite toggle.
  Widget _buildProductItem(Product product) {
    bool isFav = _favoriteProductIds.contains(product.id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product, userId: widget.userId),
              ),
            ).then((_) {
              // Clear any banners before navigation (if needed)
              ScaffoldMessenger.of(context).clearMaterialBanners();
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FutureBuilder<Uint8List>(
                  future: (product.productImage.trim().isNotEmpty)
                      ? getImageBytes(product.productImage)
                      : Future.value(Uint8List(0)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError ||
                        snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return Image.asset(
                        'assets/logo.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return Image.memory(
                        snapshot.data!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Weight: ${product.totalWeight} g',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "\$${product.manualPrice.toStringAsFixed(2)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey,
                ),
                onPressed: () async {
                  // If userId is "0", route to the login screen using pushReplacement.
                  if (widget.userId == "0") {
                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => UserLoginScreen()),
                          (route) => false,
                    );
                    return;
                  }

                  final body = {
                    "productId": product.id,
                    "userId": widget.userId,
                  };

                  try {
                    final client = createIOClient();
                    if (!isFav) {
                      // Add product to favorites.
                      const String addUrl =
                          "https://darnalbrojewelry.com/api/Favorite/add-product";
                      final response = await client.post(
                        Uri.parse(addUrl),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode(body),
                      );
                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        setState(() {
                          _favoriteProductIds.add(product.id);
                        });
                        _showTopMaterialBanner("Product added to favorites!", isError: false);
                      } else {
                        _showTopMaterialBanner("Failed to add favorite (status: ${response.statusCode})");
                      }
                    } else {
                      // Remove product from favorites.
                      const String delUrl =
                          "https://darnalbrojewelry.com/api/Favorite/del-fav-product";
                      final response = await client.post(
                        Uri.parse(delUrl),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode(body),
                      );
                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        setState(() {
                          _favoriteProductIds.remove(product.id);
                        });
                        _showTopMaterialBanner("Product removed from favorites!", isError: false);
                      } else {
                        _showTopMaterialBanner("Failed to remove favorite (status: ${response.statusCode})");
                      }
                    }
                  } catch (e) {
                    _showTopMaterialBanner("An error occurred while updating favorites: $e");
                  }
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String appBarTitle = widget.category.name;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/back_icon.png', // Your image path
            width: 24,
            height: 24,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(appBarTitle, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          FavoriteBadge(
            userId: widget.userId,
            onPressed: () async {

              if (widget.userId == "0") {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => UserLoginScreen()),
                      (route) => false,
                );
                return;
              }

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
      body: FutureBuilder<List<Product>>(
        future: fetchProducts(),
        builder: (context, snapshotProducts) {
          if (snapshotProducts.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshotProducts.hasError) {
            return Center(child: Text('Error: ${snapshotProducts.error}'));
          } else if (!snapshotProducts.hasData || snapshotProducts.data!.isEmpty) {
            return const Center(child: Text('No products available.'));
          } else {
            final products = snapshotProducts.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductItem(product);
              },
            );
          }
        },
      ),
    );
  }
}
