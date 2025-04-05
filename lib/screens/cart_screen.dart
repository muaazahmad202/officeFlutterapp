import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'cartModel.dart';
import 'cart_item.dart';

/// Helper widget to display a product image. It checks whether the image string
/// starts with "http" (i.e. network image) or not (assumes Base64).
class ProductImageWidget extends StatelessWidget {
  final String imageStr;
  final double width;
  final double height;
  final BoxFit fit;

  const ProductImageWidget({
    Key? key,
    required this.imageStr,
    this.width = 80,
    this.height = 80,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  // Helper function: fixes a Base64 string by removing data URI scheme and adding missing padding.
  String fixBase64(String base64Str) {
    if (base64Str.contains(',')) {
      base64Str = base64Str.split(',').last;
    }
    base64Str = base64Str.trim();
    // Check for known placeholder or empty string.
    if (base64Str.toLowerCase() == 'string' || base64Str.isEmpty) {
      throw Exception('Invalid Base64 image string');
    }
    // Add padding if necessary.
    int remainder = base64Str.length % 4;
    if (remainder > 0) {
      base64Str = base64Str.padRight(base64Str.length + (4 - remainder), '=');
    }
    return base64Str;
  }

  @override
  Widget build(BuildContext context) {
    if (imageStr.startsWith("http")) {
      return Image.network(
        imageStr,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.broken_image, size: 50),
      );
    } else {
      // Assume Base64 image
      return FutureBuilder<Uint8List>(
        future: Future<Uint8List>.delayed(
          Duration.zero,
              () {
            final fixed = fixBase64(imageStr);
            return base64Decode(fixed);
          },
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              width: width,
              height: height,
              child: const Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Icon(Icons.broken_image, size: 50);
          } else {
            return Image.memory(
              snapshot.data!,
              width: width,
              height: height,
              fit: fit,
            );
          }
        },
      );
    }
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key, required int userId}) : super(key: key);

  // Use URL Launcher to initiate a call.
  Future<void> _callToOrder() async {
    final Uri telUri = Uri(scheme: 'tel', path: '0413983999');
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      debugPrint("Could not launch phone dialer.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final items = cartModel.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          // List of cart items.
          Expanded(
            child: items.isEmpty
                ? const Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return CartItemCard(item: item);
              },
            ),
          ),
          // Price summary.
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                _buildSummaryRow('Subtotal', cartModel.subtotal),
                const SizedBox(height: 4),
                _buildSummaryRow('Tax & Fees', cartModel.taxAndFees),
                const Divider(height: 20, thickness: 1),
                _buildSummaryRow(
                  'Total',
                  cartModel.total,
                  isTotal: true,
                ),
                const SizedBox(height: 16),
                // Call To Order button.
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _callToOrder,
                    child: const Text(
                      'Call To Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build the price summary rows.
  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: label == 'Total' ? Colors.red : Colors.black,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }
}

// A separate widget for each cart item card.
class CartItemCard extends StatelessWidget {
  final CartItem item;

  const CartItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Item image using the helper widget.
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ProductImageWidget(
                imageStr: item.product.productImage,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Item details.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name.
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Product weight.
                  Text(
                    'Weight: ${item.product.totalWeight} g',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  // Product price.
                  Text(
                    '\$${item.product.manualPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity stepper.
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () {
                    cartModel.decreaseQuantity(item.productId);
                  },
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.red),
                  onPressed: () {
                    cartModel.increaseQuantity(item.productId);
                  },
                ),
              ],
            ),
            // Delete icon.
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                cartModel.removeItem(item.productId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
