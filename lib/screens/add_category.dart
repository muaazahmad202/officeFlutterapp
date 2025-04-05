import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'category_model_class.dart';
import 'helper_function_for_image_size.dart';
import 'http_client_for_test.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final CategoryModel? category; // If null => Add mode; if not null => Edit mode

  const CategoryDetailsScreen({Key? key, this.category}) : super(key: key);

  @override
  _CategoryDetailsScreenState createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate fields if in Edit mode.
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      // Optionally, if you want to show the current image, you might add code here.
    }
  }

  /// Helper method to show a MaterialBanner at the top that auto-dismisses after 2 seconds.
  void _showTopMaterialBanner(String message, {bool isError = true}) {
    // Clear existing banners first.
    ScaffoldMessenger.of(context).clearMaterialBanners();
    final banner = MaterialBanner(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      actions: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).clearMaterialBanners();
          },
          child: const Text(
            'DISMISS',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
    ScaffoldMessenger.of(context).showMaterialBanner(banner);
    // Auto-dismiss the banner after 2 seconds.
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).clearMaterialBanners();
    });
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black),
                title: const Text("Pick from Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile =
                  await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.black),
                title: const Text("Take a Photo"),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile =
                  await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveCategory() async {
    // Validate category name.
    if (_nameController.text.isEmpty) {
      _showTopMaterialBanner("Please enter a category name");
      return;
    }

    // For new category (Add mode), require an image.
    if (widget.category == null && _image == null) {
      _showTopMaterialBanner("Please select an image");
      return;
    }

    // Determine the image string:
    // If a new image is selected, compress and encode it;
    // Otherwise, in Edit mode, use the existing image.
    String imageString;
    if (_image != null) {
      imageString = await compressAndEncodeImage(_image!);
    } else if (widget.category != null) {
      imageString = widget.category!.image;
    } else {
      imageString = "";
    }

    // Determine if we're in edit mode.
    // If widget.category exists, then we update the category fields;
    // otherwise, we add a new category.
    bool isEdit = widget.category != null;

    // Build the request payload.
    // In edit mode, use the existing category ID.
    final Map<String, dynamic> requestBody = {
      "id": isEdit ? widget.category!.id : 0,
      "name": _nameController.text,
      "image": imageString,
    };

    try {
      final client = createIOClient();
      http.Response response;

      if (isEdit) {
        // Update category using the new update endpoint.
        response = await client.post(
          Uri.parse("https://darnalbrojewelry.com/api/Categories/UpdateCategory"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody),

        );
        debugPrint("Response status: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
      }

      else {
        // Create new category using POST.
        response = await client.post(
          Uri.parse("https://darnalbrojewelry.com/api/Categories/AddCategory"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody),
        );
      }


      if (response.statusCode == 200 || response.statusCode == 201) {
        _showTopMaterialBanner("Category saved successfully!", isError: false);
        // Clear banners and navigate back after a short delay.
        Future.delayed(const Duration(seconds: 1), () {
          ScaffoldMessenger.of(context).clearMaterialBanners();
          Navigator.pop(context);
        });
      } else {
        _showTopMaterialBanner("Failed to save category. Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error saving category: $e");
      _showTopMaterialBanner("An error occurred. Please try again.");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the body in SingleChildScrollView so it scrolls when the keyboard opens.
    return Scaffold(
      appBar: AppBar(
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
        title: const Text(
          'Category Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  const Text('Category Name',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Type here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Add Images',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red, style: BorderStyle.solid),
                      ),
                      child: Center(
                        child: _image == null
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.image, size: 40, color: Colors.black54),
                            Text('Select File',
                                style: TextStyle(
                                    color: Colors.red, fontWeight: FontWeight.bold)),
                            Text('JPG, JPEG, PNG less than 1MB',
                                style: TextStyle(fontSize: 12, color: Colors.black54)),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: _saveCategory,
                child: const Text('Save',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
