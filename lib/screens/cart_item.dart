import 'product_model.dart';

class CartItem {
  final int id;
  final int productId;
  final Product product;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      productId: json['productId'] as int,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "productId": productId,
      "product": product.toJson(),
      "quantity": quantity,
    };
  }
}
