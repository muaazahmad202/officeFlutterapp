import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:officeflutterapp/screens/product_listing.dart';
import 'package:officeflutterapp/screens/product_model.dart';

import 'helper_function_for_image_size.dart';
import 'http_client_for_test.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product? product; // If provided, this is edit mode

  const ProductDetailsScreen({Key? key, this.product}) : super(key: key);
  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // Image picker
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _totalWeightController = TextEditingController();
  final TextEditingController _manualPriceController = TextEditingController();
  final TextEditingController _laborCostController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Category data
  String? selectedCategoryName; // For display in the UI
  int? selectedCategoryId; // For sending to the backend

  /// Helper method to show a MaterialBanner at the top that disappears after 2 seconds.
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

  @override
  void initState() {
    super.initState();
    // Preload fields if editing.
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _totalWeightController.text = widget.product!.totalWeight.toString();
      _manualPriceController.text = widget.product!.manualPrice.toString();
      _laborCostController.text = widget.product!.laborCost.toString();
      _descriptionController.text = widget.product!.productDescription;
      selectedCategoryId = widget.product!.categoryId;
      // Optionally, set selectedCategoryName if available in your model.
    }
  }

  // Fetch categories from the API
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    const String categoriesApi = "https://darnalbrojewelry.com/api/Categories";
    final client = createIOClient();
    final response = await client.get(Uri.parse(categoriesApi));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }

  // Open image picker
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Show bottom sheet to select category
  void _selectCategory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 200,
                child: Center(child: Text('Error: ${snapshot.error}')),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(child: Text('No categories available')),
              );
            } else {
              final categories = snapshot.data!;
              return Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Select Category",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: buildCategoryImage(category['image'] ?? ''),
                              ),
                            ),
                            title: Text(category['name'] ?? 'Unnamed'),
                            subtitle: Text('ID: ${category['id']}'),
                            onTap: () {
                              setState(() {
                                selectedCategoryName = category['name'];
                                selectedCategoryId = category['id'];
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget buildCategoryImage(String base64String) {
    try {
      final Uint8List imageBytes = base64Decode(base64String);
      return Image.memory(
        imageBytes,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return Container(
        width: 40,
        height: 40,
        color: Colors.grey[200],
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }
  }


  // Save product data to the API (handles both add and edit)
  Future<void> _saveProduct() async {
    // Determine the product image: if a new image is selected, compress and encode it;
    // otherwise, if editing, use the existing image.
    String base64Image = "";
    if (_image != null) {
      base64Image = await compressAndEncodeImage(_image!);
    } else if (widget.product != null) {
      base64Image = widget.product!.productImage;
    } else {
      base64Image = "";
    }

    bool isEdit = widget.product != null;
    final productId = isEdit ? widget.product!.id : 0;

    final newProduct = Product(
      id: productId,
      name: _nameController.text,
      totalWeight: double.tryParse(_totalWeightController.text) ?? 0,
      manualPrice: double.tryParse(_manualPriceController.text) ?? 0,
      laborCost: double.tryParse(_laborCostController.text) ?? 0,
      categoryId: selectedCategoryId ?? 0,
      productDescription: _descriptionController.text,
      productImage: base64Image,
    );

    final Map<String, dynamic> apiPayload = {
      "id": newProduct.id,
      "name": newProduct.name,
      "totalWeight": newProduct.totalWeight,
      "manualPrice": newProduct.manualPrice,
      "laborCost": newProduct.laborCost,
      "categoryId": newProduct.categoryId,
      "productDescription": newProduct.productDescription,
      "productImage": newProduct.productImage,
    };

    try {
      final client = createIOClient();
      String url;
      http.Response response;
      if (isEdit) {
        // Use PUT for updating an existing product using the update endpoint.
        url = "https://darnalbrojewelry.com/api/products/UpdateProduct";
        response = await client.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(apiPayload),
        );
      } else {
        // Use POST for adding a new product.
        url = "https://darnalbrojewelry.com/api/products/AddProduct";
        response = await client.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(apiPayload),
        );
        debugPrint("Response status: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
      }
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showTopMaterialBanner("Product saved successfully!", isError: false);
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductListingScreen()),
          );
        });
      } else {
        _showTopMaterialBanner("Failed to save product. Status: ${response.statusCode}");
      }
    } catch (e) {
      _showTopMaterialBanner("Error saving product. Please try again.");
    }
  }

  /// Example implementation of image compression using FlutterImageCompress.
  Future<String> compressAndEncodeImage(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 50,
      minWidth: 800,
      minHeight: 800,
    );
    if (result == null) {
      throw Exception("Image compression failed");
    }
    return base64Encode(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Card-like container
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField("Product Name", controller: _nameController),
                  _buildTextField("Total Weight", controller: _totalWeightController),
                  _buildTextField("Manual Price", controller: _manualPriceController),
                  _buildTextField("Labor Cost", controller: _laborCostController),
                  _buildCategorySelector(context),
                  _buildTextField("Product Description",
                      controller: _descriptionController, maxLines: 3),
                  const SizedBox(height: 20),
                  const Text(
                    "Upload Images",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: _image == null
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.image, size: 40, color: Colors.black54),
                            Text(
                              "Select File",
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "JPG, JPEG, PNG less than 1MB",
                              style: TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _image!,
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _saveProduct,
                child: const Text("Save", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label,
      {required TextEditingController controller, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: "Type here...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Select Category", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () => _selectCategory(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedCategoryName ?? "Select One",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
