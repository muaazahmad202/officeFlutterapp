import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cart.dart';
import 'cart_item.dart';
import 'product_model.dart';

class CartModel extends ChangeNotifier {
  Cart? _cart;

  // Getter for the list of cart items; returns an empty list if cart is null.
  List<CartItem> get items => _cart?.items ?? [];

  Cart? get cart => _cart;

  // Initialize a new cart for a user.
  void createCart({required String userId, double tax = 0}) {
    _cart = Cart(id: 0, items: [], userId: userId, tax: tax);
    notifyListeners();
  }

  // Add an item to the local cart.
  Future<void> addItem(Product product, {int quantity = 1}) async {
    if (_cart == null) {
      createCart(userId: "user@example.com");
    }
    final index = _cart!.items.indexWhere((item) => item.productId == product.id);
    if (index != -1) {
      _cart!.items[index].quantity += quantity;
      // Sync the updated item.
      await syncCartItem(_cart!.items[index], _cart!.userId);
    } else {
      final newItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch,
        productId: product.id,
        product: product,
        quantity: quantity,
      );
      _cart!.items.add(newItem);
      // Sync the new item.
      await syncCartItem(newItem, _cart!.userId);
    }
    notifyListeners();
  }

  // Remove an item from the local cart.
  Future<void> removeItem(int productId) async {
    if (_cart != null) {
      _cart!.items.removeWhere((item) => item.productId == productId);
      notifyListeners();
      // Optionally sync the updated cart.
      await syncCart(_cart!);
    }
  }

  // Update quantity for an item.
  Future<void> updateQuantity(int productId, int newQuantity) async {
    if (_cart != null) {
      final index = _cart!.items.indexWhere((item) => item.productId == productId);
      if (index != -1) {
        _cart!.items[index].quantity = newQuantity;
        notifyListeners();
        // Sync this update.
        await syncCartItem(_cart!.items[index], _cart!.userId);
      }
    }
  }

  // Increase quantity by 1.
  Future<void> increaseQuantity(int productId) async {
    if (_cart == null) return;
    final index = _cart!.items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      _cart!.items[index].quantity += 1;
      notifyListeners();
      await syncCartItem(_cart!.items[index], _cart!.userId);
    }
  }

  // Decrease quantity by 1.
  Future<void> decreaseQuantity(int productId) async {
    if (_cart == null) return;
    final index = _cart!.items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (_cart!.items[index].quantity > 1) {
        _cart!.items[index].quantity -= 1;
        notifyListeners();
        await syncCartItem(_cart!.items[index], _cart!.userId);
      } else {
        // If quantity is 1, remove the item.
        await removeItem(productId);
      }
    }
  }

  // Sync the entire cart using the add-cart API.
  Future<void> syncCart(Cart cart) async {
    const String apiUrl = "https://darnalbrojewelry.com/api/Cart/add-cart";
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(cart.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("Cart synced successfully!");
    } else {
      debugPrint("Failed to sync cart. Status: ${response.statusCode}");
    }
  }

  // Sync a single cart item using the add-item API.
  Future<void> syncCartItem(CartItem item, String userEmail) async {
    const String apiUrl = "https://darnalbrojewelry.com/api/Cart/add-item";
    final payload = {
      "item": item.toJson(),
      "useremail": userEmail,
    };
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("Cart item synced successfully!");
    } else {
      debugPrint("Failed to sync cart item. Status: ${response.statusCode}");
    }
  }

  // Load the cart from the API endpoint /api/Cart/get-all-carts.
  Future<void> loadCart() async {
    const String apiUrl = "https://darnalbrojewelry.com/api/Cart/get-all-carts";
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      // Assuming the endpoint returns a list of carts.
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isNotEmpty) {
        // Optionally, filter by userId if needed.
        _cart = Cart.fromJson(jsonList[0] as Map<String, dynamic>);
        notifyListeners();
      } else {
        debugPrint("No cart data found.");
      }
    } else {
      debugPrint("Failed to load cart. Status: ${response.statusCode}");
    }
  }

  // Helper getters for subtotal, taxAndFees, and total.
  double get subtotal {
    if (_cart == null) return 0;
    return _cart!.items.fold(
        0.0, (sum, item) => sum + (item.product.manualPrice * item.quantity));
  }

  double get taxAndFees {
    // Calculate tax and fees based on your business logic.
    return _cart?.tax ?? 0;
  }

  double get total {
    return subtotal + taxAndFees;
  }
}
