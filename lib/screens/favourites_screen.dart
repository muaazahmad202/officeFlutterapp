import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'catalog_categories.dart';
import 'http_client_for_test.dart';
import 'product_model.dart';
import 'new_helper_function_for_image.dart'; // for fixBase64, getImageBytes, etc.

class FavoriteScreen extends StatefulWidget {
  final String userId;
  const FavoriteScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<Product>> _futureFavorites;
  /// We'll keep a local list of favorites so we can remove items without re-fetching.
  List<Product> _favorites = [];

  @override
  void initState() {
    super.initState();
    _futureFavorites = _fetchFavoriteProducts(widget.userId);
  }

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

  /// Fetch favorite products for the given userId.
  Future<List<Product>> _fetchFavoriteProducts(String userId) async {
    final client = createIOClient();
    // Adjust this endpoint as needed (with userId as query param)
    final String url = "https://darnalbrojewelry.com/api/Favorite?userId=$userId";
    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      final products = jsonData.map((e) => Product.fromJson(e)).toList();

      // Store the fetched favorites in a local list.
      _favorites = products;
      return products;
    } else {
      throw Exception("Failed to load favorites (status ${response.statusCode})");
    }
  }

  /// Refresh favorites by re-fetching from the server.
  Future<void> _refreshFavorites() async {
    setState(() {
      _futureFavorites = _fetchFavoriteProducts(widget.userId);
    });
  }

  /// Call this function to delete a favorite item from the server,
  /// then remove it locally and refresh the favorites list.
  Future<void> _deleteFavoriteItem(int productId) async {
    final client = createIOClient();
    const String url = "https://darnalbrojewelry.com/api/Favorite/del-fav-product";

    // The request body: productId and userId.
    final Map<String, dynamic> body = {
      "productId": productId,
      "userId": widget.userId,
    };

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showTopMaterialBanner("Item deleted from favorites.", isError: false);
        // Refresh the favorites list after deletion.
        await _refreshFavorites();
      } else {
        _showTopMaterialBanner("Failed to delete (status: ${response.statusCode})");
      }
    } catch (e) {
      _showTopMaterialBanner("An error occurred while deleting favorite.");
    }
  }

  /// Show a confirmation dialog before deleting.
  void _confirmDelete(Product product) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Column(
            children: const [
              Icon(Icons.delete, color: Colors.red, size: 40),
              SizedBox(height: 8),
              Text("Are you sure you want to delete this item?"),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              child: const Text("No", style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Yes", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(ctx).pop();
                _deleteFavoriteItem(product.id);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favorite",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
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
      ),
      // Wrap the FutureBuilder in a RefreshIndicator so user can pull-to-refresh.
      body: RefreshIndicator(
        onRefresh: _refreshFavorites,
        child: FutureBuilder<List<Product>>(
          future: _futureFavorites,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No favorite products found."));
            } else {
              // Build the UI using our local _favorites list.
              return ListView.builder(
                itemCount: _favorites.length,
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, index) {
                  final product = _favorites[index];
                  return _buildFavoriteItem(product);
                },
              );
            }
          },
        ),
      ),
    );
  }

  /// Builds each favorite item card with a long-press to delete.
  Widget _buildFavoriteItem(Product product) {
    return GestureDetector(
      onLongPress: () => _confirmDelete(product),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Product image.
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FutureBuilder<Uint8List>(
                  future: (product.productImage.trim().isNotEmpty)
                      ? getImageBytes(product.productImage)
                      : Future.value(Uint8List(0)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: 70,
                        height: 70,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError ||
                        snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return Image.asset(
                        'assets/logo.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return Image.memory(
                        snapshot.data!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Product details.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Weight: ${product.totalWeight} Grams",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Optional share icon.
              IconButton(
                icon: const Icon(Icons.share, color: Colors.amber),
                onPressed: () {
                  // Implement share logic if needed.
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
