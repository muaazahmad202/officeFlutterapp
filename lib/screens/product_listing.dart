import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'add_product.dart';
import 'category_model_class.dart';
import 'details_screen.dart';
import 'product_model.dart';


class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({Key? key}) : super(key: key);

  @override
  _ProductListingScreenState createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  late Future<Map<CategoryModel, List<Product>>> _futureCategoriesAndProducts;

  @override
  void initState() {
    super.initState();
    _futureCategoriesAndProducts = _fetchCategoriesAndProducts();
  }

  /// Fetch all categories and products, then group products by category.
  Future<Map<CategoryModel, List<Product>>> _fetchCategoriesAndProducts() async {
    const String categoriesApi = "https://darnalbrojewelry.com/api/Categories";
    const String productsApi = "https://darnalbrojewelry.com/api/products";

    final catResponse = await http.get(Uri.parse(categoriesApi));
    final prodResponse = await http.get(Uri.parse(productsApi));

    if (catResponse.statusCode == 200 && prodResponse.statusCode == 200) {
      // Parse categories
      final List<dynamic> catData = jsonDecode(catResponse.body);
      final List<CategoryModel> categories =
      catData.map((json) => CategoryModel.fromJson(json)).toList();

      // Parse products
      final List<dynamic> prodData = jsonDecode(prodResponse.body);
      final List<Product> products =
      prodData.map((json) => Product.fromJson(json)).toList();

      // Build a map of categoryId -> CategoryModel
      final Map<int, CategoryModel> categoryMap = {
        for (var c in categories) c.id: c,
      };

      // Prepare a map of CategoryModel -> List<Product>
      final Map<CategoryModel, List<Product>> categorizedProducts = {
        for (var c in categories) c: [],
      };

      // Assign each product to the correct category
      for (final product in products) {
        if (categoryMap.containsKey(product.categoryId)) {
          final categoryObj = categoryMap[product.categoryId]!;
          categorizedProducts[categoryObj]!.add(product);
        }
      }

      return categorizedProducts;
    } else {
      throw Exception("Failed to fetch categories or products.");
    }
  }

  /// Delete a product by its ID.
  Future<void> _deleteProduct(int productId) async {

    try {
      final bodyData = jsonEncode(productId);
      final response = await http.post(
        Uri.parse("https://darnalbrojewelry.com/api/products/del-product"),
        headers: {"Content-Type": "application/json"},
        body: bodyData,
      );
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted!')),
        );
        // Refresh the list after deletion.
        setState(() {
          _futureCategoriesAndProducts = _fetchCategoriesAndProducts();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting product.')),
      );
    }
  }

  /// Navigate to edit a product.
  void _editProduct(Product product) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    )
        .then((_) {
      // Refresh after editing.
      setState(() {
        _futureCategoriesAndProducts = _fetchCategoriesAndProducts();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Listing',style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        leading: Container(
          child: IconButton(
            // Replace Icon with an asset image
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
      body: FutureBuilder<Map<CategoryModel, List<Product>>>(
        future: _futureCategoriesAndProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading indicator
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Display error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // No categories or products found
            return const Center(child: Text('No products found'));
          } else {
            final categorizedProducts = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: categorizedProducts.entries.map((entry) {
                  final category = entry.key;
                  final products = entry.value;

                  // If you only want to show categories that actually have products,
                  // you can skip those with an empty list:
                  if (products.isEmpty) {
                    return const SizedBox(); // or return Container() to hide empty categories
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category name
                      Text(
                        category.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // Product cards for this category
                      Column(
                        children: products.map((product) => _buildProductCard(product)).toList(),
                      ),

                      const SizedBox(height: 20),
                    ],
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }

  /// Helper method to build the product image widget (URL or base64).
  Widget _buildProductImage(Product product) {
    if (product.productImage.startsWith('http')) {
      // If it's a URL
      return Image.network(
        product.productImage,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: const Icon(Icons.image, color: Colors.grey),
          );
        },
      );
    } else {
      // Otherwise, assume it's a base64-encoded string
      try {
        final bytes = base64Decode(product.productImage);
        return Image.memory(
          bytes,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: const Icon(Icons.image, color: Colors.grey),
            );
          },
        );
      } catch (e) {
        // If decoding fails, show a placeholder
        return Container(
          width: 80,
          height: 80,
          color: Colors.grey[200],
          child: const Icon(Icons.image, color: Colors.grey),
        );
      }
    }
  }

  /// Build a card for a single product.
  Widget _buildProductCard(Product product) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(15),
        height: 100,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildProductImage(product),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/edit_icon.png', // Your image path
                    width: 24,
                    height: 24,
                    color: Colors.red, // If you need to tint the image white
                  ),
                  onPressed: () => _editProduct(product),
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/delete_icon.png', // Your image path
                    width: 24,
                    height: 24,
                    color: Colors.red, // If you need to tint the image white
                  ),
                  onPressed: () => _deleteProduct(product.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
