import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_product.dart';            // Your existing ProductDetailsScreen
import 'add_category.dart';
import 'category_model_class.dart';
import 'http_client_for_test.dart';          // We'll implement CategoryDetailsScreen here

class AddDetailsScreen extends StatefulWidget {
  const AddDetailsScreen({Key? key}) : super(key: key);

  @override
  _AddDetailsScreenState createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends State<AddDetailsScreen> {
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Fetch categories from the API
  Future<void> _fetchCategories() async {
    try {
      // Replace with your actual endpoint
      final client = createIOClient();
      const String categoriesApi = "https://darnalbrojewelry.com/api/categories";

      final response = await client.get(Uri.parse(categoriesApi));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _categories = data.map((json) => CategoryModel.fromJson(json)).toList();
        });
      } else {
        print("Failed to load categories. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  // Delete a category
  Future<void> _deleteCategory(int categoryId) async {
    try {
      final client = createIOClient();
      // Convert the categoryId to JSON. This will produce something like "0" if categoryId = 0.
      final bodyData = jsonEncode(categoryId);


      final response = await client.post(
        Uri.parse("https://darnalbrojewelry.com/api/Categories/del-cat"),
        headers: {"Content-Type": "application/json"},
        body: bodyData, // e.g. "0"
      );


      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");


      if (response.statusCode == 200) {
        print("Category deleted successfully!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Category deleted!")),
        );
        // Refresh list
        _fetchCategories();
      } else {
        print("Failed to delete category. Status: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete. Status: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Error deleting category: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error deleting category.")),
      );
    }
  }


  // Navigate to CategoryDetailsScreen in edit mode
  void _editCategory(CategoryModel category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryDetailsScreen(category: category),
      ),
    ).then((_) {
      // Refresh after returning from edit
      _fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Details',
        style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        leading: Container(

          child: IconButton(
            // Replace Icon with an asset image
            icon: Image.asset(
              'assets/back_icon.png', // Your image path
              width: 24,
              height: 24,
              color: Colors.black, // If you need to tint the image white
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Add Product" button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProductDetailsScreen()),
                  );
                },
                child: const Text(
                  'Add Product',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // "Add Category" button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  // Passing null => "Add" mode
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CategoryDetailsScreen()),
                  ).then((_) {
                    // Refresh list after adding
                    _fetchCategories();
                  });
                },
                child: const Text(
                  'Add Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: _categories.isEmpty
                  ? const Center(child: Text('No categories found.'))
                  : ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryItem(_categories[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(CategoryModel category) {
    Widget imageWidget;

    // Check if the image string is a URL or a base64 string.
    if (category.image.startsWith('http') || category.image.startsWith('https')) {
      imageWidget = Image.network(
        category.image,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
          );
        },
      );
    } else {
      try {
        // Decode the base64 string.
        Uint8List imageBytes = base64Decode(category.image);
        imageWidget = Image.memory(
          imageBytes,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        );
      } catch (e) {
        // If decoding fails, show a fallback icon.
        imageWidget = Container(
          width: 80,
          height: 80,
          color: Colors.grey[200],
          child: const Icon(Icons.image, size: 40, color: Colors.grey),
        );
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        color: Colors.white,
        height: 100,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageWidget,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                category.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Image.asset(
                'assets/edit_icon.png', // Your image path
                width: 24,
                height: 24,
                color: Colors.red, // If you need to tint the image white
              ),
              onPressed: () => _editCategory(category),
            ),
            IconButton(
              icon: Image.asset(
                'assets/delete_icon.png', // Your image path
                width: 24,
                height: 24,
                color: Colors.red, // If you need to tint the image white
              ),
              onPressed: () => _deleteCategory(category.id),
            ),
          ],
        ),
      ),
    );
  }
}
