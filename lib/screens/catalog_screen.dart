import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:officeflutterapp/screens/user_login_screen.dart';
import 'favourite_item_count.dart';
import 'favourites_screen.dart';
import 'http_client_for_test.dart';
import 'catalog_categories.dart'; // Exports the Category model
// Import the screen you navigate to

// Define a Category model (if not already defined in catalog_categories.dart)
class Category {
  final int id;
  final String name;
  final String image;

  Category({required this.id, required this.name, required this.image});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
    );
  }
}

/// Helper function: fixes a Base64 string by removing any data URI prefix and adding missing padding.
String fixBase64(String base64Str) {
  // Remove any data URI scheme if present.
  if (base64Str.contains(',')) {
    base64Str = base64Str.split(',').last;
  }
  base64Str = base64Str.trim();

  // If the string is just a placeholder or empty, we throw an error.
  if (base64Str.toLowerCase() == 'string' || base64Str.isEmpty) {
    throw Exception('Invalid Base64 image string');
  }

  // Pad the string so that its length is a multiple of 4.
  int remainder = base64Str.length % 4;
  if (remainder > 0) {
    base64Str = base64Str.padRight(base64Str.length + (4 - remainder), '=');
  }
  return base64Str;
}

class CategoryScreen extends StatefulWidget {
  final int userId;
  const CategoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Fetch categories from the API
  Future<List<Category>> fetchCategories() async {
    final client = createIOClient();
    final response =
    await client.get(Uri.parse("https://darnalbrojewelry.com/api/Categories"));
    if (response.statusCode == 200) {
      try {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final List<Category> categories =
        jsonList.map((json) => Category.fromJson(json)).toList();
        return categories;
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Invalid JSON response');
      }
    } else {
      print('HTTP ${response.statusCode} - ${response.reasonPhrase}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load categories (status ${response.statusCode})');
    }
  }

  /// Helper method to build the category image widget.
  /// If the image string starts with "http", it uses Image.network.
  /// Otherwise, it assumes the string is Base64 encoded and attempts to decode it.
  Widget _buildCategoryImage(String image) {
    if (image.startsWith("http")) {
      return Image.network(
        image,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.broken_image, size: 50),
      );
    } else if (image.isNotEmpty && image.toLowerCase() != 'string') {
      try {
        final fixed = fixBase64(image);
        final bytes = base64Decode(fixed);
        return Image.memory(
          bytes,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, size: 50),
        );
      } catch (e) {
        print("Error decoding base64 image: $e");
        return const Icon(Icons.broken_image, size: 50);
      }
    } else {
      return const Icon(Icons.broken_image, size: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Categories',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
        actions: [
          FavoriteBadge(
            userId: widget.userId.toString(),
            onPressed: () async {

              if (widget.userId == 0) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => UserLoginScreen()),
                      (route) => false,
                );
                return;
              }
              else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FavoriteScreen(userId: widget.userId.toString()),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field (if needed)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white,
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(4, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
          // Fetch and display categories using FutureBuilder
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: fetchCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories available.'));
                } else {
                  final List<Category> categories = snapshot.data!;
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final Category category = categories[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to ChokerScreen with the selected Category
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChokerScreen(category: category, userId: widget.userId.toString(),),
                            ),
                          );
                          print('Tapped on ${category.name}');
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: _buildCategoryImage(category.image),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
